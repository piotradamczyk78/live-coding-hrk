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
}
