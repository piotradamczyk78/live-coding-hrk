<link rel="stylesheet" href="../styles/main.css">

# Baza wiedzy — Live Coding HRK

Dokumentacja przygotowawcza do rozmowy technicznej: **Programista .NET + PHP** (migracja legacy → PHP, systemy finansowe / business travel).

<div class="callout callout--info">
  <span class="badge">INFO</span>
  <p>Środowisko: <code>/Users/admin/Developer/Workspace/live-coding-hrk/</code>. Każdy temat ma osobny plik — nawiguj kartami poniżej lub linkami w stopce dokumentów.</p>
</div>

---

<a id="start-i-kontekst"></a>
<div class="section-break">Start i kontekst</div>

<div class="card-grid">

<div class="card">
  <div class="card-title"><a href="Kontekst-Roli.md">Kontekst roli</a></div>
  <div class="card-body">Czego się spodziewać na spotkaniu, prawdopodobieństwo tematów</div>
</div>

<div class="card">
  <div class="card-title"><a href="Szybki-Start.md">Szybki start</a></div>
  <div class="card-body">Bootstrap, verify, codzienne uruchomienie środowiska</div>
</div>

<div class="card">
  <div class="card-title"><a href="Komponenty-i-Dostep.md">Komponenty i dostęp</a></div>
  <div class="card-body">Porty, hosty, PostgreSQL, MS SQL, Adminer, GUI zewnętrzne</div>
</div>

<div class="card">
  <div class="card-title"><a href="Checklist-Spotkania.md">Checklist na spotkanie</a></div>
  <div class="card-body">15 min przed — technicznie, Cursor, merytorycznie</div>
</div>

</div>

---

<a id="infrastruktura"></a>
<div class="section-break">Infrastruktura</div>

<div class="card-grid">

<div class="card">
  <div class="card-title"><a href="Makefile.md">Makefile</a></div>
  <div class="card-body">Skróty: up, verify, psql, mssql, laravel, symfony</div>
</div>

<div class="card">
  <div class="card-title"><a href="Docker.md">Docker</a></div>
  <div class="card-body">Logi, exec, restart, czyszczenie, sqlcmd</div>
</div>

<div class="card">
  <div class="card-title"><a href="Bitwarden-Secrets.md">Bitwarden Secrets</a></div>
  <div class="card-body">Placeholdery {{bw:...}}, runtime env, bezpieczeństwo</div>
</div>

<div class="card">
  <div class="card-title"><a href="Rozwiazywanie-Problemow.md">Rozwiązywanie problemów</a></div>
  <div class="card-body">Kontenery, porty, Laravel/Symfony DB, MS SQL</div>
</div>

<div class="card">
  <div class="card-title"><a href="Struktura-Katalogow.md">Struktura katalogów</a></div>
  <div class="card-body">Mapa repozytorium live-coding-hrk</div>
</div>

</div>

---

<a id="bazy-danych"></a>
<div class="section-break">Bazy danych</div>

<div class="card-grid">

<div class="card">
  <div class="card-title"><a href="PostgreSQL.md">PostgreSQL</a></div>
  <div class="card-body">psql, zapytania, transakcje, przeładowanie schematu</div>
</div>

<div class="card">
  <div class="card-title"><a href="MSSQL.md">MS SQL (T-SQL)</a></div>
  <div class="card-body">sqlcmd, init-mssql, procedury, połączenie z GUI</div>
</div>

<div class="card">
  <div class="card-title"><a href="PostgreSQL-vs-MSSQL.md">PostgreSQL vs MS SQL</a></div>
  <div class="card-body">Różnice składni, typy, daty, transakcje</div>
</div>

<div class="card">
  <div class="card-title"><a href="Model-Danych.md">Model danych</a></div>
  <div class="card-body">Tabele ćwiczeniowe, przykładowe faktury</div>
</div>

</div>

---

<a id="frameworki-i-aplikacje"></a>
<div class="section-break">Frameworki i aplikacje</div>

<div class="card-grid">

<div class="card">
  <div class="card-title"><a href="Laravel.md">Laravel</a></div>
  <div class="card-body">Artisan, tinker, routing API, CRUD faktur</div>
</div>

<div class="card">
  <div class="card-title"><a href="Symfony.md">Symfony</a></div>
  <div class="card-body">Console, Doctrine, routing, CRUD faktur</div>
</div>

<div class="card">
  <div class="card-title"><a href="DotNet.md">.NET 10</a></div>
  <div class="card-body">MVC + EF Core na MS SQL, migracje, API</div>
</div>

</div>

---

<a id="cwiczenia-i-migracja"></a>
<div class="section-break">Ćwiczenia i migracja</div>

<div class="card-grid">

<div class="card">
  <div class="card-title"><a href="Cwiczenia.md">Ćwiczenia</a></div>
  <div class="card-body">7 zadań SQL/PHP/API, wzorzec architektury</div>
</div>

<div class="card">
  <div class="card-title"><a href="Migracja-DotNet-PHP.md">Migracja .NET → PHP</a></div>
  <div class="card-body">Strangler Fig, ACL, integralność danych, pytania do rekrutera</div>
</div>

<div class="card">
  <div class="card-title"><a href="Git.md">Git</a></div>
  <div class="card-body">Status, branch, commit, stash — na live coding</div>
</div>

</div>

---

<div class="section-break">Ścieżki nauki</div>

<div class="callout callout--tip">
  <span class="badge">RADA</span>
  <p><strong>Przed spotkaniem SQL + PHP</strong> — przejdź: Model danych → PostgreSQL → Ćwiczenia → Laravel lub Symfony.</p>
</div>

**Chcę przygotować się do zadań SQL**

```
Model-Danych → PostgreSQL → MSSQL → PostgreSQL-vs-MSSQL → Ćwiczenia
```

**Chcę przygotować endpoint REST**

```
Cwiczenia → Laravel / Symfony → Model-Danych → Git
```

**Chcę mówić o migracji .NET → PHP**

```
Kontekst-Roli → Migracja-DotNet-PHP → PostgreSQL-vs-MSSQL → DotNet
```

**Chcę uruchomić środowisko od zera**

```
Szybki-Start → Bitwarden-Secrets → Makefile → Checklist-Spotkania
```
