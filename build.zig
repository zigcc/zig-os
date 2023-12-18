const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "my-kernel",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = .Debug,
    });
    exe.linker_script = .{ .path = "linker.ld" };
    b.installArtifact(exe);
}
