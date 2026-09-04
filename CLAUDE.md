# CLAUDE.md — Vegolo

Detta dokument ger Claude Code kontext om Vegolo som projekt och företag. Läs det helt innan du börjar arbeta, och håll det uppdaterat när viktiga beslut fattas (tech stack, produktsortiment, varumärkesriktlinjer etc.) — det här filen är projektets "minne" mellan sessioner.

## 1. Om företaget

**Vegolo** (AB under bildande) är ett svenskt bolag som utvecklar och säljer kosttillskott riktade till veganer, vegetarianer och flexitarianer, med Sverige som första marknad (Norden på sikt).

**Vegolo är inte bara ett vinstdrivet bolag.** Grundarens uttalade syfte är att ha en genuint positiv påverkan för personer som lever växtbaserat och för djurrättsrörelsen. Det här är inte ett marknadsföringsbudskap som lagts på i efterhand — det är en del av varför bolaget finns, och det ska genomsyra produktbeslut, kommunikation och kod (t.ex. hur donationsspårning och transparens byggs in på webbplatsen).

**Central mekanism:** en del av intäkten från varje köp doneras till en etablerad djurrättsorganisation (t.ex. Djurens Rätt, som har 90-konto och granskas av Svensk Insamlingskontroll). Detta ska kommuniceras transparent på webbplatsen — inte gömmas — och webbplatsen bör på sikt ha en publik "Vår påverkan"-sida som visar totalt donerat belopp.

## 2. Nuvarande fas

**Fas 1 (detta projekt): bygg webbplatsen/webbutiken.**

Företaget är i en tidig uppstartsfas. Innan detta projekt har grundaren tagit fram:
- Marknads- och konkurrentanalys (svensk marknad för veganska kosttillskott)
- Regulatorisk kartläggning (EU-regler för kosttillskott, Novel Food-status, svensk registrering)
- Leverantörsstrategi: **white label**-tillverkning (färdiga standardformuleringar, eget varumärke/etikett) för att hålla lanseringskostnaden låg
- En affärsplan och kostnadsbudget

Webbutiken byggs **inte** på Shopify — grundaren vill äga en egen, anpassad lösning från start.

## 3. Lanseringssortiment (3 SKU:er)

| Produkt | Form | Varför |
|---|---|---|
| Vegansk B12 (metylkobalamin) | Kapslar | Mest kritiska tillskottet för veganer |
| Vegansk D3 (lavbaserad, ej lanolin) | Kapslar | Vanlig D3 är ofta animalisk (lanolin/ull) |
| Omega-3 (algolja, Schizochytrium) | Mjukgel | EPA/DHA finns annars nästan bara i fisk-/krillolja |

Dessa tre produkter är utgångspunkten för produktdatamodellen — bygg inte en generisk "hundratals produkter"-e-handelsstruktur i onödan tidigt, men lås inte heller fast antalet till exakt 3 i koden (fler produkter tillkommer efter validering).

## 4. Regulatoriska hänsyn som påverkar koden och innehållet

Dessa är **inte förslag, utan krav** som produktsidor, kassaflöde och innehåll måste respektera:

- **Hälsopåståenden:** endast EU/EFSA-godkända hälsopåståenden får förekomma i produkttexter eller marknadsföring (t.ex. "bidrar till normal funktion av immunsystemet" om godkänt för ingrediensen — inga fria påståenden som "botar", "stärker" utan godkänd formulering). Innehållsteamet (människa) ansvarar för exakt text, men bygg CMS/innehållsstruktur så att produkttexter enkelt kan granskas och uppdateras, inte hårdkodas djupt i komponenter.
- **Obligatorisk produktinformation** på varje produktsida: rekommenderat dagligt intag, varningstext (t.ex. "bör inte ersätta en varierad och balanserad kost och en hälsosam livsstil"), fullständig ingredienslista, nettokvantitet.
- **Prisvisning:** priser ska visas inklusive moms för konsumenter (B2C). Nuvarande momssats på kosttillskott (livsmedel) är **6 %** (tillfälligt sänkt 1 april 2026–31 december 2027, återgår till 12 % från 1 januari 2028) — bygg momshanteringen konfigurerbar, inte hårdkodad, eftersom satsen ändras 2028.
- **Vegansk dokumentation:** produktsidorna bör kunna visa/länka källdokumentation (t.ex. att D3 kommer från lav, att omega-3-oljan kommer från en EU-godkänd Schizochytrium-stam) — bygg gärna in ett enkelt sätt att attachera certifikat/dokumentation per produkt i datamodellen.
- **GDPR:** all kundhantering (konton, nyhetsbrev, kassaflöde) måste vara GDPR-korrekt (svensk/EU-marknad) — samtyckeshantering, dataminimering, tydlig integritetspolicy.
- **Donationstransparens:** om/när donationsfunktionen byggs (t.ex. en räknare eller kvartalsvis rapport), se till att beloppen är spårbara och verifierbara — inte bara ett hårdkodat marknadsföringstal.

## 5. Varumärke och tonalitet

- **Inte** "generisk hälsokost"-estetik. Målet är en modern, ren, förtroendeingivande identitet som sticker ut från de etablerade "vegan-sidolinjerna" hos större varumärken.
- Transparens är ett kärnvärde — källor, certifieringar (mål: V-Label på sikt) och donationsdata ska vara lätta att hitta, inte gömda i en FAQ.
- Målgrupp: veganer, vegetarianer, flexitarianer och personer engagerade i djurrättsfrågor i Sverige. Skriv och designa för en målgrupp som redan bryr sig — inte för att övertyga skeptiker om att växtbaserat är bra.

