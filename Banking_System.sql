-- Tạo cơ sở dữ liệu
CREATE DATABASE BANKING_SYSTEM;
GO


-- Tạo bảng khách hàng
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20)
);
GO

-- Tạo bảng tài khoản
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    Balance DECIMAL(15, 2),
    AccountType VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Tạo bảng giao dịch
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    Type VARCHAR(20),  -- Deposit, Withdraw, Transfer
    Amount DECIMAL(15, 2),
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);


-- Tạo bảng cảnh báo
CREATE TABLE Alerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT,
    Message VARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
GO

-- Tạo trigger phát hiện giao dịch lớn
CREATE TRIGGER SuspiciousActivity
ON Transactions
AFTER INSERT
AS
BEGIN
    INSERT INTO Alerts (AccountID, Message)
    SELECT AccountID, 'Suspicious large transaction'
    FROM INSERTED
    WHERE Amount > 10000;
END;
GO
INSERT INTO Customers (CustomerID, FullName, Email, Phone)
VALUES 
(1, 'Nguyen Van A', 'vana@example.com', '0901234567'),
(2, 'Tran Thi B', 'thib@example.com', '0907654321'),
(3, 'Le Van C', 'c.le@example.com', '0912345678'),
(4, 'Pham Thi D', 'd.pham@example.com', '0923456789'),
(5, 'Hoang Van E', 'e.hoang@example.com', '0934567890');
INSERT INTO Accounts (AccountID, CustomerID, Balance, AccountType)
VALUES 
(101, 1, 120000.00, 'Savings'),
(102, 2, 15000.00, 'Checking'),
(103, 3, 7500.00, 'Savings'),
(104, 4, 23000.00, 'Checking'),
(105, 5, 500000.00, 'Savings');
INSERT INTO Transactions (TransactionID, AccountID, Type, Amount)
VALUES 
(1001, 101, 'Deposit', 5000.00),
(1002, 101, 'Deposit', 15000.00), -- Trigger
(1003, 102, 'Withdraw', 2000.00),
(1004, 103, 'Deposit', 800.00),
(1005, 104, 'Transfer', 25000.00), -- Trigger
(1006, 105, 'Deposit', 110000.00), -- Trigger
(1007, 105, 'Withdraw', 9999.99),
(1008, 105, 'Deposit', 20000.00); -- Trigger
-- 1. Truy vấn các giao dịch có Amount > 10,000 kèm thông tin khách hàng
SELECT 
    T.TransactionID,
    C.FullName,              -- Tên chủ tài khoản
    A.AccountID,             -- Mã tài khoản
    T.Amount,                -- Số tiền giao dịch
    T.Type,                  -- Loại giao dịch: Deposit, Withdraw, Transfer
    T.Timestamp              -- Thời gian giao dịch
FROM Transactions T
JOIN Accounts A ON T.AccountID = A.AccountID
JOIN Customers C ON A.CustomerID = C.CustomerID
WHERE T.Amount > 10000;

--2. Truy vấn danh sách cảnh báo với thông tin khách hàng liên quan
SELECT 
    Al.AlertID,              -- Mã cảnh báo
    C.FullName,              -- Tên khách hàng
    A.AccountID,             -- Mã tài khoản
    Al.Message,              -- Nội dung cảnh báo
    Al.CreatedAt             -- Thời gian tạo cảnh báo
FROM Alerts Al
JOIN Accounts A ON Al.AccountID = A.AccountID
JOIN Customers C ON A.CustomerID = C.CustomerID;

-- 3. Tính tổng tiền giao dịch (Deposit, Withdraw, Transfer) theo từng tài khoản
SELECT 
    A.AccountID,
    C.FullName,
    SUM(T.Amount) AS TotalAmount -- Tổng số tiền đã giao dịch
FROM Transactions T
JOIN Accounts A ON T.AccountID = A.AccountID
JOIN Customers C ON A.CustomerID = C.CustomerID
GROUP BY A.AccountID, C.FullName;

-- 4. Đếm số giao dịch mỗi khách hàng thực hiện (qua tất cả tài khoản)
SELECT 
    C.CustomerID,
    C.FullName,
    COUNT(T.TransactionID) AS TotalTransactions -- Tổng số giao dịch
FROM Customers C
JOIN Accounts A ON C.CustomerID = A.CustomerID
JOIN Transactions T ON A.AccountID = T.AccountID
GROUP BY C.CustomerID, C.FullName;
-- 5. Lọc danh sách tài khoản có số dư cao (Balance > 100,000)
SELECT 
    C.FullName,
    A.AccountID,
    A.Balance
FROM Accounts A
JOIN Customers C ON A.CustomerID = C.CustomerID
WHERE A.Balance > 100000;

-- 6. Lấy thông tin khách hàng chỉ khi có ít nhất 1 giao dịch lớn
SELECT DISTINCT C.CustomerID, C.FullName
FROM Customers C
WHERE EXISTS (
    SELECT 1 
    FROM Accounts A
    JOIN Transactions T ON T.AccountID = A.AccountID
    WHERE A.CustomerID = C.CustomerID AND T.Amount > 10000
);
-- 7. Tìm các giao dịch từ ngày 01/04/2025 trở đi
SELECT TransactionID, AccountID, Amount, Timestamp
FROM Transactions
WHERE Timestamp >= '2025-04-01';
-- 8.  Dùng CTE và ROW_NUMBER để tìm giao dịch lớn nhất theo mỗi AccountID
WITH RankedTransactions AS (
    SELECT 
        TransactionID,
        AccountID,
        Amount,
        ROW_NUMBER() OVER (PARTITION BY AccountID ORDER BY Amount DESC) AS rn
    FROM Transactions
)
SELECT *
FROM RankedTransactions
WHERE rn = 1;
-- 9. Tổng tiền giao dịch theo loại trong tháng 4/2025
SELECT Type, SUM(Amount) AS TotalAmount
FROM Transactions
WHERE Timestamp BETWEEN '2025-04-01' AND '2025-04-30'
GROUP BY Type;
