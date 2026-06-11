<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    /**
     * Summary of table
     * @var string
     */
    protected $table = 'customers';

    /**
     * Summary of fillable
     * @var array<string>
     */
    protected $fillable = [
        'name',
        'tax_id',
    ];

    /**
     * Summary of casts
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
        ];
    }

    /**
     * Summary of invoices
     * @return HasMany<Invoice, Customer>
     */
    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }
}
