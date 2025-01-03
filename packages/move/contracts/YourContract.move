module YourContract {
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Coin;

    struct YourContract has store {
        owner: address,
        greeting: vector<u8>,
        premium: bool,
        total_counter: u64,
        user_greeting_counter: map<address, u64>,
    }

    public fun initialize(owner: address) {
        let contract = YourContract {
            owner,
            greeting: b"Building Unstoppable Move".to_vec(),
            premium: false,
            total_counter: 0,
            user_greeting_counter: Map::empty<address, u64>(),
        };
        move_to<YourContract>(owner, contract);
    }

    public fun set_greeting(account: &signer, new_greeting: vector<u8>, value: u64) {
        let sender = Signer::address_of(account);
        let mut contract = borrow_global_mut<YourContract>(sender);

        // Setting the new greeting
        contract.greeting = new_greeting;
        contract.total_counter = contract.total_counter + 1;
        let current_count = Map::get_mut(&mut contract.user_greeting_counter, sender);
        match current_count {
            Some(count) => *count = *count + 1,
            None => Map::insert(&mut contract.user_greeting_counter, sender, 1),
        }

        // Handling premium status based on value
        contract.premium = if (value > 0) { true } else { false };

        // Trigger the GreetingChange event
        GreetingChange(sender, new_greeting, contract.premium, value);
    }

    public fun withdraw(account: &signer) {
        let sender = Signer::address_of(account);
        let contract = borrow_global<YourContract>(sender);
        assert!(sender == contract.owner, 1); // Custom error code for unauthorized access

        Coin::transfer(account, contract.balance);
    }

    public fun balance_of(account: &signer): u64 {
        let sender = Signer::address_of(account);
        let contract = borrow_global<YourContract>(sender);
        contract.balance
    }

    public fun GreetingChange(sender: address, new_greeting: vector<u8>, premium: bool, value: u64) {
        // This function emits an event for GreetingChange (for tracking)
    }

    // This is the "receive" function in Solidity, automatically called when the contract receives funds
    public fun receive(account: &signer, amount: u64) {
        let sender = Signer::address_of(account);
        let contract = borrow_global_mut<YourContract>(sender);
        Coin::transfer(account, amount);
    }
}
