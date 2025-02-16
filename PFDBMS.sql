
-- USER table
CREATE TABLE [USER] (
    User_ID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(100),
    User_Name VARCHAR(100),
    Password_Hash VARCHAR(255),
    Sign_Up_Date DATE
);

-- ACCOUNT table
CREATE TABLE ACCOUNT (
    Account_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT,
    Account_Name VARCHAR(100),
    Current_Balance DECIMAL(10, 2),
    Creation_Date DATE,
    FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
);

-- INCOME_SOURCE table
CREATE TABLE INCOME_SOURCE (
    Source_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT,
    Source_Name VARCHAR(100),
    Income_Description VARCHAR(255),
    Source_Active BIT,
    FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
);

-- EXPENSE_CATEGORY table
CREATE TABLE EXPENSE_CATEGORY (
    Category_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT,
    Category_Name VARCHAR(100),
    Category_Description VARCHAR(255),
    Category_Active BIT,
    FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
);

-- INCOME table
CREATE TABLE INCOME (
    Income_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT,
    Source_ID INT,
    Income_Amount DECIMAL(10, 2),
    Income_Date DATE,
    Income_Remark VARCHAR(255),
    FOREIGN KEY (Account_ID) REFERENCES ACCOUNT(Account_ID),
    FOREIGN KEY (Source_ID) REFERENCES INCOME_SOURCE(Source_ID)
);

-- EXPENSE table
CREATE TABLE EXPENSE (
    Expense_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT,
    Category_ID INT,
    Expense_Amount DECIMAL(10, 2),
    Expense_Date DATE,
    Expense_Remark VARCHAR(255),
    FOREIGN KEY (Account_ID) REFERENCES ACCOUNT(Account_ID),
    FOREIGN KEY (Category_ID) REFERENCES EXPENSE_CATEGORY(Category_ID)
);

-- BUDGET table
CREATE TABLE BUDGET (
    Budget_ID INT IDENTITY(1,1) PRIMARY KEY,
    User_ID INT,
    Month DATE,
    Target_Amount DECIMAL(10, 2),
    Current_Progress DECIMAL(10, 2),
    FOREIGN KEY (User_ID) REFERENCES [USER](User_ID)
);

-- Insert sample data into USER table
INSERT INTO [USER] (Email, User_Name, Password_Hash, Sign_Up_Date) VALUES
('john.doe@email.com', 'John Doe', 'hash1', '2024-01-01'),
('jane.smith@email.com', 'Jane Smith', 'hash2', '2024-01-02'),
('bob.wilson@email.com', 'Bob Wilson', 'hash3', '2024-01-03');

-- Insert sample data into ACCOUNT table
INSERT INTO ACCOUNT (User_ID, Account_Name, Current_Balance, Creation_Date) VALUES
(1, 'John''s Checking', 5000.00, '2024-01-01'),
(1, 'John''s Savings', 10000.00, '2024-01-01'),
(2, 'Jane''s Main Account', 7500.00, '2024-01-02'),
(3, 'Bob''s Account', 3000.00, '2024-01-03');

-- Insert sample data into INCOME_SOURCE table
INSERT INTO INCOME_SOURCE (User_ID, Source_Name, Income_Description, Source_Active) VALUES
(1, 'Salary', 'Monthly salary from ABC Corp', 1),
(1, 'Freelance', 'Web development projects', 1),
(2, 'Investments', 'Stock dividends', 1),
(3, 'Rental', 'Property rental income', 1);

-- Insert sample data into EXPENSE_CATEGORY table
INSERT INTO EXPENSE_CATEGORY (User_ID, Category_Name, Category_Description, Category_Active) VALUES
(1, 'Groceries', 'Food and household items', 1),
(1, 'Utilities', 'Electricity, water, gas', 1),
(2, 'Transportation', 'Gas and public transport', 1),
(3, 'Entertainment', 'Movies and dining out', 1);

-- Insert sample data into INCOME table
INSERT INTO INCOME (Account_ID, Source_ID, Income_Amount, Income_Date, Income_Remark) VALUES
(1, 1, 5000.00, '2024-02-01', 'February Salary'),
(1, 2, 1000.00, '2024-02-15', 'Freelance Project'),
(3, 3, 2000.00, '2024-02-01', 'Dividend Payment'),
(4, 4, 1500.00, '2024-02-01', 'Monthly Rent');

