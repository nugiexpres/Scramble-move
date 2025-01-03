module FoodNFT {
    use aptos::account;
    use aptos::table;
    use aptos::vector;
    use aptos::crypto::sha3_256;
    use aptos::string;
    use aptos::debug;

    // Structure for storing each NFT (FoodScramble NFT)
    struct NFT has store {
        id: u64,
        token_uri: vector<u8>,
    }

    // Structure to hold the collection of NFTs for each user
    struct NFTCollection has store {
        mynfts: table::Table<u64, NFT>,  // NFTs owned by the user
        my_foods: table::Table<u64, NFT>,  // Food NFTs owned by the user
    }

    // Initialize token name and symbol
    const TOKEN_NAME: vector<u8> = vector::from_bytes(b"Food Scramble NFT");
    const TOKEN_SYMBOL: vector<u8> = vector::from_bytes(b"FSN");

    // Function to mint a new "Chef" NFT
    public fun mint_chef(
        account: &signer,
        token_uri: vector<u8>
    ): u64 {
        let token_id = generate_token_id(account);
        let nft = NFT { id: token_id, token_uri };

        // Add the NFT to the user's collection (mynfts)
        let collection = borrow_global_mut<NFTCollection>(signer::address_of(account));
        table::add(&mut collection.mynfts, token_id, nft);

        return token_id;
    }

    // Function to mint a new "Food" NFT
    public fun mint_food(
        account: &signer,
        token_uri: vector<u8>
    ): u64 {
        let token_id = generate_token_id(account);
        let nft = NFT { id: token_id, token_uri };

        // Add the NFT to the user's collection (my_foods)
        let collection = borrow_global_mut<NFTCollection>(signer::address_of(account));
        table::add(&mut collection.my_foods, token_id, nft);

        return token_id;
    }

    // Function to get all NFTs owned by a user
    public fun get_my_nfts(account: &signer): vector<u64> {
        let collection = borrow_global<NFTCollection>(signer::address_of(account));
        let mut mynfts_list: vector<u64> = vector::empty();
        
        // Iterate through the user's mynfts table and add the IDs to the list
        let mut it = table::iter(&collection.mynfts);
        while let Some((key, _)) = it.next() {
            vector::push_back(&mut mynfts_list, key);
        }
        
        mynfts_list
    }

    // Function to get all food NFTs owned by a user
    public fun get_my_foods(account: &signer): vector<u64> {
        let collection = borrow_global<NFTCollection>(signer::address_of(account));
        let mut myfoods_list: vector<u64> = vector::empty();

        // Iterate through the user's my_foods table and add the IDs to the list
        let mut it = table::iter(&collection.my_foods);
        while let Some((key, _)) = it.next() {
            vector::push_back(&mut myfoods_list, key);
        }

        myfoods_list
    }

    // Helper function to generate a new token ID (similar to _tokenIds.increment())
    fun generate_token_id(account: &signer): u64 {
        let address = signer::address_of(account);
        // Use the address and some form of hash to generate a unique token ID
        let address_hash = sha3_256(&vector::from_bytes(address));
        let token_id = u64::from_bytes(&address_hash[0..8]); // Convert the first 8 bytes to a u64 value
        token_id
    }

    // Entry point to initialize the NFT collection for a user
    public fun initialize(account: &signer) {
        // Create the initial NFTCollection for the user
        let collection = NFTCollection {
            mynfts: table::Table::empty<u64, NFT>(),
            my_foods: table::Table::empty<u64, NFT>(),
        };
        move_to(account, collection);
    }
}
