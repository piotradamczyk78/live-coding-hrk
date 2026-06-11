<link rel="stylesheet" href="../styles/main.css">

# .NET 10

<!-- nav -->
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)

`dotnet-skeleton/` — MVC (CRUD faktur) + Web API na **MS SQL** (EF Core).

## Menu wsparcia (interaktywne)

```bash
make dotnet-support    # lista komend → wpisz numer → wykonaj
```

## Instalacja SDK

```bash
brew install --cask dotnet-sdk
dotnet --version   # 10.x
```

## Uruchomienie

```bash
cd dotnet-skeleton
export MSSQL_SA_PASSWORD="$(grep MSSQL_SA_PASSWORD ../.secrets/defaults.env | cut -d= -f2)"
dotnet restore
dotnet ef database update   # migracje EF Core
dotnet run                  # http://localhost:5000
dotnet watch run            # auto-reload
```

## Interfejs webowy (CRUD)

| Akcja | URL |
|---|---|
| Lista | http://localhost:5000/invoices |
| Nowa faktura | http://localhost:5000/invoices/create |
| Edycja | http://localhost:5000/invoices/{id}/edit |

<a id="widoki-razor-przebudowa-cache"></a>

## Widoki Razor — przebudowa i cache

Projekt używa MVC + Razor (`Views/`). Domyślnie widoki kompilują się przy `dotnet build` — po zmianie `.cshtml` trzeba przebudować aplikację (lub użyć `dotnet watch run`).

<div class="callout callout--tip">
  <span class="badge">RADA</span>
  <p>Na co dzień wystarczy <code>dotnet watch run</code> + twarde odświeżenie przeglądarki (<strong>Cmd+Shift+R</strong>).</p>
</div>

### Szybko (dev)

```bash
cd dotnet-skeleton

# zatrzymaj stary proces (jeśli port zajęty)
lsof -ti :5000 | xargs kill -9 2>/dev/null

dotnet watch run   # auto-reload po zmianie widoków i kodu C#
```

### Pełne czyszczenie cache builda

Gdy widok „nie wchodzi” mimo zmian:

```bash
cd dotnet-skeleton

dotnet clean
rm -rf bin obj

dotnet restore
dotnet build
dotnet run
```

Katalog `obj/` trzyma m.in. skompilowane widoki Razor — `rm -rf bin obj` to najpewniejszy reset.

### Przeglądarka

- twarde odświeżenie: **Cmd+Shift+R** (Mac) / **Ctrl+Shift+R**
- DevTools → Network → **Disable cache** (przy otwartych narzędziach)

### Widoki bez restartu (opcjonalnie)

Żeby edytować `.cshtml` „na żywo” bez pełnego rebuildu:

```bash
dotnet add package Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation
```

W `Program.cs`:

```csharp
builder.Services.AddControllersWithViews()
    .AddRazorRuntimeCompilation();
```

Wtedy w `Development` wystarczy zapisać plik i odświeżyć stronę.

<div class="callout callout--info">
  <span class="badge">INFO</span>
  <p>W tym projekcie nie ma osobnego polecenia „cache:clear” jak w Symfony. Problemy z widokami zwykle wynikają ze starego procesu <code>dotnet run</code>, katalogów <code>bin/obj</code> lub cache przeglądarki.</p>
</div>

<a id="procesy-dotnet"></a>

## Procesy dotnet

Gdy port jest zajęty lub wiszą stare instancje `dotnet run` / `dotnet watch`:

### Wyświetl wszystkie procesy

```bash
pgrep -lf dotnet
```

Szczegółowo (PID, użytkownik, komenda):

```bash
ps aux | grep [d]otnet
```

Tylko procesy z tego projektu:

```bash
ps aux | grep [d]otnet | grep live-coding-hrk
```

### Który proces trzyma port

```bash
lsof -i :5000
lsof -i :5050
```

### Zatrzymanie procesu

```bash
kill <PID>              # grzeczne zakończenie
kill -9 <PID>           # gdy nie reaguje

lsof -ti :5000 | xargs kill -9 2>/dev/null   # zabij to, co trzyma port 5000
pkill -f dotnet         # wszystkie procesy dotnet (ostrożnie)
```

## API (ćwiczenia)

```bash
curl http://localhost:5000/api/invoices/unpaid
curl http://localhost:5000/api/invoices/unpaid | jq

curl -X POST http://localhost:5000/api/invoices/1/payments \
  -H 'Content-Type: application/json' \
  -d '{"amount": 7500, "method": "transfer"}'
```

## Migracje EF Core

```bash
dotnet ef migrations add NazwaMigracji
dotnet ef database update
```

Przy starcie aplikacja wywołuje `Database.MigrateAsync()` + seed danych.

## Connection string

```
Server=localhost,1433;Database=hrk_demo;User Id=sa;Password=<MSSQL_SA_PASSWORD>;TrustServerCertificate=True;Encrypt=False
```

Hasło z env: `MSSQL_SA_PASSWORD`.

## Architektura

```
InvoicesController → InvoiceService → HrkDbContext (EF Core) → MS SQL
Minimal API: /api/invoices/unpaid, /api/invoices/{id}/payments
```

## Ściąga C# / ASP.NET Core

```
Controller → Service → DbContext (EF Core)
async/await, IEnumerable<T>, LINQ
Migracje EF Core
Legacy: Web Forms / MVC vs ASP.NET Core
VB i C# — ten sam CLR
```

## Powiązane

- [MS SQL](MSSQL.md)
- [Migracja .NET → PHP](Migracja-DotNet-PHP.md)
- [Rozwiązywanie problemów](Rozwiazywanie-Problemow.md)

---
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)
