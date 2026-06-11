<?php

namespace App\Service;

use App\Entity\Invoice;
use App\Repository\InvoiceRepository;

class InvoiceService
{
    public function __construct(
        private readonly InvoiceRepository $invoiceRepository,
    ) {}

    /**
     * @return list<Invoice>
     */
    public function getAll(): array
    {
        return $this->invoiceRepository->findAllOrdered();
    }
}
