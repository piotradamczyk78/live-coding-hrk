SELECT
    i.number AS invoice_number,
    c.name AS customer_name,
    i.amount,
    ISNULL(SUM(p.amount), 0) AS paid_total,
    i.amount - ISNULL(SUM(p.amount), 0) AS remaining
FROM dbo.invoices i
JOIN dbo.customers c ON c.id = i.customer_id
LEFT JOIN dbo.payments p ON p.invoice_id = i.id
WHERE i.status NOT IN (N'cancelled', N'draft')
GROUP BY i.id, i.number, c.name, i.amount
HAVING ISNULL(SUM(p.amount), 0) < i.amount
ORDER BY remaining DESC;
