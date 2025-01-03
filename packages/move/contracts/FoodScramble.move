module FoodScramble {
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Hash;
    use 0x1::Coin;
    use 0x1::Account;

    struct Box has store {
        id: u64,
        type_grid: vector<u8>,
        ingredient_type: u64,
        number_of_players: u64,
    }

    struct BreadToken has store {
        balance: u64,
    }

    struct MeatToken has store {
        balance: u64,
    }

    struct LettuceToken has store {
        balance: u64,
    }

    struct CoinToken has store {
        balance: u64,
    }

    struct FoodNFT has store {
        balance: u64,
    }

    public fun generate_random_number(account: &signer): u64 {
        let block_time = move_to_bytes(&block_timestamp());
        let account_address = Signer::address_of(account);
        let hash_input = Vector::empty<u8>();

        Vector::append(&mut hash_input, block_time);
        Vector::append(&mut hash_input, account_address);

        let random_hash = Hash::sha3_256(hash_input);
        let random_number = u64::from_bytes(&random_hash);
        return random_number % 5;
    }

    public fun move_player(account: &signer, grid: &mut vector<Box>, player_position: &mut u64) {
        let random_number = generate_random_number(account);

        // Optimize player movement and reduce state changes
        let new_position = *player_position + random_number;
        if (new_position >= 20) {
            *player_position = 0;
            grid[0].number_of_players = grid[0].number_of_players + 1;
        } else {
            *player_position = new_position;
            grid[*player_position].number_of_players = grid[*player_position].number_of_players + 1;
        }
    }

    public fun assert_player_has_ingredient(account: &signer, ingredient_type: u64) {
        let has_ingredient = check_ingredient(account, ingredient_type);
        if (!has_ingredient) {
            abort 100;  // Custom error code
        }
    }

    public fun check_ingredient(account: &signer, ingredient_type: u64): bool {
        // Logic to check if the account has the required ingredient
        return true;  // Placeholder logic for now
    }

    public fun buy_ingredient(account: &signer, grid: &vector<Box>, player_position: u64) {
        let current_spot = &grid[player_position];
        
        if (current_spot.ingredient_type == 0) {
            BreadToken::mint(account, 10);
        } else if (current_spot.ingredient_type == 1) {
            MeatToken::mint(account, 10);
        } else if (current_spot.ingredient_type == 2) {
            LettuceToken::mint(account, 10);
        } else if (current_spot.ingredient_type == 3) {
            CoinToken::mint(account, 10);
        }
    }

    // Faucet for testing
    public fun faucet(account: &signer) {
        BreadToken::mint(account, 10);
        MeatToken::mint(account, 10);
        LettuceToken::mint(account, 10);
        CoinToken::mint(account, 10);
    }

    // Main Game Logic
    public fun createTokenBoundAccount(
        account: &signer,
        registry: &mut ERC6551Registry,
        implementation: address,
        chain_id: u64,
        token_contract: address,
        token_id: u64,
        salt: u64,
        init_data: vector<u8>,
    ) {
        let new_tba = registry.createAccount(implementation, chain_id, token_contract, token_id, salt, init_data);
        // Linking the TBA to the player account
        let player_address = Signer::address_of(account);
        let mut tba_list = Vector::empty<address>();
        Vector::push_back(&mut tba_list, new_tba);

        // Adding player to the grid (increase player count)
        grid[0].number_of_players = grid[0].number_of_players + 1;
    }

    public fun get_grid(grid: &vector<Box>) {
        // Fetch the grid
        return grid;
    }

    public fun get_my_foods(account: &signer, hamburger: &FoodNFT) {
        let player_address = Signer::address_of(account);
        return hamburger.balance;  // Placeholder for getting player's food
    }

    // Main game loop
    public fun main_game(account: &signer, grid: &mut vector<Box>, player_position: &mut u64, hamburger: &FoodNFT, bread: &BreadToken, meat: &MeatToken, lettuce: &LettuceToken, tomato: &CoinToken) {
        move_player(account, grid, player_position); // Random player movement
        buy_ingredient(account, grid, *player_position); // Buy ingredients if needed

        // If all ingredients are available, create the food item
        if (bread.balance > 0 && meat.balance > 0 && lettuce.balance > 0 && tomato.balance > 0) {
            mint_food(account, hamburger, bread, meat, lettuce, tomato); // Mint food NFT
        }
    }

    public fun mint_food(account: &signer, hamburger: &FoodNFT, bread: &BreadToken, meat: &MeatToken, lettuce: &LettuceToken, tomato: &CoinToken) {
        // Burn ingredients and mint food
        bread.balance = bread.balance - 1;
        meat.balance = meat.balance - 1;
        lettuce.balance = lettuce.balance - 1;
        tomato.balance = tomato.balance - 1;

        hamburger.balance = hamburger.balance + 1; // Mint the food NFT
    }
}
