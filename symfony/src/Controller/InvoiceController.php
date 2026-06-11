<?php

namespace App\Controller;

use App\Service\InvoiceService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class InvoiceController extends AbstractController
{
    public function __construct(
        private readonly InvoiceService $invoiceService,
    ) {}

    #[Route('/invoices', name: 'invoices_index')]
    public function index(): Response
    {
        return $this->render('invoices/index.html.twig', [
            'invoices' => $this->invoiceService->getAll(),
        ]);
    }
}
