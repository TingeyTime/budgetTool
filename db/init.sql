-- Exit on error
\set ON_ERROR_STOP true

-- Start a transaction
BEGIN;

-- Set timezone to UTC for consistency
SET TIME ZONE 'UTC';

--------------------------------------------------------------------------------
-- ENUMERATED TYPES
--------------------------------------------------------------------------------

CREATE TYPE account_type AS ENUM (
    'checking',
    'savings',
    'credit_card',
    'cash',
    'investment',
    'loan',
    'other'
);

CREATE TYPE transaction_type AS ENUM (
    'expense',
    'income',
    'transfer_out',
    'transfer_in'
);

--------------------------------------------------------------------------------
-- TABLES
--------------------------------------------------------------------------------

-- Accounts Table: Stores information about different financial accounts
CREATE TABLE IF NOT EXISTS accounts (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL UNIQUE,
    account_type account_type NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD', -- ISO 4217 currency code
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
ALTER TABLE accounts ADD CONSTRAINT chk_account_name_not_empty CHECK (TRIM(account_name) <> '');


CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
ALTER TABLE categories ADD CONSTRAINT chk_category_name_not_empty CHECK (TRIM(category_name) <> '');


CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    transaction_type transaction_type NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    merchant_name VARCHAR(150),
    notes TEXT,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE transactions ADD CONSTRAINT chk_description_not_empty CHECK (TRIM(description) <> '');
ALTER TABLE transactions ADD CONSTRAINT chk_amount_positive CHECK (amount >= 0); -- Ensure amount is positive. The 'transaction_type' will determine if it's an inflow or outflow.

-- Budget Periods Table: Defines periods for budgets (e.g., Monthly Jan 2024, Quarterly Q1 2024)
CREATE TABLE IF NOT EXISTS budget_periods (
    budget_period_id SERIAL PRIMARY KEY,
    period_name VARCHAR(100) NOT NULL UNIQUE, -- e.g., "May 2025", "Q2 2025"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_period_dates CHECK (end_date >= start_date)
);
ALTER TABLE budget_periods ADD CONSTRAINT chk_period_name_not_empty CHECK (TRIM(period_name) <> '');


-- Budgets Table: Defines budget allocations for categories within specific periods
CREATE TABLE IF NOT EXISTS budgets (
    budget_id SERIAL PRIMARY KEY,
    budget_period_id INTEGER NOT NULL REFERENCES budget_periods(budget_period_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    allocated_amount DECIMAL(19, 4) NOT NULL,
    notes TEXT, -- Optional notes for this specific budget item
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Ensure a category is budgeted only once per period
    UNIQUE (budget_period_id, category_id),
    CONSTRAINT chk_allocated_amount_positive CHECK (allocated_amount >= 0)
);

--------------------------------------------------------------------------------
-- INDEXES
--------------------------------------------------------------------------------

-- Indexes for frequently queried columns

-- Accounts
CREATE INDEX IF NOT EXISTS idx_accounts_account_type ON accounts(account_type);

-- Categories
CREATE INDEX IF NOT EXISTS idx_categories_parent_category_id ON categories(parent_category_id);

-- Transactions
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_date ON transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_type ON transactions(transaction_type);
-- CREATE INDEX IF NOT EXISTS idx_transactions_linked_transaction_id ON transactions(linked_transaction_id);


-- Budget Periods
CREATE INDEX IF NOT EXISTS idx_budget_periods_start_date ON budget_periods(start_date);
CREATE INDEX IF NOT EXISTS idx_budget_periods_end_date ON budget_periods(end_date);

-- Budgets
CREATE INDEX IF NOT EXISTS idx_budgets_budget_period_id ON budgets(budget_period_id);
CREATE INDEX IF NOT EXISTS idx_budgets_category_id ON budgets(category_id);

--------------------------------------------------------------------------------
-- FUNCTIONS FOR UPDATING `updated_at` TIMESTAMPS
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------
-- TRIGGERS to automatically update `updated_at` columns
--------------------------------------------------------------------------------

CREATE TRIGGER set_timestamp_accounts
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_categories
BEFORE UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_transactions
BEFORE UPDATE ON transactions
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_budget_periods
BEFORE UPDATE ON budget_periods
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_budgets
BEFORE UPDATE ON budgets
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

--------------------------------------------------------------------------------
-- Initial Data
--------------------------------------------------------------------------------

INSERT INTO accounts (account_name, account_type, currency) VALUES
('Main Checking', 'checking', 'USD'),
('Primary Savings', 'savings', 'USD'),
('Visa Rewards Card', 'credit_card', 'USD');

INSERT INTO categories (category_name, notes) VALUES
('Groceries', 'Food and household supplies'),
('Salary', 'Regular income from employment'),
('Utilities', 'Electricity, water, gas, internet'),
('Rent', 'Monthly rent payment'),
('Transportation', 'Gas, public transport, ride-sharing'),
('Dining Out', 'Restaurants and cafes'),
('Entertainment', 'Movies, concerts, hobbies'),
('Healthcare', 'Doctor visits, prescriptions'),
('Transfer', 'Movement of funds between own accounts'); -- Special category for transfers

-- Example: Create a budget period for the current month
-- This would typically be handled by your application logic dynamically
-- For May 2025 (as an example, adjust if running at a different time)
INSERT INTO budget_periods (period_name, start_date, end_date)
VALUES
('May 2025', '2025-05-01', '2025-05-31');

-- Example: Budget for Groceries in May 2025
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT
    (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'),
    (SELECT category_id FROM categories WHERE category_name = 'Groceries'),
    300.00;

COMMIT;
\echo 'Database initialization script completed successfully.'