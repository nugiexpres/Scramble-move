module MeatToken {
    use 0x1::Signer;
    use 0x1::Coin;
    use 0x1::Vector;

    struct Token has store {
        balance: u64,
    }

    public fun mint(account: &signer, amount: u64) {
        let account_address = Signer::address_of(account);
        let mut token = borrow_global_mut<Token>(account_address);
        token.balance = token.balance + amount;
    }

    public fun burn(account: &signer, amount: u64) {
        let account_address = Signer::address_of(account);
        let mut token = borrow_global_mut<Token>(account_address);
        assert!(token.balance >= amount, 100); // Custom error for insufficient balance
        token.balance = token.balance - amount;
    }

    public fun balance_of(account: &signer): u64 {
        let account_address = Signer::address_of(account);
        let token = borrow_global<Token>(account_address);
        token.balance
    }

    public fun name(): vector<u8> {
        return b"Meat".to_vec();
    }

    public fun symbol(): vector<u8> {
        return b"M".to_vec();
    }
}
