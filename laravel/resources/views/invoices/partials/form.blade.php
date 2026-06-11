@php
    $invoice = $invoice ?? null;
@endphp

<div class="form-group">
    <label for="number">Numer faktury</label>
    <input type="text" id="number" name="number" value="{{ old('number', $invoice?->number) }}" required>
    @error('number')<div class="error">{{ $message }}</div>@enderror
</div>

<div class="form-group">
    <label for="customer_id">Klient</label>
    <select id="customer_id" name="customer_id" required>
        <option value="">— wybierz —</option>
        @foreach ($customers as $customer)
            <option value="{{ $customer->id }}" @selected(old('customer_id', $invoice?->customer_id) == $customer->id)>
                {{ $customer->name }}
            </option>
        @endforeach
    </select>
    @error('customer_id')<div class="error">{{ $message }}</div>@enderror
</div>

<div class="form-group">
    <label for="amount">Kwota (PLN)</label>
    <input type="number" id="amount" name="amount" step="0.01" min="0.01"
           value="{{ old('amount', $invoice?->amount) }}" required>
    @error('amount')<div class="error">{{ $message }}</div>@enderror
</div>

<div class="form-group">
    <label for="status">Status</label>
    <select id="status" name="status" required>
        @foreach ($statuses as $status)
            <option value="{{ $status }}" @selected(old('status', $invoice?->status ?? 'draft') === $status)>
                {{ $status }}
            </option>
        @endforeach
    </select>
    @error('status')<div class="error">{{ $message }}</div>@enderror
</div>

<div class="form-group">
    <label for="issued_at">Data wystawienia</label>
    <input type="date" id="issued_at" name="issued_at"
           value="{{ old('issued_at', $invoice?->issued_at?->format('Y-m-d')) }}">
    @error('issued_at')<div class="error">{{ $message }}</div>@enderror
</div>

<div class="form-group">
    <label for="due_at">Termin płatności</label>
    <input type="date" id="due_at" name="due_at"
           value="{{ old('due_at', $invoice?->due_at?->format('Y-m-d')) }}">
    @error('due_at')<div class="error">{{ $message }}</div>@enderror
</div>
