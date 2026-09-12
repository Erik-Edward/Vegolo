import { donation, donationIsDecided, donationReports } from "@/content/site";
import { formatOreCompact } from "@/lib/money";

/**
 * Donationsredovisning.
 *
 * Summan som visas publikt räknas alltid fram ur publicerade rapporter. Det
 * är hela poängen med CLAUDE.md avsnitt 4: ett redovisat belopp ska gå att
 * följa till en period, en mottagare och ett kvitto. Finns ingen rapport
 * finns ingen siffra — då skriver sidan ut att räknaren startar vid lansering.
 */
export function totalDonatedOre(): number {
  return donationReports.reduce((sum, report) => sum + report.amountOre, 0);
}

export function hasDonationReports(): boolean {
  return donationReports.length > 0;
}

/**
 * Beskriver mekanismen i en mening, byggd ur konfigurationen i site.ts.
 * Returnerar null så länge den inte är beslutad, så att sidan kan skriva ut
 * just det i stället för att gissa.
 */
export function describeDonation(): string | null {
  if (!donationIsDecided() || donation.recipient === null) return null;

  const share =
    donation.shareOfRevenue !== null
      ? `${new Intl.NumberFormat("sv-SE", {
          style: "percent",
          maximumFractionDigits: 1,
        }).format(donation.shareOfRevenue)} av intäkten från varje köp`
      : `${formatOreCompact(donation.fixedAmountOrePerOrder ?? 0)} per order`;

  return `${share} går till ${donation.recipient.name}.`;
}

/** Svenskt datumformat för utbetalningar, t.ex. "15 april 2027". */
export function formatPaidAt(isoDate: string): string {
  return new Intl.DateTimeFormat("sv-SE", { dateStyle: "long" }).format(
    new Date(isoDate),
  );
}
