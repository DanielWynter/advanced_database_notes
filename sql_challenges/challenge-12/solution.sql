-- ============================================================
-- EXERCISE 1: Manual transaction (warm-up)
-- ============================================================
-- Transfer $50 from Charlie (3) to Alice (1) using BEGIN / COMMIT manually.
-- Before: verify balances. After COMMIT: verify again.

-- Your SQL here:
-- 1. Verify balances before
SELECT * FROM accounts WHERE account_id IN (1, 3);

-- 2. Execute transfer
BEGIN;

UPDATE accounts SET balance = balance - 50 WHERE account_id = 3;
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;

COMMIT;

-- 3. Verify balances after
SELECT * FROM accounts WHERE account_id IN (1, 3);

-- ============================================================
-- EXERCISE 2: Catch yourself with ROLLBACK
-- ============================================================
-- Start a transfer of $10,000 from Bob (2) to Charlie (3).
-- Before committing, check the balances. Does Bob have enough?
-- Use ROLLBACK to undo. Verify balances restored.

-- Your SQL here:

-- 1. Check balances before the attempt
SELECT * FROM accounts WHERE account_id IN (2, 3);

-- 2. Start the transaction
BEGIN;

-- Attempt to transfer $10,000 from Bob to Charlie
UPDATE accounts SET balance = balance - 10000 WHERE account_id = 2;
UPDATE accounts SET balance = balance + 10000 WHERE account_id = 3;

-- 3. Check balances (Notice Bob's balance would be negative if not for the CHECK constraint, 
-- or if the constraint is deferred, it shows the pending state)
SELECT * FROM accounts WHERE account_id IN (2, 3);

-- 4. Undo the changes
ROLLBACK;

-- 5. Verify balances are restored to original values
SELECT * FROM accounts WHERE account_id IN (2, 3);

-- ============================================================
-- EXERCISE 3: SAVEPOINT checkpoint
-- ============================================================
-- You need to:
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit

-- Your SQL here:

-- 1. Add $25 to Alice
BEGIN;
UPDATE accounts SET balance = balance + 25 WHERE account_id = 1;

-- 2. Set a savepoint
SAVEPOINT after_alice_update;

-- 3. Deduct $25 from Charlie (The Mistake)
UPDATE accounts SET balance = balance - 25 WHERE account_id = 3;

-- 4. Rollback to savepoint (Undoes the Charlie deduction only)
ROLLBACK TO SAVEPOINT after_alice_update;

-- 5. Deduct $25 from Bob instead
UPDATE accounts SET balance = balance - 25 WHERE account_id = 2;

-- 6. Finalize
COMMIT;

-- Verify final results
SELECT * FROM accounts ORDER BY account_id;

-- ============================================================
-- EXERCISE 4: Write your own stored procedure
-- ============================================================
-- Create a procedure called deposit_funds(p_account_id, p_amount)
-- It should:
-- 1. Validate that p_amount > 0 (raise error if not)
-- 2. Add p_amount to the account balance
-- 3. COMMIT on success
-- 4. ROLLBACK + re-raise on any error
-- Test it with: EXEC deposit_funds(3, 75);

-- Your SQL here:
CREATE OR REPLACE PROCEDURE deposit_funds (
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    -- 1. Validate that p_amount > 0
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Deposit amount must be greater than zero.');
    END IF;

    -- 2. Add p_amount to the account balance
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    -- Check if the account actually exists
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Account ID not found.');
    END IF;

    -- 3. COMMIT on success
    COMMIT;

EXCEPTION
    -- 4. ROLLBACK + re-raise on any error
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Test the procedure
EXEC deposit_funds(3, 75);

-- Verify the update
SELECT * FROM accounts WHERE account_id = 3;