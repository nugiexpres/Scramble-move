module Ingredient {
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Coin;
    use 0x1::Account;

    struct Ingredient has store {
        bread: u64,
        meat: u64,
        lettuce: u64,
        tomato: u64,
    }

    public fun mint_ingredient(account: &signer, ingredient_id: u64) {
        let account_address = Signer::address_of(account);
        let mut ingredients = borrow_global_mut<Ingredient>(account_address);

        // Mint the specific ingredient based on the ID
        if (ingredient_id == 1) {
            ingredients.bread = ingredients.bread + 1;
        } else if (ingredient_id == 2) {
            ingredients.meat = ingredients.meat + 1;
        } else if (ingredient_id == 3) {
            ingredients.lettuce = ingredients.lettuce + 1;
        } else if (ingredient_id == 4) {
            ingredients.tomato = ingredients.tomato + 1;
        } else {
            abort 100;  // Custom error code for invalid ingredient ID
        }
    }

    public fun get_ingredient_balance(account: &signer): (u64, u64, u64, u64) {
        let account_address = Signer::address_of(account);
        let ingredients = borrow_global<Ingredient>(account_address);
        return (ingredients.bread, ingredients.meat, ingredients.lettuce, ingredients.tomato);
    }

    // Faucet function for testing, giving a set number of each ingredient to an account
    public fun faucet(account: &signer) {
        mint_ingredient(account, 1);  // Bread
        mint_ingredient(account, 2);  // Meat
        mint_ingredient(account, 3);  // Lettuce
        mint_ingredient(account, 4);  // Tomato
    }
}
