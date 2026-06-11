<?php

namespace App\Controller;

use App\Entity\Invoice;
use App\Service\InvoiceService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/invoices')]
class InvoiceController extends AbstractController
{
    public function __construct(
        private readonly InvoiceService $invoiceService,
    ) {}

    #[Route('', name: 'invoices_index', methods: ['GET'])]
    public function index(): Response
    {
        return $this->render('invoices/index.html.twig', [
            'invoices' => $this->invoiceService->getAll(),
        ]);
    }

    #[Route('/new', name: 'invoices_new', methods: ['GET'])]
    public function new(): Response
    {
        return $this->render('invoices/new.html.twig', [
            'customers' => $this->invoiceService->getCustomers(),
            'statuses' => InvoiceService::STATUSES,
            'invoice' => null,
            'errors' => [],
        ]);
    }

    #[Route('', name: 'invoices_create', methods: ['POST'])]
    public function create(Request $request): Response
    {
        $result = $this->invoiceService->create($request->request->all());

        if ($result['errors'] !== []) {
            return $this->render('invoices/new.html.twig', [
                'customers' => $this->invoiceService->getCustomers(),
                'statuses' => InvoiceService::STATUSES,
                'invoice' => $result['invoice'],
                'errors' => $result['errors'],
                'formData' => $request->request->all(),
            ], new Response('', Response::HTTP_UNPROCESSABLE_ENTITY));
        }

        $this->addFlash('success', 'Faktura została dodana.');

        return $this->redirectToRoute('invoices_index');
    }

    #[Route('/{id}/edit', name: 'invoices_edit', methods: ['GET'], requirements: ['id' => '\d+'])]
    public function edit(int $id): Response
    {
        return $this->render('invoices/edit.html.twig', [
            'invoice' => $this->invoiceService->find($id),
            'customers' => $this->invoiceService->getCustomers(),
            'statuses' => InvoiceService::STATUSES,
            'errors' => [],
        ]);
    }

    #[Route('/{id}', name: 'invoices_update', methods: ['POST'], requirements: ['id' => '\d+'])]
    public function update(int $id, Request $request): Response
    {
        $invoice = $this->invoiceService->find($id);
        $result = $this->invoiceService->update($invoice, $request->request->all());

        if ($result['errors'] !== []) {
            return $this->render('invoices/edit.html.twig', [
                'invoice' => $invoice,
                'customers' => $this->invoiceService->getCustomers(),
                'statuses' => InvoiceService::STATUSES,
                'errors' => $result['errors'],
                'formData' => $request->request->all(),
            ], new Response('', Response::HTTP_UNPROCESSABLE_ENTITY));
        }

        $this->addFlash('success', 'Faktura została zaktualizowana.');

        return $this->redirectToRoute('invoices_index');
    }

    #[Route('/{id}/delete', name: 'invoices_delete', methods: ['POST'], requirements: ['id' => '\d+'])]
    public function delete(int $id, Request $request): Response
    {
        $invoice = $this->invoiceService->find($id);

        if (!$this->isCsrfTokenValid('delete'.$invoice->getId(), (string) $request->request->get('_token'))) {
            throw new AccessDeniedHttpException('Nieprawidłowy token CSRF.');
        }

        $this->invoiceService->delete($invoice);
        $this->addFlash('success', 'Faktura została usunięta.');

        return $this->redirectToRoute('invoices_index');
    }
}
