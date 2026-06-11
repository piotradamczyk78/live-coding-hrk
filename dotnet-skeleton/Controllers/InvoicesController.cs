using HrkDemo.Services;
using HrkDemo.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace HrkDemo.Controllers;

public sealed class InvoicesController(InvoiceService invoiceService) : Controller
{
    [HttpGet("/invoices")]
    public async Task<IActionResult> Index(CancellationToken cancellationToken)
    {
        return View(await invoiceService.GetAllAsync(cancellationToken));
    }

    [HttpGet("/invoices/create")]
    public async Task<IActionResult> Create(CancellationToken cancellationToken)
    {
        return View(await BuildFormViewModelAsync(new InvoiceFormViewModel(), cancellationToken));
    }

    [HttpPost("/invoices")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(
        [Bind(Prefix = "Form")] InvoiceFormViewModel model,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return View(await BuildFormViewModelAsync(model, cancellationToken));
        }

        try
        {
            await invoiceService.CreateAsync(model, cancellationToken);
        }
        catch (InvalidOperationException ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(await BuildFormViewModelAsync(model, cancellationToken));
        }

        TempData["Success"] = "Faktura została dodana.";

        return RedirectToAction(nameof(Index));
    }

    [HttpGet("/invoices/{id:int}/edit")]
    public async Task<IActionResult> Edit(int id, CancellationToken cancellationToken)
    {
        var invoice = await invoiceService.FindAsync(id, cancellationToken);

        return View(await BuildFormViewModelAsync(new InvoiceFormViewModel
        {
            Id = invoice.Id,
            Number = invoice.Number,
            CustomerId = invoice.CustomerId,
            Amount = invoice.Amount,
            Status = invoice.Status,
            IssuedAt = invoice.IssuedAt,
            DueAt = invoice.DueAt,
        }, cancellationToken));
    }

    [HttpPost("/invoices/{id:int}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(
        int id,
        [Bind(Prefix = "Form")] InvoiceFormViewModel model,
        CancellationToken cancellationToken)
    {
        model.Id = id;

        if (!ModelState.IsValid)
        {
            return View(await BuildFormViewModelAsync(model, cancellationToken));
        }

        try
        {
            await invoiceService.UpdateAsync(id, model, cancellationToken);
        }
        catch (InvalidOperationException ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(await BuildFormViewModelAsync(model, cancellationToken));
        }

        TempData["Success"] = "Faktura została zaktualizowana.";

        return RedirectToAction(nameof(Index));
    }

    [HttpPost("/invoices/{id:int}/delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await invoiceService.DeleteAsync(id, cancellationToken);
        TempData["Success"] = "Faktura została usunięta.";

        return RedirectToAction(nameof(Index));
    }

    private async Task<InvoiceFormPageViewModel> BuildFormViewModelAsync(
        InvoiceFormViewModel model,
        CancellationToken cancellationToken)
    {
        var customers = await invoiceService.GetCustomersAsync(cancellationToken);

        return new InvoiceFormPageViewModel
        {
            Form = model,
            Customers = customers.Select(c => new SelectListItem(c.Name, c.Id.ToString())).ToList(),
            Statuses = InvoiceService.Statuses,
        };
    }
}

public sealed class InvoiceFormPageViewModel
{
    public InvoiceFormViewModel Form { get; init; } = new();

    public IReadOnlyList<SelectListItem> Customers { get; init; } = [];

    public IReadOnlyList<string> Statuses { get; init; } = [];
}
