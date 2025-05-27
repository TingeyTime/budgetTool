-- Exit on error
\set ON_ERROR_STOP true

-- Start a transaction
BEGIN;

-- Set timezone to UTC for consistency
SET TIME ZONE 'UTC';

-- For PostgreSQL versions older than 13, you might need pgcrypto for gen_random_uuid()
-- or uuid-ossp for uuid_generate_v4(). gen_random_uuid() is core in PG13+.
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- Uncomment if needed

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
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_name VARCHAR(100) NOT NULL UNIQUE,
    account_type account_type NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD', -- ISO 4217 currency code
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
ALTER TABLE accounts ADD CONSTRAINT chk_account_name_not_empty CHECK (TRIM(account_name) <> '');


CREATE TABLE IF NOT EXISTS categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
ALTER TABLE categories ADD CONSTRAINT chk_category_name_not_empty CHECK (TRIM(category_name) <> '');


CREATE TABLE IF NOT EXISTS transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    transaction_type transaction_type NOT NULL,
    category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    merchant_name VARCHAR(150),
    notes TEXT,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE transactions ADD CONSTRAINT chk_description_not_empty CHECK (TRIM(description) <> '');
ALTER TABLE transactions ADD CONSTRAINT chk_amount_positive CHECK (amount >= 0);

-- Budget Periods Table: Defines periods for budgets (e.g., Monthly Jan 2024, Quarterly Q1 2024)
CREATE TABLE IF NOT EXISTS budget_periods (
    budget_period_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    budget_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_period_id UUID NOT NULL REFERENCES budget_periods(budget_period_id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    allocated_amount DECIMAL(19, 4) NOT NULL,
    notes TEXT, -- Optional notes for this specific budget item
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (budget_period_id, category_id),
    CONSTRAINT chk_allocated_amount_positive CHECK (allocated_amount >= 0)
);

--------------------------------------------------------------------------------
-- INDEXES
--------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_accounts_account_type ON accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_categories_parent_category_id ON categories(parent_category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_date ON transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_type ON transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_budget_periods_start_date ON budget_periods(start_date);
CREATE INDEX IF NOT EXISTS idx_budget_periods_end_date ON budget_periods(end_date);
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

-- Accounts (account_id will be auto-generated UUID by default)
INSERT INTO accounts (account_name, account_type, currency) VALUES
('Main Checking', 'checking', 'USD'),
('Primary Savings', 'savings', 'USD'),
('Visa Rewards Card', 'credit_card', 'USD'),
('Emergency Fund', 'savings', 'USD'),
('Vacation Fund', 'savings', 'USD'),
('Auto Loan - Honda Civic', 'loan', 'USD');

-- Categories (category_id will be auto-generated UUID by default)
INSERT INTO categories (category_name, notes) VALUES
('Groceries', 'Food and household supplies'),
('Salary', 'Regular income from employment'),
('Utilities', 'Electricity, water, gas, internet'),
    ('Electricity', 'Monthly electricity bill'),
    ('Water', 'Monthly water bill'),
    ('Internet', 'Monthly internet bill'),
('Rent', 'Monthly rent payment'),
('Transportation', 'Gas, public transport, ride-sharing'),
    ('Gasoline', 'Fuel for car'),
    ('Public Transport', 'Bus/train fare'),
('Dining Out', 'Restaurants and cafes'),
('Entertainment', 'Movies, concerts, hobbies'),
    ('Movies', 'Cinema tickets, streaming subscriptions'),
    ('Hobbies', 'Supplies and fees for hobbies'),
('Healthcare', 'Doctor visits, prescriptions'),
('Transfer', 'Movement of funds between own accounts'),
('Freelance Income', 'Income from side projects'),
('Gifts Given', 'Presents for others'),
('Personal Care', 'Haircuts, toiletries, etc.'),
('Loan Principal', 'Principal amount of a loan taken or received'),
('Loan Interest', 'Interest paid on loans');

-- Update parent categories (subselects will fetch the generated UUIDs)
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Utilities') WHERE category_name = 'Electricity';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Utilities') WHERE category_name = 'Water';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Utilities') WHERE category_name = 'Internet';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Transportation') WHERE category_name = 'Gasoline';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Transportation') WHERE category_name = 'Public Transport';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Entertainment') WHERE category_name = 'Movies';
UPDATE categories SET parent_category_id = (SELECT category_id FROM categories WHERE category_name = 'Entertainment') WHERE category_name = 'Hobbies';

-- Budget Periods (budget_period_id will be auto-generated UUID by default)
INSERT INTO budget_periods (period_name, start_date, end_date)
VALUES
('May 2025', '2025-05-01', '2025-05-31'),
('June 2025', '2025-06-01', '2025-06-30');

