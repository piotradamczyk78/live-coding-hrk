<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Invoice extends Model
{
    /**
     * Summary of UPDATED_AT
     * @var string|null
     */
    public const UPDATED_AT = null;

    /**
     * Summary of table
     * @var string
     */
    protected $table = 'invoices';

    /**
     * Summary of fillable
     * @var array<string>
     */
    protected $fillable = [
        'number',
        'customer_id',
        'amount',
        'status',
        'issued_at',
        'due_at',
    ];

    /**
     * Summary of casts
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'issued_at' => 'date',
            'due_at' => 'date',
            'created_at' => 'datetime',
        ];
    }

    /**
     * Summary of customer
     * @return BelongsTo<Customer, Invoice>
     */
    
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
}
