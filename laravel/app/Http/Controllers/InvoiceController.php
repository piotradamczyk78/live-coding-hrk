<?php

namespace App\Http\Controllers;

use App\Services\InvoiceService;
use Illuminate\View\View;

class InvoiceController extends Controller
{
    public function __construct(
        private readonly InvoiceService $invoiceService,
    ) {}

    public function index(): View
    {
        return view('invoices.index', [
            'invoices' => $this->invoiceService->getAll(),
        ]);
    }
}
