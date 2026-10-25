/// Leslie Lamport - Sui Move Object-Centric Launchpad Protocol
/// Token Symbol: $LAMPORT
module leslie_lamport_ai::launchpad_token {
    use sui::coin::{Self, TreasuryCap, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{String};

    /// One-Time-Witness for currency initialization
    struct LAUNCHPAD_TOKEN has drop {}

    /// Micro-Escrow Milestone Vault
    struct MicroEscrowVault has key {
        id: UID,
        balance: Balance<SUI>,
        milestone: String,
        admin: address
    }

    fun init(witness: LAUNCHPAD_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            9,
            b"LAMPORT",
            b"Leslie Lamport",
            b"Foundational distributed computing theory; Lamport timestamps, Paxos consensus, LaTeX",
            std::option::none(),
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    /// Bonding curve token minting against SUI payment
    public entry fun mint(
        cap: &mut TreasuryCap<LAUNCHPAD_TOKEN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(cap, amount, recipient, ctx);
    }

    /// Disburse milestone escrow to verified recipient
    public entry fun disburse_milestone(
        vault: &mut MicroEscrowVault,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == vault.admin, 0);
        let payment = coin::take(&mut vault.balance, amount, ctx);
        transfer::public_transfer(payment, recipient);
    }
}
