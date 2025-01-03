module TokenBoundAccount {

    use aptos_framework::coin::{transfer, deposit, withdraw};
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use aptos_framework::error;
    use aptos_framework::hash;

    struct Account {
        nonce: u64,
        owner: address,
        events: event::EventHandle<u64>,
    }

    struct CallResult has store {
        success: bool,
        data: vector<u8>,
    }

    struct ExecuteEvent has key, store {
        caller: address,
        to: address,
        value: u64,
        data: vector<u8>,
        result: CallResult,
    }

    public fun initialize(account: &signer, owner: address) {
        let account_addr = signer::address_of(account);

        assert!(account::exists(account_addr), error::invalid_argument(1));
        let events = event::new_event_handle<u64>(account);
        move_to(account, Account { nonce: 0, owner, events });
    }

    public fun execute_call(account: &signer, to: address, value: u64, data: vector<u8>): CallResult {
        let addr = signer::address_of(account);

        // Check ownership
        let acc = borrow_global_mut<Account>(addr);
        assert!(acc.owner == signer::address_of(account), error::permission_denied(1));

        // Increment nonce for replay protection
        acc.nonce = acc.nonce + 1;

        // Emit the execution attempt
        let result = execute_transaction_internal(to, value, data);
        event::emit_event(&mut acc.events, acc.nonce);
        result
    }

    public fun nonce(account: address): u64 {
        let acc = borrow_global<Account>(account);
        acc.nonce
    }

    public fun owner(account: address): address {
        let acc = borrow_global<Account>(account);
        acc.owner
    }

    fun execute_transaction_internal(to: address, value: u64, data: vector<u8>): CallResult {
        let success: bool;
        let result_data: vector<u8>;

        // Handle the transaction logic
        if account::exists(to) {
            transfer(signer::address_of(account), to, value);
            success = true;
            result_data = data; // Return the executed data
        } else {
            success = false;
            result_data = vector::empty();
        }

        CallResult { success, data: result_data }
    }
}
