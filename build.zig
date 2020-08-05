const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .default_target = try std.zig.CrossTarget.parse(.{
            .arch_os_abi = if (std.builtin.os.tag == .windows)
                "native-native-gnu" // on windows, use gnu by default
            else
                "native-linux-musl", // glibc has some problems by-default, use musl instead
        }),
    });

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("init-exe", "src/main.zig");
    exe.addPackagePath("win32", "../../libs/zig-win32/src/main.zig");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("kernel32");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
