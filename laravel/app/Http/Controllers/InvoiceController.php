<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use App\Services\InvoiceService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class InvoiceController extends Controller
{
    public function __construct(
        private readonly InvoiceService $invoiceService,
    ) {}

    /**
     * Summary of index
     * @return View
     */
    public function index(): View
    {
        return view('invoices.index', [
            'invoices' => $this->invoiceService->getAll(),
        ]);
    }

    /**
     * Summary of create
     * @return View
     */
    public function create(): View
    {
        return view('invoices.create', [
            'customers' => $this->invoiceService->getCustomers(),
            'statuses' => InvoiceService::STATUSES,
        ]);
    }

    /**
     * Summary of store
     * @param Request $request
     * @return RedirectResponse
     */
    public function store(Request $request): RedirectResponse
    {
        $this->invoiceService->create($request->all());

        return redirect()
            ->route('invoices.index')
            ->with('success', 'Faktura została dodana.');
    }

    /**
     * Summary of edit
     * @param Invoice $invoice
     * @return View
     */
    public function edit(Invoice $invoice): View
    {
        return view('invoices.edit', [
            'invoice' => $invoice->load('customer'),
            'customers' => $this->invoiceService->getCustomers(),
            'statuses' => InvoiceService::STATUSES,
        ]);
    }

    /**
     * Summary of update
     * @param Request $request
     * @param Invoice $invoice
     * @return RedirectResponse
     */
    public function update(Request $request, Invoice $invoice): RedirectResponse
    {
        $this->invoiceService->update($invoice, $request->all());

        return redirect()
            ->route('invoices.index')
            ->with('success', 'Faktura została zaktualizowana.');
    }

    /**
     * Summary of destroy
     * @param Invoice $invoice
     * @return RedirectResponse
     */
    public function destroy(Invoice $invoice): RedirectResponse
    {
        $this->invoiceService->delete($invoice);

        return redirect()
            ->route('invoices.index')
            ->with('success', 'Faktura została usunięta.');
    }
}
