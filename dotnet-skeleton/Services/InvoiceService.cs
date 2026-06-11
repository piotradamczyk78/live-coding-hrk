using HrkDemo.Data;
using HrkDemo.Models;
using HrkDemo.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace HrkDemo.Services;

public sealed class InvoiceService(HrkDbContext db)
{
    public static readonly string[] Statuses =
        ["draft", "issued", "paid", "overdue", "cancelled"];

    public async Task<IReadOnlyList<Invoice>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await db.Invoices
            .AsNoTracking()
            .Include(i => i.Customer)
            .OrderBy(i => i.Id)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Customer>> GetCustomersAsync(CancellationToken cancellationToken = default)
    {
        return await db.Customers
            .AsNoTracking()
            .OrderBy(c => c.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<Invoice> FindAsync(int id, CancellationToken cancellationToken = default)
    {
        return await db.Invoices
            .Include(i => i.Customer)
            .FirstAsync(i => i.Id == id, cancellationToken);
    }

    public async Task<Invoice> CreateAsync(InvoiceFormViewModel model, CancellationToken cancellationToken = default)
    {
        await EnsureCustomerExistsAsync(model.CustomerId, cancellationToken);
        await EnsureUniqueNumberAsync(model.Number, null, cancellationToken);

        var invoice = new Invoice
        {
            Number = model.Number.Trim(),
            CustomerId = model.CustomerId,
            Amount = model.Amount,
            Status = model.Status,
            IssuedAt = model.IssuedAt,
            DueAt = model.DueAt,
            CreatedAt = DateTime.UtcNow,
        };

        db.Invoices.Add(invoice);
        await db.SaveChangesAsync(cancellationToken);

        return await FindAsync(invoice.Id, cancellationToken);
    }

    public async Task<Invoice> UpdateAsync(int id, InvoiceFormViewModel model, CancellationToken cancellationToken = default)
    {
        var invoice = await db.Invoices.FirstAsync(i => i.Id == id, cancellationToken);

        await EnsureCustomerExistsAsync(model.CustomerId, cancellationToken);
        await EnsureUniqueNumberAsync(model.Number, id, cancellationToken);

        invoice.Number = model.Number.Trim();
        invoice.CustomerId = model.CustomerId;
        invoice.Amount = model.Amount;
        invoice.Status = model.Status;
        invoice.IssuedAt = model.IssuedAt;
        invoice.DueAt = model.DueAt;

        await db.SaveChangesAsync(cancellationToken);

        return await FindAsync(id, cancellationToken);
    }

    public async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);

        await db.Payments.Where(p => p.InvoiceId == id).ExecuteDeleteAsync(cancellationToken);
        await db.InvoiceItems.Where(i => i.InvoiceId == id).ExecuteDeleteAsync(cancellationToken);
        await db.Invoices.Where(i => i.Id == id).ExecuteDeleteAsync(cancellationToken);

        await transaction.CommitAsync(cancellationToken);
    }

    public async Task<bool> NumberExistsAsync(string number, int? ignoreId, CancellationToken cancellationToken = default)
    {
        var query = db.Invoices.AsNoTracking().Where(i => i.Number == number.Trim());

        if (ignoreId is not null)
        {
            query = query.Where(i => i.Id != ignoreId);
        }

        return await query.AnyAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<object>> GetUnpaidInvoicesAsync(CancellationToken cancellationToken = default)
    {
        var invoices = await db.Invoices
            .AsNoTracking()
            .Include(i => i.Customer)
            .Include(i => i.Payments)
            .Where(i => i.Status != "cancelled" && i.Status != "draft")
            .OrderBy(i => i.Id)
            .ToListAsync(cancellationToken);

        return invoices
            .Select(i =>
            {
                var paidTotal = i.Payments.Sum(p => p.Amount);
                return new
                {
                    invoice_number = i.Number,
                    customer_name = i.Customer.Name,
                    amount = i.Amount,
                    paid_total = paidTotal,
                    remaining = i.Amount - paidTotal,
                };
            })
            .Where(i => i.paid_total < i.amount)
            .Cast<object>()
            .ToList();
    }

    public async Task<object> CreatePaymentAsync(
        int invoiceId,
        decimal amount,
        string method,
        CancellationToken cancellationToken = default)
    {
        if (amount <= 0)
        {
            throw new InvalidOperationException("Amount must be greater than zero.");
        }

        var invoice = await db.Invoices
            .Include(i => i.Payments)
            .FirstOrDefaultAsync(i => i.Id == invoiceId, cancellationToken)
            ?? throw new InvalidOperationException("Invoice not found.");

        if (invoice.Status == "cancelled")
        {
            throw new InvalidOperationException("Cannot add payment to cancelled invoice.");
        }

        db.Payments.Add(new Payment
        {
            InvoiceId = invoiceId,
            Amount = amount,
            Method = method,
            PaidAt = DateTime.UtcNow,
        });

        var paidTotal = invoice.Payments.Sum(p => p.Amount) + amount;
        if (paidTotal >= invoice.Amount)
        {
            invoice.Status = "paid";
        }

        await db.SaveChangesAsync(cancellationToken);

        return new
        {
            ok = true,
            invoice_id = invoiceId,
            paid_total = paidTotal,
            status = invoice.Status,
            method,
        };
    }

    private async Task EnsureCustomerExistsAsync(int customerId, CancellationToken cancellationToken)
    {
        if (!await db.Customers.AnyAsync(c => c.Id == customerId, cancellationToken))
        {
            throw new InvalidOperationException("Wybrany klient nie istnieje.");
        }
    }

    private async Task EnsureUniqueNumberAsync(string number, int? ignoreId, CancellationToken cancellationToken)
    {
        if (await NumberExistsAsync(number, ignoreId, cancellationToken))
        {
            throw new InvalidOperationException("Ten numer faktury jest już zajęty.");
        }
    }
}
