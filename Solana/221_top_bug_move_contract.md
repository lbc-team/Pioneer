

# Top 10 Most Common Bugs In Your Aptos Move Contract

## We see these bugs over and over. Are they in your Move contracts too?



[The Move language is designed to make it difficult to write bugs,](https://www.zellic.io/blog/move-fast-and-break-things-pt-1) and does its job relatively well. There are certain bug classes that it completely eliminates. But as is the case with everything, it’s not impossible — and smart contract bugs almost always have the potential for negative financial impact.

After many Move audits, we’ve observed patterns of bugs emerging. So, the purpose of this blog post is to document the most common bug types we find and report to our clients.

>💡 We created a fictional, intentionally vulnerable [automated market maker (AMM)](https://www.gemini.com/en-US/cryptopedia/amm-what-are-automated-market-makers) protocol named “DonkeySwap” to demonstrate each bug type and describe how we would remediate each issue in this blog post.
>We’ve published the source code [here](https://github.com/Zellic/DonkeySwap) — go take a look!

Note that a code pattern may be considered a bug in only some contexts; for example, the ability to trigger an abort signifies a bug if it is necessary for execution to complete, but it is not always necessary for execution to complete. And, note that the impact of most bugs is usually context dependent.

* * *

## 1\. Lack of Generics Type Checking

As far as public functions are concerned in Move, generic types are another form of user input that must be checked for validity. We often find functions that take a generic type without

*   checking that the type is a valid/whitelisted type.
*   checking that the type is the expected type (e.g., not comparing to a stored type).

For example, [DonkeySwap](https://github.com/Zellic/DonkeySwap) (our example vulnerable protocol) is vulnerable to the following:

### DonkeySwap: Function `cancel_order` Does Not Check `BaseCoinType` Generic Type

*   Category: Coding Mistakes
*   Severity: Critical
*   Impact: Critical
*   Likelihood: High

#### Description

The `cancel_order` function does not assert that the inputted `BaseCoinType` generic type matches the `base_type` TypeInfo stored on the Order resource.

This function unlocks the liquidity for a given base coin type and returns the stored amount of the coin to the user:

```rust
public fun cancel_order<BaseCoinType>(
        user: &signer,
        order_id: u64
    ) acquires OrderStore, CoinStore {
        // [...]
        deposit_funds<BaseCoinType>(order_store, address_of(user), order.base);
        // [...]
}
```

#### Impact

An attacker could potentially drain liquidity from the AMM by placing a limit swap order and cancelling the order — passing the incorrect coin type.

The following proof of concept demonstrates an attacker’s ability to steal other users’ locked liquidity:

```rust
##[test(admin=@donkeyswap, user=@0x2222)]
fun WHEN_exploit_lack_of_type_checking(admin: &signer, user: &signer) acquires CoinCapability {
    let (my_usdc, order_id) = setup_with_limit_swap(admin, user, 1000000000000000);

    // let's say the admin deposits some ZEL

    mint<ZEL>(my_usdc, address_of(admin));
    let _admin_order_id = market::limit_swap<ZEL, USDC>(admin, my_usdc, 1000000000000000);

    // now, let's try stealing from the admin

    assert!(coin::balance<USDC>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);

    market::cancel_order<ZEL>(user, order_id); // ZEL is not the right coin type!

    assert!(coin::balance<USDC>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == my_usdc, ERR_UNEXPECTED_BALANCE); // received ZEL?
}
```

#### Recommendations

Add the following type-checking assertion to the `cancel_order` function:

```rust
assert!(order.base_type == type_info::type_of<BaseCoinType>(), ERR_ORDER_WRONG_COIN_TYPE);
```

## 2\. Unbounded Execution

Unbounded execution, also known as gas griefing/loop bombing, is a denial-of-service attack that exists when users can add iterations to looping code shared by multiple users (i.e., that can be executed by many users) without limit.

An attacker could potentially cause the loop to iterate enough times to run out of gas and abort. Depending on the context, this could potentially block critical functionality of the application.

### DonkeySwap: While Loop Bombing Blocks Some Functions

*   Category: Coding Mistakes
*   Severity: High
*   Impact: High
*   Likelihood: High

#### Description

The following loop iterates over every open order and could potentially be blocked by registering many orders:

```jsx
fun get_order_by_id(
    order_store: &OrderStore,
    order_id: u64
): (Option<Order>) {
    let i = 0;
    let len = vector::length(&order_store.orders);
    while (i < len) {
        let order = vector::borrow<Order>(&order_store.orders, i);
        if (order.id == order_id) {
            return option::some(*order)
        };
        i = i + 1;
    };

    return option::none<Order>()
}
```

There are a few of these while loops that iterate over every open order:

*   In the `get_order_by_id` function, which is called by `cancel_order` and `fulfill_order`.
*   In the `fulfill_orders` function, which is called by `add_liquidity`.
*   In the `drop_order` function, which is called by `cancel_order` and `execute_limit_order`.

#### Impact

Because each of these functions could be blocked by registering a large number of orders, an attacker could potentially

*   permanently block all users from cancelling or fulfilling limit orders, locking funds in the protocol permanently.
*   permanently block users from swapping, adding liquidity, and creating limit swap orders.

#### Recommendations

Avoid looping over every order and instead consider limiting the number of iterations each loop can do and structuring fees to incentivize users fulfilling each other’s orders.

## 3\. Improper Access Control

Accepting an `&signer` parameter is not sufficient for access control. Be sure to assert that the signer is the expected account.

### DonkeySwap: Improper `cancel_order` Function Access Control

*   Category: Coding Mistakes
*   Severity: Critical
*   Impact: Critical
*   Likelihood: High

#### Description

The `cancel_order` function does not assert that the signer is the owner of the order before cancelling the order and transferring assets to the caller:

```rust
public fun cancel_order<BaseCoinType>(
        user: &signer,
        order_id: u64
    ) acquires OrderStore, CoinStore {
        // [...]
        deposit_funds<BaseCoinType>(order_store, address_of(user), order.base);
        // [...]
}
```

#### Impact

An attacker could potentially drain all locked liquidity for any coin type by cancelling every user’s orders:

```rust
##[test(admin=@donkeyswap, user=@0x2222)]
fun WHEN_exploit_improper_access_control(admin: &signer, user: &signer) acquires CoinCapability {
    setup_with_liquidity(admin, user);

    // let's say the admin deposits some USDC

    let my_usdc = 1000000000000000;
    mint<USDC>(my_usdc, address_of(admin));
    let order_id = market::limit_swap<USDC, ZEL>(admin, my_usdc, 1000000000000000);

    // now, let's try stealing USDC from the admin

    assert!(coin::balance<USDC>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);

    market::cancel_order<USDC>(user, order_id); // order owned by admin, but signer is user!

    assert!(coin::balance<USDC>(address_of(user)) == my_usdc, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE); // received ZEL?
}
```

#### Recommendations

Add the following signer assertion to `cancel_order` to ensure the caller owns the order:

```rust
assert!(order.user_address == address_of(user), ERR_PERMISSION_DENIED);
```

## 4\. Price Oracle Manipulation

In 2022, according to [Chainalysis](https://blog.chainalysis.com/reports/oracle-manipulation-attacks-rising/), “DeFi protocols lost $403.2 million in 41 separate oracle manipulation attacks,” and Aptos Move does not mitigate this vulnerability category.

Vulnerabilities in this category all — one way or another — enable an attacker to influence the price oracle in a way that is profitable to the attacker and negatively impacts the victims.

For more information on the many ways oracles can be manipulated, see [samczsun’s blog post](https://samczsun.com/so-you-want-to-use-a-price-oracle/) about securely using a price oracle.

### DonkeySwap: Manipulable Price Oracle Enables Pool Draining

*   Category: Coding Mistakes
*   Severity: Critical
*   Impact: Critical
*   Likelihood: High

#### Description

DonkeySwap naïvely uses the liquidity ratio of tokens in a pair as a price oracle for determining how much liquidity token to send or receive for deposits and withdrawals.

#### Impact

An attacker could potentially drain the module by manipulating the ratio of tokens. The following is a proof of concept that demonstrates this:

Consider the prices on exchanges outside of DonkeySwap to be 10USDCperZELand10 USDC per ZEL and 10USDCperZELand1 USDC per HUGE.

>📌 Initial DonkeySwap state:
>*   1000 USDC
>*   1000 HUGE ($1 USDC per HUGE)
>*   100 ZEL ($10 USDC per ZEL)
>
>Initial attacker state:
>*   3000 USDC
>*   100 ZEL (worth $1000 USDC)

Steps:

1.  Deposit 3000 USDC. Receive 3000 DONK in exchange.

>📌 New DonkeySwap state:
>*   4000 USDC
>*   1000 HUGE ($4 USDC per HUGE)
>*   100 ZEL ($40 USDC per ZEL)
>
>New attacker state:
>*   3000 DONK
>*   100 ZEL (worth $4000 USDC)

2.  Deposit 100 ZEL. Receive 2000 DONK in exchange.

>📌 New DonkeySwap state:
>*   4000 USDC
>*   1000 HUGE ($4 USDC per HUGE)
>*   200 ZEL ($20 USDC per ZEL)
>
>New attacker state:
>*   5000 DONK

3.  Withdraw 3999 USDC using 3999 DONK.

📌 New DonkeySwap state:

*   1 USDC
*   1000 HUGE ($0.001 USDC per HUGE)
*   200 ZEL ($0.005 USDC per ZEL)

New attacker state:

*   1001 DONK
*   3999 USDC

4.  Withdraw 200 ZEL using 1 DONK. Withdraw 1000 HUGE using 1 DONK.

>📌 Final DonkeySwap state:
>*   1 USDC
>
>Final attacker state:
>*   999 DONK
>*   3999 USDC
>*   200 ZEL (worth $2000 USDC)
>*   1000 HUGE (worth $1000 USDC)

#### Recommendations

Use at least one external price oracle that can not be easily manipulated (e.g., averaged over time).

## 5\. Arithmetic Precision Errors

Precision-decreasing arithmetic operations round down, potentially causing protocols to underrepresent the result of such calculations.

Any calculations resulting in a nonintegral value between 0 and 1 will be represented as 0 by the u8, u64, and u128 types. This has implications that vary depending on the context.

When possible, [order the operations](https://blog.solidityscan.com/precision-loss-in-arithmetic-operations-8729aea20be9?gi=ab7d8f6cf2c6) in a way that minimizes precision loss.

### DonkeySwap: Rounding Error Enables Protocol Fee Bypass

*   Category: Coding Mistakes
*   Severity: Medium
*   Impact: Medium
*   Likelihood: High

#### Description

DonkeySwap calculates the appropriate protocol fees by taking a percentage of the order size in the following function:

```rust
##[query]
public fun calculate_protocol_fees(
    size: u64
): (u64) {
    return size * PROTOCOL_FEE_BPS / 10000
}
```

If the `size` argument is less than `10000 / PROTOCOL_FEE_BPS`, the fee will round down to 0.

#### Impact

Users can bypass fees when removing liquidity, swapping, or limit swapping by placing multiple small orders.

The following proof of concept demonstrates this impact with a single order costing zero protocol fees:

```rust
##[test(admin=@donkeyswap, user=@0x2222)]
fun WHEN_exploit_fees_rounding_down(admin: &signer, user: &signer) acquires CoinCapability {
    setup_with_liquidity(admin, user);

    let max_exploit_amount = (10000 / market::get_protocol_fees_bps()) - 1;
    assert!(market::calculate_protocol_fees(max_exploit_amount) == 0, ERR_UNEXPECTED_PROTOCOL_FEES);

    let my_usdc = max_exploit_amount;
    mint<USDC>(my_usdc, address_of(user));

    assert!(coin::balance<USDC>(address_of(user)) == my_usdc, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);

    let output = market::swap<USDC, ZEL>(user, my_usdc);

    assert!(coin::balance<USDC>(address_of(user)) == 0, ERR_UNEXPECTED_BALANCE);
    assert!(coin::balance<ZEL>(address_of(user)) == output, ERR_UNEXPECTED_BALANCE);
    assert!(output > 0, ERR_UNEXPECTED_BALANCE);

    assert!(market::get_protocol_fees<USDC>() == 0, ERR_UNEXPECTED_PROTOCOL_FEES);
    assert!(market::get_protocol_fees<ZEL>() == 0, ERR_UNEXPECTED_PROTOCOL_FEES); // no fees collected
}
```

#### Recommendations

Require that order sizes be higher than a minimum amount or require that calculated protocol fees are nonzero.

## 6\. Lack of Account Registration Check for Coin

The `aptos_framework::coin` module requires that a CoinStore exists on the target account when calling `coin::deposit` or `coin::withdraw`, so the account must be registered first with `coin::register` beforehand:

```rust
public fun register<CoinType>(account: &signer) {
    let account_addr = signer::address_of(account);
    // Short-circuit and do nothing if account is already registered for CoinType.
    if (is_account_registered<CoinType>(account_addr)) {
        return
    };
        // [...]
}
```

Note that the function returns early if the account is already registered. So, it’s safe to always register first before a withdraw or deposit operation.

When a signer is not available to register the account in the function, the code should check if the account has already been registered with `coin::is_account_registered` first, and fail if not.

### DonkeySwap: Unregistered Accounts Block `fulfill_order` Function

*   Category: Coding Mistakes
*   Severity: Medium
*   Impact: Medium
*   Likelihood: High

#### Description

The `execute_limit_order` function does not check whether the account that will receive the quote coin is registered for the coin.

#### Impact

The `execute_limit_order` function is called by `execute_order`, which is called by `fulfill_orders` — and `add_liquidity` calls that function, so if an attacker were to create a fulfillable order that targets an account that is not registered for the quote coin, it would be impossible to swap or add liquidity.

The following proof of concept demonstrates this:

```rust
##[test(admin=@donkeyswap, user=@0x2222, attacker=@0x3333)]
##[expected_failure(abort_code=393221, location=coin)] // ECOIN_STORE_NOT_PUBLISHED
fun WHEN_exploit_lack_of_account_registered_check(admin: &signer, user: &signer, attacker: &signer) acquires CoinCapability {
    account::create_account_for_test(address_of(attacker));
    setup(admin, user);
    assert!(!coin::is_account_registered<ZEL>(address_of(attacker)), ERR_UNEXPECTED_ACCOUNT);

    // create limit order from attacker's account
    let my_usdc = 10_0000; // $10 USDC
    mint<USDC>(my_usdc, address_of(attacker));
    market::limit_swap<USDC, ZEL>(user, my_usdc, 0);

    // try to add liquidity from user's account, which tries to fulfill the order
    mint<USDC>(my_usdc, address_of(user));
    market::add_liquidity<USDC>(user, my_usdc); // this should abort
}
```

Note that — while `add_liquidity` and `remove_liquidity` also do not check if the account is registered — the operations would immediately revert, acting only as a self–denial-of-service attack.

#### Recommendations

Add the following two lines to the `limit_swap` function to forcefully register the accounts:

```rust
coin::register<BaseCoinType>(user);
coin::register<QuoteCoinType>(user);
```

Note that the `coin::register` function automatically skips registration if the account is already registered.

## 7\. Arithmetic Errors and Inconsistencies

Aptos Move implements u8, u16, and u64 integer types. So, in many of our audits, we see custom types that add support for floating-point or fixed-point decimals, signed integers, or other widths. It is important to be aware that custom data sizes may have different overflow/underflow behavior from the built-in unsigned integer types.

Ensure that code that should not revert cannot experience an arithmetic error such as divide-by-zero, overflow, and underflow errors because such errors would be a denial of service.

### DonkeySwap: Calculations on High Decimal Coins May Cause Overflow

*   Category: Coding Mistakes
*   Severity: Medium
*   Impact: High
*   Likelihood: Low

#### Description

An attacker could potentially create an order with a size large enough to cause an overflow abort in the following places:

*   `calculate_lp_coin_amount_internal`:
    
    ```rust
    size * get_usd_value_internal(order_store, type)
    ```
    
*   `calculate_protocol_fees`:
    
    ```rust
    size * PROTOCOL_FEE_BPS / 10000
    ```
    

#### Impact

Because `add_liquidity` always attempts to fulfill orders, if a calculation overflows when fulfilling the order, the `add_liquidity` request will fail.

The following proof of concept demonstrates `add_liquidity` being blocked by the arithmetic error:

```rust
##[test(admin=@donkeyswap, user=@0x2222)]
##[expected_failure(arithmetic_error, location=market)]
fun WHEN_exploit_overflow_revert(admin: &signer, user: &signer) acquires CoinCapability {
    setup_with_liquidity(admin, user);

    // add extra DONK liquidity
    let admin_donk = 1000000000000000;
    mint<DONK>(admin_donk, address_of(admin));
    market::admin_deposit_donk(admin, admin_donk);

    // place a reasonable order size for HUGE
    let user_huge = 1000000000000000;
    mint<HUGE>(user_huge, address_of(user));
    market::limit_swap<HUGE, ZEL>(user, user_huge, 0);

    // inadvertently fulfill limit order
    let admin_zel = 10000;
    mint<ZEL>(admin_zel, address_of(admin));
    market::add_liquidity<ZEL>(admin, admin_zel);
}
```

#### Recommendations

Cast operands to u128 before multiplication and ensure that coins that can reasonably cause overflow do not get whitelisted.

## 8\. Improper Resource Management

In the [Aptos Move development model](https://aptos.dev/guides/move-guides/move-on-aptos/#comparison-to-other-vms), data is intended to be stored in a resource moved to the owner’s account, rather than a universal resource storage on the module’s account.

Per the [Aptos Move documentation on data ownership](https://aptos.dev/guides/move-guides/move-on-aptos/#data-ownership):

> In Move, data can be stored within the module owner's account, but that creates the issue of ownership ambiguity and implies two issues:
> 
> 1.  It makes ownership ambiguous as the asset has no resource associated with the owner.
> 2.  The module creator takes responsibility for the lifetime of that resources (e.g., rent, reclamation, and so forth).
> 
> On the first point, by placing assets within trusted resources within an account, the owner can ensure that even a maliciously programmed module will be unable to modify those assets. In Move, we can program a standard orderbook structure and interface that would let applications built on top be unable to gain backdoor access to an account or its orderbook entries.

Simply put, designing this way is a good practice so that accounting (resource ownership) is per user.

### DonkeySwap: Orders Stored on Global Store Instead of Owner

*   Category: Business Logic
*   Severity: Informational
*   Impact: N/A
*   Likelihood: N/A

#### Description

DonkeySwap puts the Order resources in the `orders` vector, which is stored on `@donkeyswap`:

```rust
struct OrderStore has key {
    current_id: u64,
    orders: vector<Order>,
    locked: Table<TypeInfo, u64>,
    liquidity: Table<TypeInfo, u64>,
    decimals: Table<TypeInfo, u8>
}
```

#### Impact

Per the [Aptos Move documentation on data ownership](https://aptos.dev/guides/move-guides/move-on-aptos/#data-ownership), this is bad practice and may enable exploitability of other vulnerabilities.

For example, if the global vector of `orders` grows too large and iterating over it causes an out-of-gas abort, it will affect all users; but if each user had an `orders` vector, adding too many orders would only be a self–denial-of-service attack.

#### Recommendations

In general, we recommend storing resources within the users’ accounts as it is considered a best practice in Move.

## 9\. Business Logic Flaws

Another one of the most common type of flaws we report when auditing protocols written in Move are business logic flaws. These are flaws in the underlying design of a protocol — as opposed to errors in the code — such as misaligned incentives, centralization risks, incorrect order of operations, logic flaws (e.g., double spending), and so forth.

Though this is a broad category of bugs, business logic is highly context dependent, so we grouped most of these types of bugs under this section.

### DonkeySwap: Lack of LP Incentives

*   Category: Business Logic
*   Severity: High
*   Impact: High
*   Likelihood: High

#### Description

Users are not incentivized to provide liquidity to the AMM in any way.

#### Impact

Upon deploying the DonkeySwap, it is unlikely that users would provide liquidity to the protocol because they have no reason to.

#### Recommendations

Typically, AMM protocols collect fees from swap or liquidity-changing operations to use to incentivize providing liquidity. We recommend implementing a fee structure that incentivizes adding liquidity and optionally disincentivizes removing liquidity.

## 10\. Use of Incorrect Standard Function

In the Move stdlib, certain functions operate similarly: the correct function needs to be used at the right time to avoid a runtime abort (where the compiler/type checking does not catch these errors in advance).

For example (disclaimer: this is not a wholly inclusive list),

*   `option::borrow_mut<Element>(t: &mut Option<Element>)`
    
    `option::extract<Element>(t: &mut Option<Element>)`
    
*   `table::add<K: copy + drop, V>(table: &mut Table<K, V>, key: K, val: V)`
    
    `table::upsert<K: copy + drop, V: drop>(table: &mut Table<K, V>, key: K, value: V)`
    
*   `table_with_length::add<K: copy + drop, V>(table: &mut Table<K, V>, key: K, val: V)`
    
    `table_with_length::upsert<K: copy + drop, V: drop>(table: &mut Table<K, V>, key: K, value: V)`
    

### DonkeySwap: `fulfill_orders` Borrows After Extracting

*   Category: Coding Mistakes
*   Severity: Medium
*   Impact: Medium
*   Likelihood: Low

#### Description

The `fulfill_orders` function — which is automatically called when adding liquidity — borrows the order from an Option to fetch the order ID after extracting the Order upon successful order execution:

```jsx
let order_option = get_next_order(&mut orders);
if (option::is_none(&order_option)) {
    break
};
let status = execute_order<CoinType>(order_store, &option::extract(&mut order_option));
if (status == 0) {
    vector::push_back(&mut successful_order_ids, option::borrow(&mut order_option).id);
};
```

However, the Order will not be present to borrow inside of the Option after extracting.

#### Impact

If any limit order successfully fulfills during a `fulfill_orders` call, the transaction will abort, potentially preventing users from being able to add liquidity.

#### Recommendations

Extract the order from the Option once or borrow it twice.

Additionally, ensure that this code has test coverage; had the `status == 0` been reached in any tests, this issue would have been caught.

* * *

## Conclusion

Move language is designed to reduce the number of bug types, but bugs can still exist. We have identified the most common bug types and how to remediate them. Auditing your code is essential to protect your smart contracts from financial loss.


原文链接：https://www.zellic.io/blog/top-10-aptos-move-bugs