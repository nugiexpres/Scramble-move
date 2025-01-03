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

    public fun initialize(name: vector<u8>, symbol: vector<u8>, initial_supply: u64, account: &signer) {
        let token = Token {
            name,
            symbol,
            total_supply: initial_supply,
            balances: table::Table::empty(),
        };
        table::add(&mut token.balances, signer::address_of(account), initial_supply);
        move_to(account, token);
    }

    public fun mint(account: address, amount: u64, signer: &signer) {
        let token = borrow_global_mut<Token>(signer::address_of(signer));
        let current_balance = table::borrow_mut(&mut token.balances, account).unwrap_or(0);
        table::add(&mut token.balances, account, current_balance + amount);
        token.total_supply = token.total_supply + amount;
    }

    public fun burn(account: address, amount: u64, signer: &signer) {
        let token = borrow_global_mut<Token>(signer::address_of(signer));
        let current_balance = table::borrow_mut(&mut token.balances, account).unwrap_or(0);
        assert!(current_balance >= amount, "Insufficient balance to burn tokens");
        table::add(&mut token.balances, account, current_balance - amount);
        token.total_supply = token.total_supply - amount;
    }

    public fun balance_of(account: address): u64 {
        let token = borrow_global<Token>(signer::address_of(account));
        table::borrow(&token.balances, account).unwrap_or(0)
    }

    public fun get_name(): vector<u8> {
        let token = borrow_global<Token>(signer::address_of(signer::address_of()));
        token.name
    }

    public fun get_symbol(): vector<u8> {
        let token = borrow_global<Token>(signer::address_of(signer::address_of()));
        token.symbol
    }
}