-- Insert sample data into EXPENSE table
INSERT INTO EXPENSE (Account_ID, Category_ID, Expense_Amount, Expense_Date, Expense_Remark) VALUES
(1, 1, 300.00, '2024-02-05', 'Weekly Groceries'),
(1, 2, 150.00, '2024-02-10', 'Electricity Bill'),
(3, 3, 200.00, '2024-02-07', 'Monthly Transit Pass'),
(4, 4, 100.00, '2024-02-08', 'Movie Night');

-- Insert sample data into BUDGET table
INSERT INTO BUDGET (User_ID, Month, Target_Amount, Current_Progress) VALUES
(1, '2024-02-01', 3000.00, 450.00),
(2, '2024-02-01', 2000.00, 200.00),
(3, '2024-02-01', 1500.00, 100.00);

SELECT     U.User_Name,    COALESCE(SUM(I.Income_Amount), 0) as Total_Income,    COALESCE(SUM(E.Expense_Amount), 0) as Total_ExpensesFROM [USER] ULEFT JOIN ACCOUNT A ON U.User_ID = A.User_IDLEFT JOIN INCOME I ON A.Account_ID = I.Account_IDLEFT JOIN EXPENSE E ON A.Account_ID = E.Account_IDGROUP BY U.User_ID, U.User_Name;

-- 2. Find users who have not exceeded their budget
SELECT 
    U.User_Name,
    B.Target_Amount,
    B.Current_Progress
FROM [USER] U
JOIN BUDGET B ON U.User_ID = B.User_ID
WHERE B.Current_Progress < B.Target_Amount;

-- 3. Get the most used expense category for each user
SELECT 
    U.User_Name,
    EC.Category_Name,
    COUNT(*) as Usage_Count
FROM [USER] U
JOIN EXPENSE_CATEGORY EC ON U.User_ID = EC.User_ID
JOIN EXPENSE E ON EC.Category_ID = E.Category_ID
GROUP BY U.User_ID, U.User_Name, EC.Category_Name
HAVING COUNT(*) = (
    SELECT TOP 1 COUNT(*)
    FROM EXPENSE E2
    JOIN EXPENSE_CATEGORY EC2 ON E2.Category_ID = EC2.Category_ID
    WHERE EC2.User_ID = U.User_ID
    GROUP BY EC2.Category_ID
    ORDER BY COUNT(*) DESC
);

-- 4. Calculate account balance after all transactions
SELECT 
    A.Account_Name,
    A.Current_Balance,
    COALESCE(SUM(I.Income_Amount), 0) - COALESCE(SUM(E.Expense_Amount), 0) as Net_Change
FROM ACCOUNT A
LEFT JOIN INCOME I ON A.Account_ID = I.Account_ID
LEFT JOIN EXPENSE E ON A.Account_ID = E.Account_ID
GROUP BY A.Account_ID, A.Account_Name, A.Current_Balance;

-- 5. Find users with no recent activity (no transactions in the last 30 days)
SELECT DISTINCT U.User_Name
FROM [USER] U
LEFT JOIN ACCOUNT A ON U.User_ID = A.User_ID
LEFT JOIN INCOME I ON A.Account_ID = I.Account_ID
LEFT JOIN EXPENSE E ON A.Account_ID = E.Account_ID
WHERE (I.Income_Date IS NULL OR I.Income_Date < DATEADD(day, -30, GETDATE()))
AND (E.Expense_Date IS NULL OR E.Expense_Date < DATEADD(day, -30, GETDATE()));

-- 6. Get monthly income summary by source
SELECT 
    U.User_Name,
    IncSource.Source_Name,
    FORMAT(I.Income_Date, 'yyyy-MM') as Month,
    SUM(I.Income_Amount) as Total_Income
FROM INCOME I
JOIN INCOME_SOURCE IncSource ON I.Source_ID = IncSource.Source_ID
JOIN ACCOUNT A ON I.Account_ID = A.Account_ID
JOIN [USER] U ON A.User_ID = U.User_ID
GROUP BY U.User_Name, IncSource.Source_Name, FORMAT(I.Income_Date, 'yyyy-MM');

-- 7. Find highest single expense for each category
SELECT 
    U.User_Name,
    EC.Category_Name,
    MAX(E.Expense_Amount) as Highest_Expense
FROM EXPENSE E
JOIN EXPENSE_CATEGORY EC ON E.Category_ID = EC.Category_ID
JOIN ACCOUNT A ON E.Account_ID = A.Account_ID
JOIN [USER] U ON A.User_ID = U.User_ID
GROUP BY U.User_Name, EC.Category_Name;

-- 8. Calculate budget utilization percentage
SELECT 
    U.User_Name,
    B.Target_Amount,
    B.Current_Progress,
    (B.Current_Progress / B.Target_Amount * 100) as Utilization_Percentage
