<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Invoice;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class InvoiceService
{
    public const STATUSES = ['draft', 'issued', 'paid', 'overdue', 'cancelled'];

    /**
     * @return Collection<int, Invoice>
     */
    public function getAll(): Collection
    {
        return Invoice::query()
            ->with('customer')
            ->orderBy('id')
            ->get();
    }

    /**
     * @return Collection<int, Customer>
     */
    public function getCustomers(): Collection
    {
        return Customer::query()->orderBy('name')->get();
    }

    public function find(int $id): Invoice
    {
        return Invoice::query()->with('customer')->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): Invoice
    {
        $validated = $this->validate($data);

        return Invoice::query()->create([
            ...$validated,
            'created_at' => now(),
        ]);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Invoice $invoice, array $data): Invoice
    {
        $validated = $this->validate($data, $invoice->id);

        $invoice->update($validated);

        return $invoice->fresh(['customer']);
    }

    public function delete(Invoice $invoice): void
    {
        DB::transaction(function () use ($invoice): void {
            DB::table('payments')->where('invoice_id', $invoice->id)->delete();
            DB::table('invoice_items')->where('invoice_id', $invoice->id)->delete();
            $invoice->delete();
        });
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function validate(array $data, ?int $ignoreId = null): array
    {
        $uniqueRule = 'unique:invoices,number';
        if ($ignoreId !== null) {
            $uniqueRule .= ','.$ignoreId;
        }

        $validator = Validator::make($data, [
            'number' => ['required', 'string', 'max:50', $uniqueRule],
            'customer_id' => ['required', 'integer', 'exists:customers,id'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'status' => ['required', 'string', 'in:'.implode(',', self::STATUSES)],
            'issued_at' => ['nullable', 'date'],
            'due_at' => ['nullable', 'date'],
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        $validated = $validator->validated();

        return [
            'number' => $validated['number'],
            'customer_id' => (int) $validated['customer_id'],
            'amount' => $validated['amount'],
            'status' => $validated['status'],
            'issued_at' => $validated['issued_at'] ?? null,
            'due_at' => $validated['due_at'] ?? null,
        ];
    }
}
