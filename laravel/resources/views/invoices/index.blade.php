<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Faktury — {{ config('app.name', 'Laravel') }}</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, sans-serif;
            margin: 0;
            padding: 2rem;
            background: #f8fafc;
            color: #0f172a;
        }
        h1 { margin: 0 0 1.5rem; font-size: 1.5rem; }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }
        th, td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }
        th {
            background: #f1f5f9;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
        }
        tr:last-child td { border-bottom: none; }
        .amount { font-variant-numeric: tabular-nums; text-align: right; }
        .status {
            display: inline-block;
            padding: 0.15rem 0.5rem;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        .status-paid { background: #dcfce7; color: #166534; }
        .status-issued { background: #dbeafe; color: #1e40af; }
        .status-overdue { background: #fee2e2; color: #991b1b; }
        .status-draft { background: #f1f5f9; color: #475569; }
        .status-cancelled { background: #fef3c7; color: #92400e; }
        .empty { color: #64748b; padding: 2rem; text-align: center; }
    </style>
</head>
<body>
    <h1>Faktury</h1>

    @if ($invoices->isEmpty())
        <p class="empty">Brak faktur w bazie danych.</p>
    @else
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Numer</th>
                    <th>Klient</th>
                    <th>Kwota</th>
                    <th>Status</th>
                    <th>Wystawiona</th>
                    <th>Termin płatności</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($invoices as $invoice)
                    <tr>
                        <td>{{ $invoice->id }}</td>
                        <td>{{ $invoice->number }}</td>
                        <td>{{ $invoice->customer?->name ?? '—' }}</td>
                        <td class="amount">{{ number_format($invoice->amount, 2, ',', ' ') }} PLN</td>
                        <td>
                            <span class="status status-{{ $invoice->status }}">
                                {{ $invoice->status }}
                            </span>
                        </td>
                        <td>{{ $invoice->issued_at?->format('Y-m-d') ?? '—' }}</td>
                        <td>{{ $invoice->due_at?->format('Y-m-d') ?? '—' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</body>
</html>
