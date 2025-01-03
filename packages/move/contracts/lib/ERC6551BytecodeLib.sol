module Bytecode {

    use aptos_framework::account;
    use aptos_framework::error;
    use aptos_framework::event;
    use aptos_framework::hash;
    use aptos_framework::vector;

    struct CodeStore has key, store {
        code_map: table::Table<address, vector<u8>>,
    }

    /// Initialize the module for the sender
    public fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<CodeStore>(addr), error::already_exists(1));
        move_to(account, CodeStore { code_map: table::new<address, vector<u8>>() });
    }

    /// Add a code entry for a specific address
    public fun add_code(account: &signer, target_addr: address, code: vector<u8>) {
        let code_store = borrow_global_mut<CodeStore>(signer::address_of(account));
        table::add(&mut code_store.code_map, target_addr, code);
    }

    /// Retrieve the code size for a specific address
    public fun code_size(addr: address): u64 {
        if (!table::contains(&borrow_global<CodeStore>(addr).code_map, addr)) {
            return 0;
        }
        let code = table::borrow(&borrow_global<CodeStore>(addr).code_map, addr);
        vector::length(&code) as u64
    }

    /// Retrieve a segment of the code stored for a specific address
    public fun code_at(addr: address, start: u64, end: u64): vector<u8> acquires CodeStore {
        let code_store = borrow_global<CodeStore>(addr);
        if (!table::contains(&code_store.code_map, addr)) {
            return vector::empty<u8>();
        }

        let code = table::borrow(&code_store.code_map, addr);
        let code_length = vector::length(&code);
        if (start > code_length || end > code_length || start > end) {
            abort error::invalid_argument(1);
        }
        vector::sub_range(&code, start, end - start)
    }

    /// Simulate creating a new contract with the specified code
    public fun creation_code_for(account: &signer, code: vector<u8>): vector<u8> {
        let addr = signer::address_of(account);
        add_code(account, addr, code);
        code
    }
}
