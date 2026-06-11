SELECT
    i.number AS invoice_number,
    c.name AS customer_name,
    i.amount,
    COALESCE(SUM(p.amount), 0) AS paid_total,
    i.amount - COALESCE(SUM(p.amount), 0) AS remaining
FROM invoices i
JOIN customers c ON c.id = i.customer_id
LEFT JOIN payments p ON p.invoice_id = i.id
WHERE i.status NOT IN ('cancelled', 'draft')
GROUP BY i.id, i.number, c.name, i.amount
HAVING COALESCE(SUM(p.amount), 0) < i.amount
ORDER BY remaining DESC;
