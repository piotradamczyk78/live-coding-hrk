-- Schemat ćwiczeniowy: faktury i płatności (MS SQL / T-SQL)
-- Ładowany przez scripts/init-mssql.sh

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'hrk_demo')
    CREATE DATABASE hrk_demo;
GO

USE hrk_demo;
GO

IF OBJECT_ID(N'dbo.payments', N'U') IS NOT NULL DROP TABLE dbo.payments;
IF OBJECT_ID(N'dbo.invoice_items', N'U') IS NOT NULL DROP TABLE dbo.invoice_items;
IF OBJECT_ID(N'dbo.invoices', N'U') IS NOT NULL DROP TABLE dbo.invoices;
IF OBJECT_ID(N'dbo.customers', N'U') IS NOT NULL DROP TABLE dbo.customers;
GO

CREATE TABLE dbo.customers (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(200) NOT NULL,
    tax_id      NVARCHAR(20) NULL UNIQUE,
    created_at  DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE dbo.invoices (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    number      NVARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL REFERENCES dbo.customers(id),
    amount      DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    status      NVARCHAR(20) NOT NULL DEFAULT N'draft'
                CHECK (status IN (N'draft', N'issued', N'paid', N'overdue', N'cancelled')),
    issued_at   DATE NULL,
    due_at      DATE NULL,
    created_at  DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE dbo.invoice_items (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id  INT NOT NULL REFERENCES dbo.invoices(id) ON DELETE CASCADE,
    description NVARCHAR(300) NOT NULL,
    quantity    INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price  DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    line_total  DECIMAL(12, 2) NOT NULL CHECK (line_total >= 0)
);

CREATE TABLE dbo.payments (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id  INT NOT NULL REFERENCES dbo.invoices(id),
    amount      DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    paid_at     DATETIME2 NOT NULL DEFAULT GETDATE(),
    method      NVARCHAR(30) NOT NULL DEFAULT N'transfer'
);
GO

SET IDENTITY_INSERT dbo.customers ON;
INSERT INTO dbo.customers (id, name, tax_id) VALUES
    (1, N'Acme Travel Sp. z o.o.', N'PL1234567890'),
    (2, N'Globex Business Trips',  N'PL9876543210'),
    (3, N'Wayfarer Consulting',    N'PL5555555555');
SET IDENTITY_INSERT dbo.customers OFF;
GO

SET IDENTITY_INSERT dbo.invoices ON;
INSERT INTO dbo.invoices (id, number, customer_id, amount, status, issued_at, due_at) VALUES
    (1, N'FV/2026/001', 1, 12500.00, N'issued',  '2026-01-10', '2026-02-10'),
    (2, N'FV/2026/002', 1,  8400.00, N'paid',    '2026-01-05', '2026-02-05'),
    (3, N'FV/2026/003', 2, 22000.00, N'overdue', '2025-11-01', '2025-12-01'),
    (4, N'FV/2026/004', 3,  3100.00, N'draft',   NULL,         NULL),
    (5, N'FV/2026/005', 2,  5600.00, N'issued',  '2026-02-01', '2026-03-01');
SET IDENTITY_INSERT dbo.invoices OFF;
GO

INSERT INTO dbo.invoice_items (invoice_id, description, quantity, unit_price, line_total) VALUES
    (1, N'Rezerwacja hotelu — Warszawa',  5,  500.00,  2500.00),
    (1, N'Bilety lotnicze',              10, 1000.00, 10000.00),
    (2, N'Pakiet konferencyjny',          2, 4200.00,  8400.00),
    (3, N'Delegacja zagraniczna',         4, 5500.00, 22000.00),
    (4, N'Konsultacja travel policy',     1, 3100.00,  3100.00),
    (5, N'Transfer lotniskowy',          14,  400.00,  5600.00);
GO

INSERT INTO dbo.payments (invoice_id, amount, paid_at, method) VALUES
    (2, 8400.00, '2026-01-20 10:00:00', N'transfer'),
    (1, 5000.00, '2026-01-25 14:30:00', N'transfer'),
    (3,  800.00, '2025-12-10 09:00:00', N'transfer');
GO
