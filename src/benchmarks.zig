//! Comprehensive benchmarks for BLS12-381 signature library
//! Copyright (c) 2025 zk-evm
//! SPDX-License-Identifier: Apache-2.0

const std = @import("std");
const testing = std.testing;
const print = std.debug.print;
const builtin = @import("builtin");

const root_min_pk = @import("root_min_pk.zig");
const root_min_sig = @import("root_min_sig.zig");

// Import the library modules
// Test parameters
const NUM_ITERATIONS = 1000;
const NUM_BATCH_SIGS = 100;
const NUM_KEYS_FOR_AGG = 10;

// Timer helper for benchmarking
fn Timer() type {
    return struct {
        start_time: i128,

        const Self = @This();

        pub fn start() Self {
            return Self{ .start_time = std.time.nanoTimestamp() };
        }

        pub fn elapsed(self: Self) f64 {
            const end_time = std.time.nanoTimestamp();
            return @as(f64, @floatFromInt(end_time - self.start_time)) / 1_000_000.0; // Convert to milliseconds
        }

        pub fn elapsedMicros(self: Self) f64 {
            const end_time = std.time.nanoTimestamp();
            return @as(f64, @floatFromInt(end_time - self.start_time)) / 1_000.0; // Convert to microseconds
        }
    };
}

// Generate random key material
fn generateRandomKey(rng: *std.Random.DefaultPrng) [32]u8 {
    var ikm: [32]u8 = undefined;
    rng.random().bytes(&ikm);
    return ikm;
}