FROM BUDGET B
JOIN [USER] U ON B.User_ID = U.User_ID;

-- 9. Find users with multiple accounts and their total balance
SELECT 
    U.User_Name,
    COUNT(A.Account_ID) as Number_of_Accounts,
    SUM(A.Current_Balance) as Total_Balance
FROM [USER] U
JOIN ACCOUNT A ON U.User_ID = A.User_ID
GROUP BY U.User_ID, U.User_Name
HAVING COUNT(A.Account_ID) > 1;

-- 10. Get expense trends by category over time
SELECT 
    EC.Category_Name,
    FORMAT(E.Expense_Date, 'yyyy-MM') as Month,
    SUM(E.Expense_Amount) as Total_Expense,
    COUNT(*) as Number_of_Transactions
FROM EXPENSE E
JOIN EXPENSE_CATEGORY EC ON E.Category_ID = EC.Category_ID
GROUP BY EC.Category_Name, FORMAT(E.Expense_Date, 'yyyy-MM')
ORDER BY EC.Category_Name, FORMAT(E.Expense_Date, 'yyyy-MM');


-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_User ON [USER](User_ID)
-- Email is used for login and should be unique
CREATE UNIQUE NONCLUSTERED INDEX IX_User_Email ON [USER](Email)

-- Cover frequently queried columns
CREATE NONCLUSTERED INDEX IX_User_Name ON [USER](User_Name) 
    INCLUDE (Sign_Up_Date)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_Account ON ACCOUNT(Account_ID)

-- Foreign key index for joins with USER table
CREATE NONCLUSTERED INDEX IX_Account_UserID ON ACCOUNT(User_ID)

-- Composite index for account lookup
CREATE NONCLUSTERED INDEX IX_Account_UserName ON ACCOUNT(User_ID, Account_Name)
    INCLUDE (Current_Balance, Creation_Date)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_IncomeSource ON INCOME_SOURCE(Source_ID)

-- Foreign key index
CREATE NONCLUSTERED INDEX IX_IncomeSource_UserID ON INCOME_SOURCE(User_ID)

-- Composite index for source lookup
CREATE NONCLUSTERED INDEX IX_IncomeSource_Name ON INCOME_SOURCE(User_ID, Source_Name)
    INCLUDE (Source_Active)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_ExpenseCategory ON EXPENSE_CATEGORY(Category_ID)

-- Foreign key index
CREATE NONCLUSTERED INDEX IX_ExpenseCategory_UserID ON EXPENSE_CATEGORY(User_ID)

-- Composite index for category lookup
CREATE NONCLUSTERED INDEX IX_ExpenseCategory_Name ON EXPENSE_CATEGORY(User_ID, Category_Name)
    INCLUDE (Category_Active)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_Income ON INCOME(Income_ID)

-- Foreign key indexes
CREATE NONCLUSTERED INDEX IX_Income_AccountID ON INCOME(Account_ID)
CREATE NONCLUSTERED INDEX IX_Income_SourceID ON INCOME(Source_ID)

-- Date-based queries index
CREATE NONCLUSTERED INDEX IX_Income_Date ON INCOME(Income_Date)
    INCLUDE (Income_Amount)

-- Composite index for reporting
CREATE NONCLUSTERED INDEX IX_Income_AccountDate ON INCOME(Account_ID, Income_Date)
    INCLUDE (Income_Amount)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_Expense ON EXPENSE(Expense_ID)

-- Foreign key indexes
CREATE NONCLUSTERED INDEX IX_Expense_AccountID ON EXPENSE(Account_ID)
CREATE NONCLUSTERED INDEX IX_Expense_CategoryID ON EXPENSE(Category_ID)

-- Date-based queries index
CREATE NONCLUSTERED INDEX IX_Expense_Date ON EXPENSE(Expense_Date)
    INCLUDE (Expense_Amount)

-- Composite index for reporting
CREATE NONCLUSTERED INDEX IX_Expense_AccountDate ON EXPENSE(Account_ID, Expense_Date)
    INCLUDE (Expense_Amount)
-- Primary Key (automatically creates clustered index)
CREATE UNIQUE CLUSTERED INDEX PK_Budget ON BUDGET(Budget_ID)

-- Foreign key index
CREATE NONCLUSTERED INDEX IX_Budget_UserID ON BUDGET(User_ID)

-- Composite index for monthly budget lookup
CREATE NONCLUSTERED INDEX IX_Budget_UserMonth ON BUDGET(User_ID, Month)
    INCLUDE (Target_Amount, Current_Progress)