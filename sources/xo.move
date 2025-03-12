// Copyright (c) Ndus Interactive, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Coin<XO> is the xociety's token used to maintain ecosystem on Sui blockchain.
/// It has 9 decimals, and the smallest unit (10^-9) is called "motus".
module xo::xo;

use sui::coin::{Self, TreasuryCap};
use sui::dynamic_object_field as dof;

/// The total supply of XO denominated in Motus (5 Billion * 10^9)
const TOTAL_SUPPLY_XO_WITH_DECIMALS: u64 = 5_000_000_000_000_000_000;

/// Name of the coin
public struct XO has drop {}

public struct WrappedTreasury<phantom T> has key { id: UID,}

/// Save the `TreasuryCap` as a DOF, to maintain discoverability.
public struct TreasuryCapKey() has copy, store, drop;

/// Register the `XO` Coin to acquire its `Supply`.
/// This should be called only once during the deployment.
fun init(otw: XO, ctx: &mut TxContext) {
    let (mut treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"XO",
        b"Xociety Token",
        b"Base currency for the Xociety ecosystem", // description
        // url
        option::some(sui::url::new_unsafe(std::ascii::string(b"https://app.xociety.io/assets/xo/xo_token.png"))),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    
    // mint all the tokens & freeze TreasuryCap
    mint_and_transfer_to_sender(&mut treasury, ctx.sender(), ctx);
    wrap_and_freeze_treasury(treasury, ctx);
}

/// Wrap a `TreasuryCap<T>` in a `WrappedTreasury<T>` object.
/// `WrappedTreasury<T>` must be shared.
/// below function has to be executed fun init phase when contract deployed
fun wrap_and_freeze_treasury<T>(treasury_cap: TreasuryCap<T>, ctx: &mut TxContext,) {
  let mut id = object::new(ctx);
  dof::add(&mut id, TreasuryCapKey(), treasury_cap);

  let wrapped_treasury = WrappedTreasury<T> { id };
  transfer::freeze_object(wrapped_treasury);  
}

// Create XO token using the TreasuryCap.
// Will mint 5 billion - total supply - only once.
fun mint_and_transfer_to_sender(
    treasury_cap: &mut TreasuryCap<XO>,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, TOTAL_SUPPLY_XO_WITH_DECIMALS, ctx);
    transfer::public_transfer(coin, recipient)
}

