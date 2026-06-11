<?php

namespace App\Services;

use App\Models\Invoice;
use Illuminate\Database\Eloquent\Collection;

class InvoiceService
{
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
}
