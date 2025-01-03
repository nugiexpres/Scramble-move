module IERC6551Registry {

    use aptos_framework::coin::{transfer};
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::hash;
    use aptos_framework::vector;

    struct AccountCreatedEvent has key, store {
        account: address,
        implementation: address,
        chain_id: u64,
        token_contract: address,
        token_id: u64,
        salt: u64,
    }

    struct AccountData has store {
        implementation: address,
        chain_id: u64,
        token_contract: address,
        token_id: u64,
        salt: u64,
    }

    struct Registry has key, store {
        events: event::EventHandle<AccountCreatedEvent>,
        accounts: vector<AccountData>,
    }

    /// Initializes the registry on-chain
    public fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<Registry>(addr), 1);
        let events = event::new_event_handle<AccountCreatedEvent>(account);
        move_to(account, Registry { events, accounts: vector::empty<AccountData>() });
    }

    /// Creates an account and emits an AccountCreated event
    public fun create_account(
        account: &signer,
        implementation: address,
        chain_id: u64,
        token_contract: address,
        token_id: u64,
        seed: u64
    ): address {
        let addr = signer::address_of(account);

        // Generate a deterministic address based on input parameters
        let account_hash = hash::sha3_256(vector::concat(
            vector::from_slice(&[
                implementation,
                chain_id,
                token_contract,
                token_id,
                seed
            ]),
        ));
        let new_account_address = hash_to_address(account_hash);

        // Register account
        let registry = borrow_global_mut<Registry>(addr);
        vector::push_back(&mut registry.accounts, AccountData {
            implementation,
            chain_id,
            token_contract,
            token_id,
            salt: seed,
        });

        // Emit the account creation event
        event::emit_event(
            &mut registry.events,
            AccountCreatedEvent {
                account: new_account_address,
                implementation,
                chain_id,
                token_contract,
                token_id,
                salt: seed,
            },
        );

        new_account_address
    }

    /// Fetches the account data based on parameters
    public fun get_account(
        addr: address,
        implementation: address,
        chain_id: u64,
        token_contract: address,
        token_id: u64,
        salt: u64,
    ): address {
        let registry = borrow_global<Registry>(addr);

        let accounts = &registry.accounts;
        let len = vector::length(accounts);
        let mut i = 0;

        while (i < len) {
            let account_data = vector::borrow(accounts, i);
            if account_data.implementation == implementation &&
               account_data.chain_id == chain_id &&
               account_data.token_contract == token_contract &&
               account_data.token_id == token_id &&
               account_data.salt == salt {
                return hash_to_address(hash::sha3_256(vector::concat(
                    vector::from_slice(&[
                        implementation,
                        chain_id,
                        token_contract,
                        token_id,
                        salt,
                    ]),
                )));
            }
            i = i + 1;
        }

        abort 2; // Account not found
    }

    /// Converts a hash to an address
    fun hash_to_address(hash: vector<u8>): address {
        assert!(vector::length(&hash) >= 16, 3);
        let truncated = vector::sub(hash, 0, 16);
        vector::to_address(truncated)
    }
}
