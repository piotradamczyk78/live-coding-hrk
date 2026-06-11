<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Faktury — {{ config('app.name', 'Laravel') }}</title>
    @include('invoices.partials.styles')
</head>
<body>
    <div class="header">
        <h1>Faktury</h1>
        <a href="{{ route('invoices.create') }}" class="btn btn-primary">+ Nowa faktura</a>
    </div>

    @if (session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

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
                    <th>Akcje</th>
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
                        <td>
                            <div class="actions">
                                <a href="{{ route('invoices.edit', $invoice) }}" class="btn btn-secondary btn-sm">Edytuj</a>
                                <form method="POST" action="{{ route('invoices.destroy', $invoice) }}"
                                      onsubmit="return confirm('Czy na pewno usunąć fakturę {{ $invoice->number }}?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-danger btn-sm">Usuń</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</body>
</html>
