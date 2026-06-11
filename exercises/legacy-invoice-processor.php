<?php
/**
 * Legacy — do refaktoryzacji (Zadanie 7).
 * Problemy: brak typów, SQL injection, brak transakcji, mieszanie warstw.
 */

function process_payment($invoiceId, $amount, $method)
{
    $conn = mysqli_connect('postgres', 'dev', getenv('DB_PASSWORD') ?: 'dev', 'hrk_demo', 5432);
    if (!$conn) {
        die('DB error');
    }

    $sql = "SELECT amount, status FROM invoices WHERE id = " . $invoiceId;
    $res = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($res);

    if ($row['status'] == 'cancelled') {
        return false;
    }

    mysqli_query($conn, "INSERT INTO payments (invoice_id, amount, method) VALUES ($invoiceId, $amount, '$method')");

    $paid = mysqli_query($conn, "SELECT SUM(amount) AS total FROM payments WHERE invoice_id = $invoiceId");
    $total = mysqli_fetch_assoc($paid)['total'];

    if ($total >= $row['amount']) {
        mysqli_query($conn, "UPDATE invoices SET status = 'paid' WHERE id = $invoiceId");
    }

    return true;
}
