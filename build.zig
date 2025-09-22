//! This is the build.zig file for the bls12-381 signature library
//! Copyright (c) 2025 zk-evm
//! SPDX-License-Identifier: Apache-2.0
//!
//! It builds the bls12-381 signature library
//! The bls12-381 signature library is built using the blst library

const std = @import("std");
const Compile = std.Build.Step.Compile;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const blst_dep = b.dependency("blst", .{ .target = target, .optimize = optimize });
    const portable = b.option(bool, "portable", "Enable portable implementation") orelse false;
    const force_adx = b.option(bool, "force-adx", "Enable ADX optimizations") orelse false;
    const staticLib = b.addLibrary(.{
        .name = "bls12-381",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const module_bls12_381_min_pk = b.createModule(.{
        .root_source_file = b.path("src/root_min_pk.zig"),
        .target = target,
        .optimize = optimize,
    });
    try withBlst(blst_dep, module_bls12_381_min_pk, target, false, portable, force_adx);

    b.modules.put(b.dupe("bls12-381-min-pk"), module_bls12_381_min_pk) catch @panic("OOM");

    const module_bls12_381_min_sig = b.createModule(.{
        .root_source_file = b.path("src/root_min_sig.zig"),
        .target = target,
        .optimize = optimize,
    });
    try withBlst(blst_dep, module_bls12_381_min_sig, target, false, portable, force_adx);
    b.modules.put(b.dupe("bls12-381-min-sig"), module_bls12_381_min_sig) catch @panic("OOM");

    staticLib.linkLibC();
    try withBlst(blst_dep, staticLib.root_module, target, false, portable, force_adx);

    b.installArtifact(staticLib);

    const sharedLib = b.addLibrary(.{
        .name = "bls12-381-min-pk",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root_c_abi_min_pk.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    sharedLib.linkLibC();
    try withBlst(blst_dep, sharedLib.root_module, target, true, portable, force_adx);
    b.installArtifact(sharedLib);

    const exe = b.addExecutable(.{
        .name = "bls12-381",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const lib_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    try withBlst(blst_dep, lib_unit_tests.root_module, target, true, portable, force_adx);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const exe_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);

    // Add benchmark tests
    const benchmark_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/benchmarks.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    try withBlst(blst_dep, benchmark_tests.root_module, target, true, portable, force_adx);

    const run_benchmark_tests = b.addRunArtifact(benchmark_tests);
    const bench_step = b.step("bench", "Run benchmark tests");
    bench_step.dependOn(&run_benchmark_tests.step);
}

fn withBlst(blst_dep: *std.Build.Dependency, module: *std.Build.Module, target: ResolvedTarget, is_shared_lib: bool, portable: bool, force_adx: bool) !void {
    module.addIncludePath(blst_dep.path("bindings"));
    const arch = target.result.cpu.arch;

    if (portable == true and force_adx == false) {
        module.addCMacro("__BLST_PORTABLE__", "");
    } else if (portable == false and force_adx == true) {
        if (arch == .x86_64) {
            module.addCMacro("__ADX__", "");
        } else {
            std.debug.print("`force-adx` is ignored for non-x86_64 targets \n", .{});
        }
    } else if (portable == false and force_adx == false) {
        if (arch == .x86_64) {
            std.debug.print("ADX is turned on by default for x86_64 targets \n", .{});
            module.addCMacro("__ADX__", "");
        }
    } else {
        // both are true
        @panic("Cannot set both `portable` and `force-adx` to true");
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var cflags = std.ArrayListUnmanaged([]const u8){};
    defer cflags.deinit(allocator);

    if (arch == .x86_64) {
        try cflags.append(allocator, "-mno-avx"); // avoid costly transitions
    }
    try cflags.append(allocator, "-fno-builtin");
    try cflags.append(allocator, "-Wno-unused-function");
    try cflags.append(allocator, "-Wno-unused-command-line-argument");

    if (is_shared_lib) {
        try cflags.append(allocator, "-fPIC");
    }

    module.addCSourceFile(.{ .file = blst_dep.path("src/server.c"), .flags = cflags.items });
    module.addCSourceFile(.{ .file = blst_dep.path("build/assembly.S"), .flags = cflags.items });

    const os = target.result.os;
    if (os.tag == .linux) {
        module.addIncludePath(.{ .cwd_relative = "/usr/local/include" });
        module.addIncludePath(.{ .cwd_relative = "/usr/include" });
        if (arch == .x86_64) {
            module.addIncludePath(.{ .cwd_relative = "/usr/include/x86_64-linux-gnu" });
        } else if (arch == .aarch64) {
            module.addIncludePath(.{ .cwd_relative = "/usr/include/aarch64-linux-gnu" });
        }
    }
}
