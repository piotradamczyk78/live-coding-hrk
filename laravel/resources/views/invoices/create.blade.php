<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nowa faktura — {{ config('app.name', 'Laravel') }}</title>
    @include('invoices.partials.styles')
</head>
<body>
    <h1>Nowa faktura</h1>

    <div class="form-card">
        <form method="POST" action="{{ route('invoices.store') }}">
            @csrf
            @include('invoices.partials.form')
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Zapisz</button>
                <a href="{{ route('invoices.index') }}" class="btn btn-secondary">Anuluj</a>
            </div>
        </form>
    </div>
</body>
</html>
