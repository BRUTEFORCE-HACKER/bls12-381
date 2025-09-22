//! This is the main module for the bls12-381 signature library
//! Copyright (c) 2025 zk-evm
//! SPDX-License-Identifier: Apache-2.0
//!
//! It prints a message to the console
//! It also tests the library

const std = @import("std");

pub fn main() !void {
    std.debug.print("bls12-381 signature library\n", .{});
    std.debug.print("Copyright (c) 2025 zk-evm\n", .{});
    std.debug.print("https://github.com/zk-evm/bls12-381\n", .{});

    var stdout_buffer: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&stdout_buffer);
    try stdout.interface.print("Run `zig build test` to run the tests.\n", .{});
    try stdout.interface.print("Run `zig build` to build the bls12-381 lib.\n", .{});
    try stdout.interface.flush();
}

test "simple test" {
    var list = std.ArrayListUnmanaged(i32){};
    defer list.deinit(std.testing.allocator);
    try list.append(std.testing.allocator, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
