//! This is the c_imports module for the bls12-381 signature library
//! Copyright (c) 2025 zk-evm
//! SPDX-License-Identifier: Apache-2.0
//!
//! It imports the blst.h file for the bls12-381 signature library
//! All C imports should go through this file for the bls12-381 signature library

// Centralized @cImport to avoid type conflicts
pub const c = @cImport({
    @cInclude("blst.h");
});
