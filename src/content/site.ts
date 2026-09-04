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

export const navigation = [
  { href: "/", label: "Start" },
  { href: "/produkter", label: "Produkter" },
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
