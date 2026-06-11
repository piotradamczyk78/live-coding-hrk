<?php

namespace App\Repository;

use App\Entity\Invoice;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Invoice>
 */
class InvoiceRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Invoice::class);
    }

    /**
     * @return list<Invoice>
     */
    public function findAllOrdered(): array
    {
        return $this->createQueryBuilder('i')
            ->leftJoin('i.customer', 'c')
            ->addSelect('c')
            ->orderBy('i.id', 'ASC')
            ->getQuery()
            ->getResult();
    }

    public function findOneWithCustomer(int $id): ?Invoice
    {
        return $this->createQueryBuilder('i')
            ->leftJoin('i.customer', 'c')
            ->addSelect('c')
            ->where('i.id = :id')
            ->setParameter('id', $id)
            ->getQuery()
            ->getOneOrNullResult();
    }

    public function existsByNumber(string $number, ?int $ignoreId = null): bool
    {
        $qb = $this->createQueryBuilder('i')
            ->select('COUNT(i.id)')
            ->where('i.number = :number')
            ->setParameter('number', $number);

        if ($ignoreId !== null) {
            $qb->andWhere('i.id != :id')->setParameter('id', $ignoreId);
        }

        return (int) $qb->getQuery()->getSingleScalarResult() > 0;
    }
}
