const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MB1_MAGIC: u32 = 0x1BADB002;
const FLAGS: u32 = ALIGN | MEMINFO;

const MultibootHeader = extern struct {
    magic: u32 = MB1_MAGIC,
    flags: u32,
    checksum: u32,
};

export var multiboot align(4) linksection(".multiboot") = MultibootHeader{
    .flags = FLAGS,
    .checksum = @as(u32, @intCast(((-(@as(i64, @intCast(MB1_MAGIC)) + @as(i64, @intCast(FLAGS)))) & 0xFFFFFFFF))),
};

// https://ziglang.org/download/0.11.0/release-notes.html#Naked-Functions
pub export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ push %ebp
        \\ jmp %[start:P]
        :
        : [start] "X" (&start),
    );
}

pub fn start() void {
    terminal.initialize();
    terminal.write("Hello, Kernel World from Zig 0.7.1!");
}

// Hardware text mode color constants
const VgaColor = u8;
const VGA_COLOR_BLACK = 0;
const VGA_COLOR_BLUE = 1;
const VGA_COLOR_GREEN = 2;
const VGA_COLOR_CYAN = 3;
const VGA_COLOR_RED = 4;
const VGA_COLOR_MAGENTA = 5;
const VGA_COLOR_BROWN = 6;
const VGA_COLOR_LIGHT_GREY = 7;
const VGA_COLOR_DARK_GREY = 8;
const VGA_COLOR_LIGHT_BLUE = 9;
const VGA_COLOR_LIGHT_GREEN = 10;
const VGA_COLOR_LIGHT_CYAN = 11;
const VGA_COLOR_LIGHT_RED = 12;
const VGA_COLOR_LIGHT_MAGENTA = 13;
const VGA_COLOR_LIGHT_BROWN = 14;
const VGA_COLOR_WHITE = 15;

fn vga_entry_color(fg: VgaColor, bg: VgaColor) u8 {
    return fg | (bg << 4);
}

fn vga_entry(uc: u8, color: u8) u16 {
    var c: u16 = color;

    return uc | (c << 8);
}

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

const terminal = struct {
    var row: usize = 0;
    var column: usize = 0;

    var color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);

    const buffer = @as([*]volatile u16, @ptrFromInt(0xB8000));

    fn initialize() void {
        var y: usize = 0;
        while (y < VGA_HEIGHT) : (y += 1) {
            var x: usize = 0;
            while (x < VGA_WIDTH) : (x += 1) {
                putCharAt(' ', color, x, y);
            }
        }
    }

    fn setColor(new_color: u8) void {
        color = new_color;
    }

    fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
        const index = y * VGA_WIDTH + x;
        buffer[index] = vga_entry(c, new_color);
    }

    fn putChar(c: u8) void {
        putCharAt(c, color, column, row);
        column += 1;
        if (column == VGA_WIDTH) {
            column = 0;
            row += 1;
            if (row == VGA_HEIGHT)
                row = 0;
        }
    }

    fn write(data: []const u8) void {
        for (data) |c|
            putChar(c);
    }
};
