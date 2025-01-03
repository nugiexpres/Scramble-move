module BreadToken {
    use std::signer;
    use std::vector;
    use std::table;

    struct Token has key, store {
        name: vector<u8>,
        symbol: vector<u8>,
        total_supply: u64,
        balances: table::Table<address, u64>,
    }

    // Initialize the contract with fixed name, symbol, and initial supply of 0
    public fun initialize(account: &signer) {
        let token = Token {
            name: b"Bread", // Fixed token name
            symbol: b"B",   // Fixed token symbol
            total_supply: 0, // Start with 0 supply
            balances: table::Table::empty(),
        };
        table::add(&mut token.balances, signer::address_of(account), 0); // Initialize with 0 balance
        move_to(account, token);
    }

    // Mint tokens to a specific account
    public fun mint(account: address, amount: u64, signer: &signer) {
        let token = borrow_global_mut<Token>(signer::address_of(signer));
        let current_balance = table::borrow_mut(&mut token.balances, account).unwrap_or(0);
        table::add(&mut token.balances, account, current_balance + amount);
        token.total_supply = token.total_supply + amount;
    }

    // Burn tokens from a specific account
    public fun burn(account: address, amount: u64, signer: &signer) {
        let token = borrow_global_mut<Token>(signer::address_of(signer));
        let current_balance = table::borrow_mut(&mut token.balances, account).unwrap_or(0);
        assert!(current_balance >= amount, "Insufficient balance to burn tokens");
        table::add(&mut token.balances, account, current_balance - amount);
        token.total_supply = token.total_supply - amount;
    }

    // Get the balance of a specific account
    public fun balance_of(account: address): u64 {
        let token = borrow_global<Token>(signer::address_of(account));
        table::borrow(&token.balances, account).unwrap_or(0)
    }

    // Get the fixed token name
    public fun get_name(): vector<u8> {
        let token = borrow_global<Token>(signer::address_of(signer::address_of()));
        token.name
    }

    // Get the fixed token symbol
    public fun get_symbol(): vector<u8> {
        let token = borrow_global<Token>(signer::address_of(signer::address_of()));
        token.symbol
    }
}
