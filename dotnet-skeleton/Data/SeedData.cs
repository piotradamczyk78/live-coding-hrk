using HrkDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace HrkDemo.Data;

public static class SeedData
{
    public static async Task InitializeAsync(HrkDbContext db, CancellationToken cancellationToken = default)
    {
        if (await db.Customers.AnyAsync(cancellationToken))
        {
            return;
        }

        var acme = new Customer { Name = "Acme Travel Sp. z o.o.", TaxId = "PL1234567890", CreatedAt = DateTime.UtcNow };
        var globex = new Customer { Name = "Globex Business Trips", TaxId = "PL9876543210", CreatedAt = DateTime.UtcNow };
        var wayfarer = new Customer { Name = "Wayfarer Consulting", TaxId = "PL5555555555", CreatedAt = DateTime.UtcNow };

        db.Customers.AddRange(acme, globex, wayfarer);
        await db.SaveChangesAsync(cancellationToken);

        var invoices = new[]
        {
            new Invoice { Number = "FV/2026/001", CustomerId = acme.Id, Amount = 12500m, Status = "issued", IssuedAt = new DateOnly(2026, 1, 10), DueAt = new DateOnly(2026, 2, 10), CreatedAt = DateTime.UtcNow },
            new Invoice { Number = "FV/2026/002", CustomerId = acme.Id, Amount = 8400m, Status = "paid", IssuedAt = new DateOnly(2026, 1, 5), DueAt = new DateOnly(2026, 2, 5), CreatedAt = DateTime.UtcNow },
            new Invoice { Number = "FV/2026/003", CustomerId = globex.Id, Amount = 22000m, Status = "overdue", IssuedAt = new DateOnly(2025, 11, 1), DueAt = new DateOnly(2025, 12, 1), CreatedAt = DateTime.UtcNow },
            new Invoice { Number = "FV/2026/004", CustomerId = wayfarer.Id, Amount = 3100m, Status = "draft", CreatedAt = DateTime.UtcNow },
            new Invoice { Number = "FV/2026/005", CustomerId = globex.Id, Amount = 5600m, Status = "issued", IssuedAt = new DateOnly(2026, 2, 1), DueAt = new DateOnly(2026, 3, 1), CreatedAt = DateTime.UtcNow },
        };

        db.Invoices.AddRange(invoices);
        await db.SaveChangesAsync(cancellationToken);

        db.InvoiceItems.AddRange(
            new InvoiceItem { InvoiceId = invoices[0].Id, Description = "Rezerwacja hotelu — Warszawa", Quantity = 5, UnitPrice = 500m, LineTotal = 2500m },
            new InvoiceItem { InvoiceId = invoices[0].Id, Description = "Bilety lotnicze", Quantity = 10, UnitPrice = 1000m, LineTotal = 10000m },
            new InvoiceItem { InvoiceId = invoices[1].Id, Description = "Pakiet konferencyjny", Quantity = 2, UnitPrice = 4200m, LineTotal = 8400m },
            new InvoiceItem { InvoiceId = invoices[2].Id, Description = "Delegacja zagraniczna", Quantity = 4, UnitPrice = 5500m, LineTotal = 22000m },
            new InvoiceItem { InvoiceId = invoices[3].Id, Description = "Konsultacja travel policy", Quantity = 1, UnitPrice = 3100m, LineTotal = 3100m },
            new InvoiceItem { InvoiceId = invoices[4].Id, Description = "Transfer lotniskowy", Quantity = 14, UnitPrice = 400m, LineTotal = 5600m });

        db.Payments.AddRange(
            new Payment { InvoiceId = invoices[1].Id, Amount = 8400m, PaidAt = new DateTime(2026, 1, 20, 10, 0, 0, DateTimeKind.Utc), Method = "transfer" },
            new Payment { InvoiceId = invoices[0].Id, Amount = 5000m, PaidAt = new DateTime(2026, 1, 25, 14, 30, 0, DateTimeKind.Utc), Method = "transfer" },
            new Payment { InvoiceId = invoices[2].Id, Amount = 800m, PaidAt = new DateTime(2025, 12, 10, 9, 0, 0, DateTimeKind.Utc), Method = "transfer" });

        await db.SaveChangesAsync(cancellationToken);
    }
}
