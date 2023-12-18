const std = @import("std");
const print = std.debug.print;

// https://ziglang.org/download/0.11.0/release-notes.html#Naked-Functions
pub export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ push %rbp
        \\ jmp %[start:P]
        :
        : [start] "X" (&start),
    );
}
fn start() void {}
