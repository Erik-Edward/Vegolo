import type { HealthClaim, Product } from "./types";

/**
 * Regulatoriska regler som gäller alla produkter.
 *
 * Poängen med den här filen är att de lagstadgade delarna inte ska vara
 * beroende av att någon kommer ihåg dem när en produkt läggs till. De
 * obligatoriska varningarna läggs på automatiskt, och ogranskade
 * hälsopåståenden filtreras bort innan de kan nå en publik sida.
 */

/**
 * Varningar som enligt kosttillskottsdirektivet (2002/46/EG art. 6.3,
 * i Sverige LIVSFS 2003:9) måste finnas på varje kosttillskott.
 * Ändra bara den här listan efter avstämning med den regulatoriska
 * granskningen — den gäller hela sortimentet.
 */
export const MANDATORY_WARNINGS: readonly string[] = [
  "Rekommenderat dagligt intag bör inte överskridas.",
  "Kosttillskott bör inte användas som ett alternativ till en varierad och balanserad kost och en hälsosam livsstil.",
  "Förvaras utom räckhåll för små barn.",
];

/**
 * Sant när ogranskat innehåll får visas — dvs. lokalt och i förhandsvisning,
 * aldrig i skarp drift. Sätt NEXT_PUBLIC_SHOW_DRAFT_CONTENT=1 för att
 * tvinga fram granskningsläget även i en produktionsbyggd förhandsvisning.
 */
export function draftContentVisible(): boolean {
  if (process.env.NEXT_PUBLIC_SHOW_DRAFT_CONTENT === "1") return true;
  return process.env.NODE_ENV !== "production";
}

/** Lagstadgade varningar först, därefter produktspecifika. Dubbletter tas bort. */
export function getAllWarnings(product: Product): string[] {
  return Array.from(new Set([...MANDATORY_WARNINGS, ...product.warnings]));
}

/**
 * Hälsopåståenden som får publiceras. I skarp drift returneras endast
 * granskade och godkända påståenden — ett ogranskat påstående kan alltså
 * inte råka gå live.
 */
export function getPublishableHealthClaims(product: Product): HealthClaim[] {
  if (draftContentVisible()) return product.healthClaims;
  return product.healthClaims.filter((claim) => claim.status === "approved");
}

/** Påståenden som väntar på regulatorisk granskning. */
export function getUnreviewedHealthClaims(product: Product): HealthClaim[] {
  return product.healthClaims.filter((claim) => claim.status !== "approved");
}

/** Antal dagar en förpackning räcker vid rekommenderat intag. */
export function daysPerPackage(product: Product): number | null {
  const { dosesPerDay } = product.recommendedDailyIntake;
  if (dosesPerDay <= 0) return null;
  return Math.floor(product.netQuantity.unitCount / dosesPerDay);
}

/** Sant när produktens regulatoriska innehåll är granskat och godkänt. */
export function isReviewed(product: Product): boolean {
  return (
    product.reviewStatus === "approved" &&
    getUnreviewedHealthClaims(product).length === 0
  );
}
