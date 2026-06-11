using HrkDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace HrkDemo.Data;

public sealed class HrkDbContext(DbContextOptions<HrkDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();

    public DbSet<Invoice> Invoices => Set<Invoice>();

    public DbSet<InvoiceItem> InvoiceItems => Set<InvoiceItem>();

    public DbSet<Payment> Payments => Set<Payment>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Customer>(entity =>
        {
            entity.ToTable("customers", "dbo");
            entity.Property(c => c.Id).HasColumnName("id");
            entity.Property(c => c.Name).HasColumnName("name").HasMaxLength(200);
            entity.Property(c => c.TaxId).HasColumnName("tax_id").HasMaxLength(20);
            entity.Property(c => c.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.ToTable("invoices", "dbo");
            entity.Property(i => i.Id).HasColumnName("id");
            entity.Property(i => i.Number).HasColumnName("number").HasMaxLength(50);
            entity.Property(i => i.CustomerId).HasColumnName("customer_id");
            entity.Property(i => i.Amount).HasColumnName("amount").HasPrecision(12, 2);
            entity.Property(i => i.Status).HasColumnName("status").HasMaxLength(20);
            entity.Property(i => i.IssuedAt).HasColumnName("issued_at");
            entity.Property(i => i.DueAt).HasColumnName("due_at");
            entity.Property(i => i.CreatedAt).HasColumnName("created_at");
            entity.HasOne(i => i.Customer)
                .WithMany(c => c.Invoices)
                .HasForeignKey(i => i.CustomerId);
        });

        modelBuilder.Entity<InvoiceItem>(entity =>
        {
            entity.ToTable("invoice_items", "dbo");
            entity.Property(i => i.Id).HasColumnName("id");
            entity.Property(i => i.InvoiceId).HasColumnName("invoice_id");
            entity.Property(i => i.Description).HasColumnName("description").HasMaxLength(300);
            entity.Property(i => i.Quantity).HasColumnName("quantity");
            entity.Property(i => i.UnitPrice).HasColumnName("unit_price").HasPrecision(12, 2);
            entity.Property(i => i.LineTotal).HasColumnName("line_total").HasPrecision(12, 2);
            entity.HasOne(i => i.Invoice)
                .WithMany()
                .HasForeignKey(i => i.InvoiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.ToTable("payments", "dbo");
            entity.Property(p => p.Id).HasColumnName("id");
            entity.Property(p => p.InvoiceId).HasColumnName("invoice_id");
            entity.Property(p => p.Amount).HasColumnName("amount").HasPrecision(12, 2);
            entity.Property(p => p.PaidAt).HasColumnName("paid_at");
            entity.Property(p => p.Method).HasColumnName("method").HasMaxLength(30);
            entity.HasOne(p => p.Invoice)
                .WithMany(i => i.Payments)
                .HasForeignKey(p => p.InvoiceId);
        });
    }
}
