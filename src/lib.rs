#![no_std]

use core::mem::MaybeUninit;
use core::sync::atomic::{AtomicU32, Ordering};

const ALPHA: u32 = 0xFF_00_00_00;
const COLOUR: u32 = 0x00_FF_FF_FF;

const WIDTH: usize = 50;
const HEIGHT: usize = 50;

#[no_mangle]
static mut BUFFER: [u32; WIDTH * HEIGHT] = [0; WIDTH * HEIGHT];

static FRAME: AtomicU32 = AtomicU32::new(0);

#[no_mangle]
pub unsafe extern "C" fn go() {
    render_frame(&mut BUFFER)
}

fn tick_lfsr(seed: u32) -> u32 {
    (seed << 1) | ((seed & 0b11010000_00001000).count_ones() & 1)
}

#[inline(never)]
fn set(pixel: &mut u32, alive: bool) {
    if alive {
        *pixel = ALPHA | *pixel
    } else {
        *pixel = (((*pixel & ALPHA) / 4 * 3) & ALPHA) | (*pixel & COLOUR)
    }
}

fn render_frame(buffer: &mut [u32; WIDTH * HEIGHT]) {
    let mut lfsr = FRAME.load(Ordering::Relaxed) + 1;
    for v in buffer.iter_mut() {
        set(v, (*v & ALPHA) == ALPHA);
        if FRAME.load(Ordering::Relaxed) == 0 {
            if lfsr % 2 == 0 {
                *v = 0x00_1f_60_02;
            } else {
                *v = 0xFF_1F_60_02;
            }
            lfsr = tick_lfsr(lfsr);
        }
    }
    FRAME.fetch_add(1, Ordering::Relaxed);
    if FRAME.load(Ordering::Relaxed) % 10 == 0 {
        let old_board: [u32; WIDTH * HEIGHT] = unsafe {
            let mut d = [const { MaybeUninit::uninit() }; WIDTH * HEIGHT];
            for i in 0..WIDTH * HEIGHT {
                d[i].write(buffer[i] / ALPHA);
            }
            core::mem::transmute(d)
        };
        for idx in 0..(WIDTH * HEIGHT) - 2 * WIDTH - 2 {
            let n_count = old_board[idx]
                + old_board[idx + 1]
                + old_board[idx + 2]
                + old_board[idx + WIDTH]
                + old_board[idx + WIDTH + 1]
                + old_board[idx + WIDTH + 2]
                + old_board[idx + 2 * WIDTH]
                + old_board[idx + 2 * WIDTH + 1]
                + old_board[idx + 2 * WIDTH + 2];
            set(
                &mut buffer[idx + WIDTH + 1],
                if old_board[idx + WIDTH + 1] != 0 {
                    n_count == 3 || n_count == 4
                } else {
                    n_count == 3
                },
            );
        }
        for y in 0..HEIGHT {
            set(&mut buffer[y * WIDTH + 0], lfsr % 2 == 0);
            set(&mut buffer[y], lfsr % 8 < 4);
            set(&mut buffer[(HEIGHT - 1) * WIDTH + y], lfsr % 16 < 8);
            lfsr = tick_lfsr(lfsr);
        }
    }
}

#[panic_handler]
fn handle_panic(_: &core::panic::PanicInfo) -> ! {
    loop {}
}