-- Budgets for May 2025 (subselects will fetch UUIDs for budget_period_id and category_id)
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Groceries'), 350.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Rent'), 1200.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Electricity'), 75.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Internet'), 60.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Gasoline'), 150.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Dining Out'), 200.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Entertainment'), 100.00;
INSERT INTO budgets (budget_period_id, category_id, allocated_amount)
SELECT (SELECT budget_period_id FROM budget_periods WHERE period_name = 'May 2025'), (SELECT category_id FROM categories WHERE category_name = 'Loan Interest'), 50.00;


-- Transactions (for May 2025)
DO $$
DECLARE
    main_checking_id UUID;
    primary_savings_id UUID;
    visa_rewards_id UUID;
    emergency_fund_id UUID;
    vacation_fund_id UUID;
    auto_loan_honda_id UUID;

    groceries_cat_id UUID;
    salary_cat_id UUID;
    rent_cat_id UUID;
    electricity_cat_id UUID;
    internet_cat_id UUID;
    gasoline_cat_id UUID;
    public_transport_cat_id UUID;
    dining_out_cat_id UUID;
    movies_cat_id UUID;
    hobbies_cat_id UUID;
    healthcare_cat_id UUID;
    transfer_cat_id UUID;
    freelance_cat_id UUID;
    gifts_cat_id UUID;
    personal_care_cat_id UUID;
    loan_principal_cat_id UUID;
    loan_interest_cat_id UUID;
