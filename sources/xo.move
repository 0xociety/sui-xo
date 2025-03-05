// Copyright (c) Ndus Interactive, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Coin<XO> is the xociety's token used to maintain echo-system on Sui blockchain.
/// It has 9 decimals, and the smallest unit (10^-9) is called "motus".
module xo::xo;

use sui::coin::{Self, TreasuryCap};

const EAlreadyMinted: u64 = 0;
/// Sender is not @0x0 the system address.
const ENotSystemAddress: u64 = 1;

#[allow(unused_const)]
/// The amount of Motus per XO token based on the fact that motus is
/// 10^-9 of a XO token
const MOTUS_PER_XO: u64 = 1_000_000_000;

#[allow(unused_const)]
/// The total supply of XO denominated in whole XO tokens (5 Billion)
const TOTAL_SUPPLY_XO: u64 = 5_000_000_000;

/// The total supply of XO denominated in Motus (5 Billion * 10^9)
const TOTAL_SUPPLY_MOTUS: u64 = 5_000_000_000_000_000_000;

/// Name of the coin
public struct XO has drop {}

/// Register the `XO` Coin to acquire its `Supply`.
/// This should be called only once during the deployment.
fun init(otw: XO, ctx: &mut TxContext) {
    assert!(ctx.sender() == @0x0, ENotSystemAddress);
    assert!(ctx.epoch() == 0, EAlreadyMinted);

    let (treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"XO",
        b"Xociety Token",
        b"Base currency for the Xociety echo system", // description
        // url - will be changed later 
        option::some(sui::url::new_unsafe(std::ascii::string(b"https://app.xociety.io/assets/ntx/obj-ntx.png"))),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury, ctx.sender())
}

// Create XO token using the TreasuryCap.
// Will mint 5 billion - total supply - only once.
public fun mint(
    treasury_cap: &mut TreasuryCap<XO>,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, TOTAL_SUPPLY_MOTUS, ctx);
    transfer::public_transfer(coin, recipient)
}

