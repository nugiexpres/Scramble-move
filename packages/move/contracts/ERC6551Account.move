module ERC6551Account {
    use aptos::account;
    use aptos::crypto::{self, ed25519, Signature};
    use aptos::table;
    use aptos::vector;
    use aptos::string;

    struct Token has store {
        token_contract: address,
        token_id: u64,
    }

    struct Account has store {
        owner: address,
        nonce: u64,
        token: Token,
    }

    // Initialize the account
    public fun initialize(account: &signer, token_contract: address, token_id: u64) {
        let owner_address = signer::address_of(account);
        let token = Token {
            token_contract,
            token_id,
        };
        let account_struct = Account {
            owner: owner_address,
            nonce: 0,
            token,
        };
        move_to(account, account_struct);
    }

    // Execute a function call (simplified, no external call as in Solidity)
    public fun execute_call(account: &signer, to: address, value: u64, data: vector<u8>) {
        let account_struct = borrow_global_mut<Account>(signer::address_of(account));
        
        // Ensure the caller is the owner of the account
        assert!(account_struct.owner == signer::address_of(account), 100, "Not token owner");

        // Increment nonce after successful execution
        account_struct.nonce = account_struct.nonce + 1;
    }

    // Return the token details (contract address and token id)
    public fun get_token(account: &signer): (address, u64) {
        let account_struct = borrow_global<Account>(signer::address_of(account));
        (account_struct.token.token_contract, account_struct.token.token_id)
    }

    // Return the owner of the token (from the associated ERC721 contract)
    public fun get_owner(account: &signer): address {
        let account_struct = borrow_global<Account>(signer::address_of(account));
        account_struct.owner
    }

    // Nonce tracking
    public fun get_nonce(account: &signer): u64 {
        let account_struct = borrow_global<Account>(signer::address_of(account));
        account_struct.nonce
    }

    // Signature verification (simplified)
    public fun is_valid_signature(account: &signer, hash: vector<u8>, signature: vector<u8>): bool {
        let account_struct = borrow_global<Account>(signer::address_of(account));
        let public_key = account_struct.owner;
        let is_valid = crypto::verify_signature(public_key, hash, signature);
        is_valid
    }
}