BEGIN
    SELECT account_id INTO main_checking_id FROM accounts WHERE account_name = 'Main Checking';
    SELECT account_id INTO primary_savings_id FROM accounts WHERE account_name = 'Primary Savings';
    SELECT account_id INTO visa_rewards_id FROM accounts WHERE account_name = 'Visa Rewards Card';
    SELECT account_id INTO emergency_fund_id FROM accounts WHERE account_name = 'Emergency Fund';
    SELECT account_id INTO vacation_fund_id FROM accounts WHERE account_name = 'Vacation Fund';
    SELECT account_id INTO auto_loan_honda_id FROM accounts WHERE account_name = 'Auto Loan - Honda Civic';

    SELECT category_id INTO groceries_cat_id FROM categories WHERE category_name = 'Groceries';
    SELECT category_id INTO salary_cat_id FROM categories WHERE category_name = 'Salary';
    SELECT category_id INTO rent_cat_id FROM categories WHERE category_name = 'Rent';
    SELECT category_id INTO electricity_cat_id FROM categories WHERE category_name = 'Electricity';
    SELECT category_id INTO internet_cat_id FROM categories WHERE category_name = 'Internet';
    SELECT category_id INTO gasoline_cat_id FROM categories WHERE category_name = 'Gasoline';
    SELECT category_id INTO public_transport_cat_id FROM categories WHERE category_name = 'Public Transport';
    SELECT category_id INTO dining_out_cat_id FROM categories WHERE category_name = 'Dining Out';
    SELECT category_id INTO movies_cat_id FROM categories WHERE category_name = 'Movies';
    SELECT category_id INTO hobbies_cat_id FROM categories WHERE category_name = 'Hobbies';
    SELECT category_id INTO healthcare_cat_id FROM categories WHERE category_name = 'Healthcare';
    SELECT category_id INTO transfer_cat_id FROM categories WHERE category_name = 'Transfer';
    SELECT category_id INTO freelance_cat_id FROM categories WHERE category_name = 'Freelance Income';
    SELECT category_id INTO gifts_cat_id FROM categories WHERE category_name = 'Gifts Given';
    SELECT category_id INTO personal_care_cat_id FROM categories WHERE category_name = 'Personal Care';
    SELECT category_id INTO loan_principal_cat_id FROM categories WHERE category_name = 'Loan Principal';
    SELECT category_id INTO loan_interest_cat_id FROM categories WHERE category_name = 'Loan Interest';

    -- Income (transaction_id will be auto-generated UUID)
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, is_recurring)
    VALUES
    (main_checking_id, '2025-05-01', 'Monthly Salary Deposit', 3000.00, 'income', salary_cat_id, 'Tech Solutions Inc.', TRUE),
    (main_checking_id, '2025-05-15', 'Freelance Project Payment - Web Design', 500.00, 'income', freelance_cat_id, 'Client X', FALSE);

    -- Auto Loan Origination
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, notes)
    VALUES
    (auto_loan_honda_id, '2025-05-02', 'Auto Loan Principal for Honda Civic', 22000.00, 'expense', loan_principal_cat_id, 'This transaction makes the loan account balance negative, representing a liability.');
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, notes)
    VALUES
    (main_checking_id, '2025-05-02', 'Auto Loan Funds Received for Honda Civic', 22000.00, 'income', loan_principal_cat_id, 'Honda Finance', 'Funds deposited for car purchase.');

    -- Expenses from Checking
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, is_recurring, notes)
    VALUES
    (main_checking_id, '2025-05-01', 'Rent Payment May', 1200.00, 'expense', rent_cat_id, 'Landlord Properties', TRUE, 'Monthly rent'),
    (main_checking_id, '2025-05-03', 'Electricity Bill', 65.50, 'expense', electricity_cat_id, 'City Power Co.', TRUE, NULL),
    (main_checking_id, '2025-05-05', 'Internet Bill', 59.99, 'expense', internet_cat_id, 'ConnectMe ISP', TRUE, NULL),
    (main_checking_id, '2025-05-10', 'Bus Pass Top-up', 50.00, 'expense', public_transport_cat_id, 'City Transit Authority', FALSE, NULL),
    (main_checking_id, '2025-05-18', 'Pharmacy - Prescription', 25.75, 'expense', healthcare_cat_id, 'Local Pharmacy', FALSE, NULL),
    (main_checking_id, '2025-05-22', 'Haircut', 40.00, 'expense', personal_care_cat_id, 'Cool Cuts Salon', FALSE, NULL);

    -- Expenses from Credit Card
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, notes)
    VALUES
    (visa_rewards_id, '2025-05-02', 'Groceries Run', 75.20, 'expense', groceries_cat_id, 'SuperMart', 'Weekly groceries'),
    (visa_rewards_id, '2025-05-04', 'Dinner with Friends', 62.80, 'expense', dining_out_cat_id, 'The Italian Place', NULL),
    (visa_rewards_id, '2025-05-08', 'Gas Fill-up', 45.00, 'expense', gasoline_cat_id, 'Quick Gas Stop', NULL),
    (visa_rewards_id, '2025-05-12', 'Movie Tickets - Action Flick', 28.00, 'expense', movies_cat_id, 'Cineplex Odeon', NULL),
    (visa_rewards_id, '2025-05-15', 'Groceries - Mid month', 55.40, 'expense', groceries_cat_id, 'Fresh Foods Co', NULL),
    (visa_rewards_id, '2025-05-19', 'Lunch Meeting', 33.10, 'expense', dining_out_cat_id, 'Cafe Central', NULL),
    (visa_rewards_id, '2025-05-21', 'Art Supplies for Painting', 70.00, 'expense', hobbies_cat_id, 'Crafty Corner', 'New paints and brushes'),
    (visa_rewards_id, '2025-05-25', 'Birthday Gift for Sarah', 50.00, 'expense', gifts_cat_id, 'Gift Emporium', NULL);

    -- Transfers
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, notes)
    VALUES
    (main_checking_id, '2025-05-02', 'Transfer to Primary Savings', 500.00, 'transfer_out', transfer_cat_id, 'Monthly savings goal'),
    (primary_savings_id, '2025-05-02', 'Transfer from Main Checking', 500.00, 'transfer_in', transfer_cat_id, 'Monthly savings goal'),
    (main_checking_id, '2025-05-16', 'Transfer to Emergency Fund', 250.00, 'transfer_out', transfer_cat_id, 'Building up emergency fund'),
    (emergency_fund_id, '2025-05-16', 'Transfer from Main Checking', 250.00, 'transfer_in', transfer_cat_id, 'Building up emergency fund'),
    (main_checking_id, '2025-05-20', 'Transfer to Vacation Fund', 100.00, 'transfer_out', transfer_cat_id, 'Saving for trip'),
    (vacation_fund_id, '2025-05-20', 'Transfer from Main Checking', 100.00, 'transfer_in', transfer_cat_id, 'Saving for trip');

    -- Auto Loan Payment Example
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, notes)
    VALUES
    (main_checking_id, '2025-05-26', 'Auto Loan Interest - Honda', 30.00, 'expense', loan_interest_cat_id, 'Honda Finance', 'Portion of payment for interest');
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, merchant_name, notes)
    VALUES
    (main_checking_id, '2025-05-26', 'Auto Loan Principal Payment - Honda', 450.00, 'transfer_out', transfer_cat_id, 'Honda Finance', 'Portion of payment for principal'),
    (auto_loan_honda_id, '2025-05-26', 'Principal Payment from Main Checking - Honda', 450.00, 'transfer_in', transfer_cat_id, NULL, 'Reduces loan principal');

    -- Credit Card Payment from Checking
    INSERT INTO transactions (account_id, transaction_date, description, amount, transaction_type, category_id, notes)
    VALUES
    (main_checking_id, '2025-05-28', 'Payment to Visa Rewards Card', 300.00, 'transfer_out', transfer_cat_id, 'Partial CC payment'),
    (visa_rewards_id, '2025-05-28', 'Payment from Main Checking', 300.00, 'transfer_in', transfer_cat_id, 'Reduces CC balance effectively');

END $$;


COMMIT;
\echo 'Database initialization completed successfully.'