// Benchmark key generation (Min-PK variant)
test "benchmark_key_generation_min_pk" {
    print("\n=== Key Generation Benchmark (Min-PK) ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const timer = Timer().start();

    for (0..NUM_ITERATIONS) |_| {
        const ikm = generateRandomKey(&rng);
        _ = try root_min_pk.SecretKey.keyGen(&ikm, null);
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0);
    const avg_time_us = (elapsed * 1000.0) / NUM_ITERATIONS;

    print("Generated {} secret keys in {d:.2} ms\n", .{ NUM_ITERATIONS, elapsed });
    print("Average: {d:.1} μs per key\n", .{avg_time_us});
    print("Throughput: {d:.0} keys/sec\n\n", .{ops_per_sec});
}

// Benchmark signing (Min-PK variant)
test "benchmark_signing_min_pk" {
    print("=== Signing Benchmark (Min-PK) ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const ikm = generateRandomKey(&rng);
    const sk = try root_min_pk.SecretKey.keyGen(&ikm, null);

    const dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";
    const msg = "benchmark message for signing performance test";

    const timer = Timer().start();

    for (0..NUM_ITERATIONS) |_| {
        _ = sk.sign(msg, dst, null);
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0);
    const avg_time_us = (elapsed * 1000.0) / NUM_ITERATIONS;

    print("Signed {} messages in {d:.2} ms\n", .{ NUM_ITERATIONS, elapsed });
    print("Average: {d:.1} μs per signature\n", .{avg_time_us});
    print("Throughput: {d:.0} signatures/sec\n\n", .{ops_per_sec});
}

// Benchmark verification (Min-PK variant)
test "benchmark_verification_min_pk" {
    print("=== Verification Benchmark (Min-PK) ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const ikm = generateRandomKey(&rng);
    const sk = try root_min_pk.SecretKey.keyGen(&ikm, null);
    const pk = sk.skToPk();

    const dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";
    const msg = "benchmark message for verification performance test";
    const sig = sk.sign(msg, dst, null);

    const timer = Timer().start();

    for (0..NUM_ITERATIONS) |_| {
        try sig.verify(true, msg, dst, null, &pk, true);
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0);
    const avg_time_us = (elapsed * 1000.0) / NUM_ITERATIONS;

    print("Verified {} signatures in {d:.2} ms\n", .{ NUM_ITERATIONS, elapsed });
    print("Average: {d:.1} μs per verification\n", .{avg_time_us});
    print("Throughput: {d:.0} verifications/sec\n\n", .{ops_per_sec});
}

// Benchmark signature aggregation (Min-PK variant)
test "benchmark_aggregation_min_pk" {
    print("=== Signature Aggregation Benchmark (Min-PK) ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";
    const msg = "benchmark message for aggregation performance test";

    // Prepare keys and signatures
    var sks: [NUM_KEYS_FOR_AGG]root_min_pk.SecretKey = undefined;
    var pks: [NUM_KEYS_FOR_AGG]root_min_pk.PublicKey = undefined;
    var sigs: [NUM_KEYS_FOR_AGG]root_min_pk.Signature = undefined;
    var sig_refs: [NUM_KEYS_FOR_AGG]*const root_min_pk.Signature = undefined;

    for (0..NUM_KEYS_FOR_AGG) |i| {
        const ikm = generateRandomKey(&rng);
        sks[i] = try root_min_pk.SecretKey.keyGen(&ikm, null);
        pks[i] = sks[i].skToPk();
        sigs[i] = sks[i].sign(msg, dst, null);
        sig_refs[i] = &sigs[i];
    }

    const iterations = NUM_ITERATIONS / 10; // Fewer iterations for aggregation
    const timer = Timer().start();

    for (0..iterations) |_| {
        _ = try root_min_pk.AggregateSignature.aggregate(sig_refs[0..], false);
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, iterations) / (elapsed / 1000.0);
    const avg_time_us = (elapsed * 1000.0) / @as(f64, iterations);

    print("Aggregated {} sets of {} signatures in {d:.2} ms\n", .{ iterations, NUM_KEYS_FOR_AGG, elapsed });
    print("Average: {d:.1} μs per aggregation\n", .{avg_time_us});
    print("Throughput: {d:.0} aggregations/sec\n\n", .{ops_per_sec});
}

// Benchmark aggregate verification (Min-PK variant)
test "benchmark_aggregate_verification_min_pk" {
    print("=== Aggregate Verification Benchmark (Min-PK) ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";
    const msg = "benchmark message for aggregate verification performance test";

    // Prepare keys and signatures
    var sks: [NUM_BATCH_SIGS]root_min_pk.SecretKey = undefined;
    var pks: [NUM_BATCH_SIGS]root_min_pk.PublicKey = undefined;
    var sigs: [NUM_BATCH_SIGS]root_min_pk.Signature = undefined;
    var sig_refs: [NUM_BATCH_SIGS]*const root_min_pk.Signature = undefined;
    var pk_refs: [NUM_BATCH_SIGS]*const root_min_pk.PublicKey = undefined;

    for (0..NUM_BATCH_SIGS) |i| {
        const ikm = generateRandomKey(&rng);
        sks[i] = try root_min_pk.SecretKey.keyGen(&ikm, null);
        pks[i] = sks[i].skToPk();
        sigs[i] = sks[i].sign(msg, dst, null);
        sig_refs[i] = &sigs[i];
        pk_refs[i] = &pks[i];
    }

    // Create aggregate signature
    const agg_sig = try root_min_pk.AggregateSignature.aggregate(sig_refs[0..], false);
    const final_sig = agg_sig.toSignature();

    // Create aggregate public key
    const agg_pk = try root_min_pk.AggregatePublicKey.aggregate(pk_refs[0..], false);
    const final_pk = agg_pk.toPublicKey();

    const iterations = 100; // Fewer iterations for expensive operations
    const timer = Timer().start();

    for (0..iterations) |_| {
        try final_sig.verify(true, msg, dst, null, &final_pk, true);
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, iterations) / (elapsed / 1000.0);
    const avg_time_ms = elapsed / @as(f64, iterations);

    print("Verified {} aggregate signatures ({} sigs each) in {d:.2} ms\n", .{ iterations, NUM_BATCH_SIGS, elapsed });
    print("Average: {d:.2} ms per aggregate verification\n", .{avg_time_ms});
    print("Throughput: {d:.1} aggregate verifications/sec\n", .{ops_per_sec});
    print("Effective throughput: {d:.0} individual sig verifications/sec\n\n", .{ops_per_sec * NUM_BATCH_SIGS});
}

// Benchmark public key derivation
test "benchmark_pubkey_derivation" {
    print("=== Public Key Derivation Benchmark ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));

    // Pre-generate secret keys
    var secret_keys: [NUM_ITERATIONS]root_min_pk.SecretKey = undefined;
    for (0..NUM_ITERATIONS) |i| {
        const ikm = generateRandomKey(&rng);
        secret_keys[i] = try root_min_pk.SecretKey.keyGen(&ikm, null);
    }

    const timer = Timer().start();

    for (0..NUM_ITERATIONS) |i| {
        _ = secret_keys[i].skToPk();
    }

    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0);
    const avg_time_us = (elapsed * 1000.0) / NUM_ITERATIONS;

    print("Derived {} public keys in {d:.2} ms\n", .{ NUM_ITERATIONS, elapsed });
    print("Average: {d:.1} μs per derivation\n", .{avg_time_us});
    print("Throughput: {d:.0} derivations/sec\n\n", .{ops_per_sec});
}

// Benchmark serialization/deserialization
test "benchmark_serialization" {
    print("=== Serialization Benchmark ===\n", .{});

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const ikm = generateRandomKey(&rng);
    const sk = try root_min_pk.SecretKey.keyGen(&ikm, null);
    const pk = sk.skToPk();

    const dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";
    const msg = "benchmark message";
    const sig = sk.sign(msg, dst, null);

    // Benchmark public key serialization
    var timer = Timer().start();
    for (0..NUM_ITERATIONS) |_| {
        _ = pk.compress();
    }
    var elapsed = timer.elapsed();
    print("PK Compression: {d:.0} ops/sec ({d:.1} μs avg)\n", .{ @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0), (elapsed * 1000.0) / NUM_ITERATIONS });

    // Benchmark signature serialization
    timer = Timer().start();
    for (0..NUM_ITERATIONS) |_| {
        _ = sig.compress();
    }
    elapsed = timer.elapsed();
    print("Sig Compression: {d:.0} ops/sec ({d:.1} μs avg)\n", .{ @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0), (elapsed * 1000.0) / NUM_ITERATIONS });

    // Benchmark public key deserialization
    const pk_bytes = pk.compress();
    timer = Timer().start();
    for (0..NUM_ITERATIONS) |_| {
        _ = try root_min_pk.PublicKey.uncompress(&pk_bytes);
    }
    elapsed = timer.elapsed();
    print("PK Decompression: {d:.0} ops/sec ({d:.1} μs avg)\n", .{ @as(f64, NUM_ITERATIONS) / (elapsed / 1000.0), (elapsed * 1000.0) / NUM_ITERATIONS });

    print("\n", .{});
}

// Comprehensive performance summary
test "benchmark_summary" {
    print("\n" ++ "=" ** 50 ++ "\n", .{});
    print("  BLS12-381 Performance Benchmark Summary\n", .{});
    print("  Platform: {} on {s}\n", .{ builtin.cpu.arch, @tagName(builtin.os.tag) });
    print("  Zig Version: {s}\n", .{builtin.zig_version_string});
    print("  Optimization: Debug (use -Doptimize=ReleaseFast for production)\n", .{});
    print("=" ** 50 ++ "\n\n", .{});

    print("Run individual benchmarks:\n", .{});
    print("  zig build test --test-filter \"benchmark_key_generation\"\n", .{});
    print("  zig build test --test-filter \"benchmark_signing\"\n", .{});
    print("  zig build test --test-filter \"benchmark_verification\"\n", .{});
    print("  zig build test --test-filter \"benchmark_aggregation\"\n", .{});
    print("  zig build test --test-filter \"benchmark_serialization\"\n\n", .{});

    print("For production performance, build with:\n", .{});
    print("  zig build test -Doptimize=ReleaseFast\n\n", .{});
}