## 6. Teknikstack

**Status: bekräftad med grundaren 2026-09-04.** Hosting är det enda som medvetet lämnats öppet.

- **Framework: Next.js 16** (React 19, TypeScript, App Router, Turbopack). **Låst.** Valdes framför Astro för större ekosystem och för att samma projekt ska rymma både innehållssidor och en kommande kassa.
- **Styling: Tailwind CSS v4.** **Låst.** Designtokens (färg, typografi) definieras samlat i `src/app/globals.css` under `@theme` — ändra profilen där, inte i enskilda komponenter.
- **Betalning: Stripe med hostad kassa (Stripe Checkout).** **Låst som riktning, inte byggd ännu.** Ska konfigureras för kort, Klarna och Swish. Hostad kassa valdes för att Vegolo aldrig ska hantera kortdata själv (minimerar PCI-ansvar) och för att komma live snabbare. Avvägningen är mindre designkontroll på just betalsteget.
- **Produktdata: typade innehållsfiler i repot** (`src/content/products/`). **Låst.** Motivet är regulatoriskt lika mycket som tekniskt: varje ändring av en varningstext eller ett hälsopåstående får datum och spårbar historik i Git. Datamodellen är byggd så att ett CMS kan ersätta filerna senare utan att sidorna skrivs om — bara `src/lib/products/index.ts` behöver då ändras.
- **Hosting: INTE beslutad.** Två realistiska alternativ när lansering närmar sig:
  - *Vercel Pro, ca 20 USD/mån.* Enklaste vägen för Next.js. Obs: gratisnivån Hobby får enligt Vercels villkor inte användas kommersiellt, så en butik kräver Pro — budgetera för det.
  - *Cloudflare Pages/Workers.* Kommersiell användning tillåten på gratisnivån och billigare på sikt, men kräver mer konfiguration och vissa Next-funktioner beter sig annorlunda.

  Inget i koden låser fast valet.

## 7. Repo och arbetssätt

- GitHub: `Erik-Edward/Vegolo`. Huvudgren: **`main`** (bekräftad).
- **Commit-meddelanden skrivs på engelska** (bekräftat 2026-09-04). Kod, kommentarer och allt kundvänt innehåll skrivs på svenska.
- **Fråga innan stora arkitekturbeslut** (databas, betalningsflöde, tredjepartsintegrationer) — grundaren är inte utvecklare i grunden, så förklara avvägningar i vanligt språk snarare än att anta att val är självklara.
- Produktinnehåll (texter, priser, ingredienslistor) hålls separerat från kodlogik. All produktdata ligger i `src/content/`, alla sajttexter i `src/content/site.ts`. Komponenter innehåller ingen produkttext.
- Uppdatera denna CLAUDE.md-fil när viktiga beslut fattas så att kontexten inte går förlorad mellan sessioner.

## 8. Kodstruktur och regulatoriska skyddsnät

Scaffoldingen är byggd så att de regulatoriska kraven i avsnitt 4 upprätthålls av koden, inte av att någon kommer ihåg dem:

| Var | Vad |
|---|---|
| `src/lib/products/types.ts` | Datamodellen. Obligatoriska uppgifter (rekommenderat dagligt intag, varningstext, ingredienser, nettokvantitet) är obligatoriska även i TypeScript — **bygget failar** om en produkt saknar dem. |
| `src/lib/products/regulatory.ts` | De tre lagstadgade varningarna läggs på **automatiskt** för varje produkt. Hälsopåståenden med status `draft` filtreras bort i produktionsbygget och kan alltså inte råka publiceras. |
| `src/lib/tax.ts` | Momssatser med giltighetsperiod. 6 % gäller 2026-04-01–2027-12-31, 12 % från 2028-01-01 — **återgången 2028 kräver ingen kodändring.** Priser lagras i öre inklusive moms; nettot räknas fram. |
| `src/content/products/*.ts` | En fil per produkt. Här redigeras texter, priser och ingredienslistor. |
| `src/content/site.ts` | Varumärkestexter och donationskonfiguration. |
| `src/app/produkter/[slug]/page.tsx` | En mall som renderar hela sortimentet. Ny produkt = ny innehållsfil, ingen sidkod. |

Miljövariabler för förhandsgranskning finns dokumenterade i `.env.example` (bl.a. en momsoverride för att se hur sajten ser ut efter 2028).

**Allt textinnehåll i scaffoldingen är platshållare** och måste ersättas innan lansering. Hälsopåståendena ligger inne som utkast med källhänvisning men är inte granskade — de måste stämmas av ord för ord mot EU:s register och sättas till `approved` av en människa.

## 9. Vad som INTE är klart än (fråga grundaren, anta inte)

- **Hosting** (se avsnitt 6)
- Slutgiltigt varumärkesnamn för produkterna på förpackning kontra webbplats (om det skiljer sig från "Vegolo")
- Slutlig produktfotografering och grafisk profil (grundaren tar fram detta själv — färger och typografi i `globals.css` är ett provisoriskt utgångsläge)
- Exakt donationsbelopp/mekanism per köp och vilken organisation som slutgiltigt väljs — modellerat som `null` i `src/content/site.ts`, och gränssnittet skriver ut att det beslutas i stället för att visa en påhittad siffra
- Om nyhetsbrev/kundkonto ska finnas från lansering eller läggas till senare
- Leverantörsspecifikationer: alla produktuppgifter (doser, ingredienser, nettovikt) är platshållare tills white label-leverantörens specifikation finns

## 10. Next.js-specifika regler

@AGENTS.md
