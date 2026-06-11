-- Schemat ćwiczeniowy: faktury i płatności (PostgreSQL)
-- Ładowany automatycznie przy pierwszym starcie kontenera postgres.

CREATE TABLE IF NOT EXISTS customers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    tax_id      VARCHAR(20) UNIQUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
    id          SERIAL PRIMARY KEY,
    number      VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL REFERENCES customers(id),
    amount      DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    status      VARCHAR(20) NOT NULL DEFAULT 'draft'
                CHECK (status IN ('draft', 'issued', 'paid', 'overdue', 'cancelled')),
    issued_at   DATE,
    due_at      DATE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoice_items (
    id          SERIAL PRIMARY KEY,
    invoice_id  INT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(300) NOT NULL,
    quantity    INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price  DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    line_total  DECIMAL(12, 2) NOT NULL CHECK (line_total >= 0)
);

CREATE TABLE IF NOT EXISTS payments (
    id          SERIAL PRIMARY KEY,
    invoice_id  INT NOT NULL REFERENCES invoices(id),
    amount      DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    paid_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    method      VARCHAR(30) NOT NULL DEFAULT 'transfer'
);

INSERT INTO customers (id, name, tax_id) VALUES
    (1, 'Acme Travel Sp. z o.o.', 'PL1234567890'),
    (2, 'Globex Business Trips',  'PL9876543210'),
    (3, 'Wayfarer Consulting',    'PL5555555555')
ON CONFLICT (id) DO NOTHING;

SELECT setval('customers_id_seq', (SELECT COALESCE(MAX(id), 1) FROM customers));

INSERT INTO invoices (id, number, customer_id, amount, status, issued_at, due_at) VALUES
    (1, 'FV/2026/001', 1, 12500.00, 'issued',  '2026-01-10', '2026-02-10'),
    (2, 'FV/2026/002', 1,  8400.00, 'paid',    '2026-01-05', '2026-02-05'),
    (3, 'FV/2026/003', 2, 22000.00, 'overdue', '2025-11-01', '2025-12-01'),
    (4, 'FV/2026/004', 3,  3100.00, 'draft',   NULL,         NULL),
    (5, 'FV/2026/005', 2,  5600.00, 'issued',  '2026-02-01', '2026-03-01')
ON CONFLICT (id) DO NOTHING;

SELECT setval('invoices_id_seq', (SELECT COALESCE(MAX(id), 1) FROM invoices));

INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, line_total) VALUES
    (1, 'Rezerwacja hotelu — Warszawa',  5,  500.00,  2500.00),
    (1, 'Bilety lotnicze',              10, 1000.00, 10000.00),
    (2, 'Pakiet konferencyjny',          2, 4200.00,  8400.00),
    (3, 'Delegacja zagraniczna',         4, 5500.00, 22000.00),
    (4, 'Konsultacja travel policy',     1, 3100.00,  3100.00),
    (5, 'Transfer lotniskowy',          14,  400.00,  5600.00);

INSERT INTO payments (invoice_id, amount, paid_at, method) VALUES
    (2, 8400.00, '2026-01-20 10:00:00', 'transfer'),
    (1, 5000.00, '2026-01-25 14:30:00', 'transfer'),
    (3,  800.00, '2025-12-10 09:00:00', 'transfer');
