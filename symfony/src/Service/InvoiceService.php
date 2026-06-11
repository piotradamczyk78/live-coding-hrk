<?php

namespace App\Service;

use App\Entity\Customer;
use App\Entity\Invoice;
use App\Repository\CustomerRepository;
use App\Repository\InvoiceRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class InvoiceService
{
    public const STATUSES = ['draft', 'issued', 'paid', 'overdue', 'cancelled'];

    public function __construct(
        private readonly InvoiceRepository $invoiceRepository,
        private readonly CustomerRepository $customerRepository,
        private readonly EntityManagerInterface $entityManager,
    ) {}

    /**
     * @return list<Invoice>
     */
    public function getAll(): array
    {
        return $this->invoiceRepository->findAllOrdered();
    }

    /**
     * @return list<Customer>
     */
    public function getCustomers(): array
    {
        return $this->customerRepository->findAllOrdered();
    }

    public function find(int $id): Invoice
    {
        $invoice = $this->invoiceRepository->findOneWithCustomer($id);

        if ($invoice === null) {
            throw new NotFoundHttpException('Faktura nie została znaleziona.');
        }

        return $invoice;
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array{invoice: Invoice, errors: array<string, string>}
     */
    public function create(array $data): array
    {
        $errors = $this->validate($data);
        if ($errors !== []) {
            return ['invoice' => new Invoice(), 'errors' => $errors];
        }

        $customer = $this->customerRepository->find((int) $data['customer_id']);
        if ($customer === null) {
            return ['invoice' => new Invoice(), 'errors' => ['customer_id' => 'Wybrany klient nie istnieje.']];
        }

        $invoice = new Invoice();
        $this->fillInvoice($invoice, $data, $customer);
        $invoice->setCreatedAt(new \DateTime());

        $this->entityManager->persist($invoice);
        $this->entityManager->flush();

        return ['invoice' => $invoice, 'errors' => []];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array{invoice: Invoice, errors: array<string, string>}
     */
    public function update(Invoice $invoice, array $data): array
    {
        $errors = $this->validate($data, $invoice->getId());
        if ($errors !== []) {
            return ['invoice' => $invoice, 'errors' => $errors];
        }

        $customer = $this->customerRepository->find((int) $data['customer_id']);
        if ($customer === null) {
            return ['invoice' => $invoice, 'errors' => ['customer_id' => 'Wybrany klient nie istnieje.']];
        }

        $this->fillInvoice($invoice, $data, $customer);
        $this->entityManager->flush();

        return ['invoice' => $invoice, 'errors' => []];
    }

    public function delete(Invoice $invoice): void
    {
        $connection = $this->entityManager->getConnection();
        $id = $invoice->getId();

        $connection->transactional(function () use ($connection, $invoice, $id): void {
            $connection->executeStatement('DELETE FROM payments WHERE invoice_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM invoice_items WHERE invoice_id = ?', [$id]);
            $this->entityManager->remove($invoice);
            $this->entityManager->flush();
        });
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, string>
     */
    private function validate(array $data, ?int $ignoreId = null): array
    {
        $errors = [];

        $number = trim((string) ($data['number'] ?? ''));
        if ($number === '') {
            $errors['number'] = 'Numer faktury jest wymagany.';
        } elseif (mb_strlen($number) > 50) {
            $errors['number'] = 'Numer faktury może mieć maksymalnie 50 znaków.';
        } elseif ($this->invoiceRepository->existsByNumber($number, $ignoreId)) {
            $errors['number'] = 'Ten numer faktury jest już zajęty.';
        }

        $customerId = $data['customer_id'] ?? '';
        if ($customerId === '' || !ctype_digit((string) $customerId)) {
            $errors['customer_id'] = 'Klient jest wymagany.';
        }

        $amount = $data['amount'] ?? '';
        if ($amount === '' || !is_numeric($amount) || (float) $amount <= 0) {
            $errors['amount'] = 'Kwota musi być liczbą większą od zera.';
        }

        $status = (string) ($data['status'] ?? '');
        if (!in_array($status, self::STATUSES, true)) {
            $errors['status'] = 'Nieprawidłowy status faktury.';
        }

        foreach (['issued_at' => 'Data wystawienia', 'due_at' => 'Termin płatności'] as $field => $label) {
            $value = $data[$field] ?? '';
            if ($value !== '' && !preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $value)) {
                $errors[$field] = sprintf('%s ma nieprawidłowy format.', $label);
            }
        }

        return $errors;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function fillInvoice(Invoice $invoice, array $data, Customer $customer): void
    {
        $invoice
            ->setNumber(trim((string) $data['number']))
            ->setCustomer($customer)
            ->setAmount(number_format((float) $data['amount'], 2, '.', ''))
            ->setStatus((string) $data['status'])
            ->setIssuedAt($this->parseDate($data['issued_at'] ?? null))
            ->setDueAt($this->parseDate($data['due_at'] ?? null));
    }

    private function parseDate(mixed $value): ?\DateTimeInterface
    {
        if ($value === null || $value === '') {
            return null;
        }

        return new \DateTime((string) $value);
    }
}
