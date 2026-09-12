/**
 * Varumärkes- och sajttexter.
 *
 * PLATSHÅLLARE: all copy nedan är utkast och ska ersättas när den grafiska
 * profilen och de slutliga texterna är klara. Texterna ligger här och inte
 * i komponenterna så att de kan uppdateras utan att röra kod.
 */

export const site = {
  name: "Vegolo",
  /** Kort positionering. Får inte innehålla hälsopåståenden. */
  tagline: "Kosttillskott för dig som lever växtbaserat",
  description:
    "Vegolo utvecklar kosttillskott för veganer, vegetarianer och flexitarianer. Öppet om innehåll, ursprung och vart pengarna går.",
  /** Sätts när domänen är klar — används för kanoniska länkar och OG-taggar. */
  url: "https://vegolo.se",
  locale: "sv-SE",
} as const;

/**
 * Startsidans texter.
 *
 * Rubriker skrivs utan avslutande punkt: den gröna Vegolo-punkten läggs på av
 * <Punkt /> i komponenten. Den får bara avsluta påståenden vi kan belägga, så
 * inga hälsopåståenden här.
 */
export const home = {
  eyebrow: "Platshållartext",
  heroHeading: "Veganskt, ända in i kapseln",
  heroBody:
    "B12, D3 och omega-3 för dig som lever växtbaserat. Inga animaliska råvaror, inte ens i skalet.",
  heroCta: "Se sortimentet",
  heroSecondary: "Så redovisar vi",

  rangeHeading: "Sortimentet",
  rangeBody: "Tre tillskott till att börja med. Fler tillkommer efterhand.",

  openHeading: "Öppet redovisat",
  openPoints: [
    {
      title: "Dokumentation, inte påståenden",
      body: "Ursprungsintyg och analyscertifikat ligger på produktsidan, inte begravda i en FAQ.",
    },
    {
      title: "Veganskt hela vägen",
      body: "Även kapseln och processhjälpmedlen. D3 kommer från lav, inte från lanolin.",
    },
    {
      title: "En del av intäkten doneras",
      body: "Mekanism, belopp och mottagande organisation beslutas innan lansering. Beloppet kommer att redovisas publikt och gå att stämma av, inte anges som en marknadsföringssiffra.",
      bodyDecided:
        "Varje köp bidrar till {recipient}. Vi redovisar det donerade beloppet publikt.",
    },
  ],
} as const;

/** Sidan som visas när en adress inte finns. */
export const missingPage = {
  label: "404",
  heading: "Den här sidan finns inte",
  body: "Adressen kan ha ändrats, eller så har den aldrig funnits. Sortimentet hittar du här nedanför.",
  cta: "Se sortimentet",
  secondary: "Till startsidan",
} as const;

export const navigation = [
  { href: "/", label: "Start" },
  { href: "/produkter", label: "Produkter" },
  { href: "/var-paverkan", label: "Vår påverkan" },
] as const;

/**
 * Donationsmekanismen.
 *
 * Enligt CLAUDE.md avsnitt 8 är varken belopp, mekanism eller mottagande
 * organisation beslutad ännu. Fälten är därför medvetet null. Gränssnittet
 * ska hantera det genom att skriva att detta beslutas — inte genom att visa
 * en påhittad siffra. Ett donationslöfte som inte går att verifiera är
 * precis det CLAUDE.md avsnitt 4 säger att vi inte ska bygga.
 */
export const donation = {
  /** Andel av intäkten som doneras, t.ex. 0.05 för 5 %. null = ej beslutat. */
  shareOfRevenue: null as number | null,
  /** Fast belopp i öre per order, som alternativ till andel. null = ej beslutat. */
  fixedAmountOrePerOrder: null as number | null,
  /** Mottagande organisation. null = ej beslutat. */
  recipient: null as { name: string; url: string; note: string } | null,
} as const;

/**
 * Sant först när donationsmekanismen är beslutad och kan beskrivas exakt.
 * Används för att styra vad som får påstås publikt.
 */
export function donationIsDecided(): boolean {
  return (
    donation.recipient !== null &&
    (donation.shareOfRevenue !== null || donation.fixedAmountOrePerOrder !== null)
  );
}

/**
 * En publicerad donationsrapport.
 *
 * Räknaren på "Vår påverkan" är summan av de här raderna, aldrig en siffra
 * som skrivs in för hand. Det är skillnaden mellan ett redovisat belopp och
 * ett marknadsföringstal: varje krona i summan går att följa till en period,
 * en mottagare och ett kvitto.
 */
export type DonationReport = {
  /** Perioden rapporten avser, t.ex. "2027 kvartal 1". */
  period: string;
  /** Donerat belopp i öre. */
  amountOre: number;
  /** Mottagare vid tillfället. Kan ändras över tid, därför per rapport. */
  recipient: string;
  /** Datum då pengarna betalades ut (ISO, t.ex. "2027-04-15"). */
  paidAt: string;
  /** Länk till kvitto eller mottagarens intyg. Tom sträng = inte publicerat än. */
  receiptHref: string;
};

/** Tom tills första utbetalningen är gjord och kvittot finns. */
export const donationReports: DonationReport[] = [];

/**
 * Texterna på "Vår påverkan".
 *
 * Sidan får bara påstå sådant som går att kontrollera. Så länge mekanismen
 * inte är beslutad skriver sidan ut just det, i stället för att visa en
 * påhittad siffra.
 */
export const impact = {
  eyebrow: "Vår påverkan",
  heading: "Varje krona redovisas",
  lede: "En del av intäkten från varje köp går till djurrättsarbete. Här står hur mycket det blivit, vart pengarna gick och hur du kan kontrollera det.",

  counterLabel: "Donerat hittills",
  counterPending: "Räknaren startar vid lansering. Den visar summan av publicerade rapporter, inte en uppskattning.",
  counterLive: "Summan av alla publicerade rapporter nedan.",

  mechanismHeading: "Så funkar det",
  mechanismPending:
    "Mekanismen är inte beslutad ännu. När den är det står den här: hur stor del av varje köp som doneras, vilken organisation som tar emot och hur ofta pengarna betalas ut. Kravet vi utgår från är att organisationen har 90-konto och granskas av Svensk Insamlingskontroll.",

  methodHeading: "Så redovisar vi",
  methodPoints: [
    {
      title: "Beloppet kommer från försäljningen",
      body: "Summan räknas fram ur faktiska order, inte ur en budget eller en prognos.",
    },
    {
      title: "Varje utbetalning får ett kvitto",
      body: "Kvitto eller intyg från mottagaren länkas i tabellen nedan, så att du kan kontrollera beloppet hos dem och inte bara hos oss.",
    },
    {
      title: "Räknaren är summan av rapporterna",
      body: "Siffran högst upp är adderad ur tabellen. Finns ingen rapport finns ingen siffra.",
    },
  ],

  reportsHeading: "Rapporter",
  reportsEmpty:
    "Inga rapporter ännu. Den första publiceras efter den första utbetalningen.",
  reportsColumns: {
    period: "Period",
    amount: "Belopp",
    recipient: "Mottagare",
    paidAt: "Utbetalt",
    receipt: "Kvitto",
  },
} as const;
