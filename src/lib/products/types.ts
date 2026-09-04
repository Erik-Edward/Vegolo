import type { VatCategory } from "@/lib/tax";

/**
 * Datamodell för en produkt.
 *
 * Modellen är medvetet strikt: fält som är obligatoriska enligt EU:s
 * kosttillskottsdirektiv (2002/46/EG) och livsmedelsinformations-
 * förordningen (1169/2011) är obligatoriska även i TypeScript. Det gör att
 * bygget failar om någon lägger till en produkt utan varningstext,
 * ingredienslista, nettokvantitet eller rekommenderat dagligt intag —
 * i stället för att den publiceras ofullständig.
 */

export type ProductForm = "kapsel" | "mjukgelkapsel" | "tablett" | "droppar" | "pulver";

export type Availability = "in_stock" | "coming_soon" | "out_of_stock";

/**
 * Granskningsstatus för innehåll som omfattas av regulatoriska krav.
 * Endast "approved" publiceras i produktion. Se src/lib/products/regulatory.ts.
 */
export type ReviewStatus = "draft" | "approved";

/** Näringsdeklaration per dagsdos. */
export type NutrientDeclaration = {
  name: string;
  /** Mängd per rekommenderad dagsdos, med enhet. Exempel: "100 µg". */
  amountPerDailyDose: string;
  /** Procent av referensintag (RI). null när RI saknas för ämnet. */
  nrvPercent: number | null;
};

export type IngredientRole =
  | "aktiv"
  | "kapsel"
  | "barare"
  | "antiklumpmedel"
  | "ovrigt";

export type Ingredient = {
  name: string;
  role: IngredientRole;
  /** Kort not, t.ex. ursprung eller E-nummer. */
  note?: string;
};

/**
 * Hälsopåstående.
 *
 * Endast formuleringar som är godkända enligt förordning (EG) 1924/2006 och
 * unionsförteckningen (432/2012 m.fl.) får publiceras. Fria formuleringar
 * som "stärker" eller "botar" är förbjudna. `status` styr publicering:
 * påståenden som inte är granskade och godkända renderas aldrig i produktion.
 */
export type HealthClaim = {
  /** Exakt formulering som ska visas för kund. */
  text: string;
  /** Vilket näringsämne påståendet gäller. */
  nutrient: string;
  /** Referens till EU:s register över hälsopåståenden. */
  source: string;
  /** Villkor som produkten måste uppfylla för att få använda påståendet. */
  condition: string;
  status: ReviewStatus;
};

/** Dokumentation som styrker veganskt ursprung, renhet, analys m.m. */
export type SourceDocument = {
  title: string;
  description: string;
  /** Fil under /public/dokument eller extern URL. Tom sträng = saknas ännu. */
  href: string;
  /** ISO-datum då dokumentet senast stämdes av mot leverantören. */
  verifiedAt: string | null;
};

export type NetQuantity = {
  /** Antal enheter i förpackningen, t.ex. 90. */
  unitCount: number;
  /** Enhetens namn i plural, t.ex. "kapslar". */
  unitLabel: string;
  /** Nettovikt i gram enligt förpackningen. */
  netWeightGram: number;
};

export type RecommendedDailyIntake = {
  /** Text som visas för kund, t.ex. "1 kapsel per dag." */
  text: string;
  /** Antal doser per dag — används för att räkna ut hur länge en burk räcker. */
  dosesPerDay: number;
};

export type ProductPrice = {
  /** Pris i öre INKLUSIVE moms. B2C ska alltid visa pris inkl. moms. */
  grossOre: number;
  currency: "SEK";
  /** Styr vilken momssats som tillämpas. Se src/lib/tax.ts. */
  vatCategory: VatCategory;
};

export type ProductImage = {
  /** Sökväg under /public. Tom sträng tills produktfotot finns. */
  src: string;
  alt: string;
};

export type Product = {
  slug: string;
  /** Fullständigt produktnamn, t.ex. "Vegolo B12". */
  name: string;
  /** Kort beskrivning av vad produkten är — inte ett hälsopåstående. */
  tagline: string;
  form: ProductForm;
  sku: string;
  ean: string | null;

  /** Brödtext, ett stycke per element. Får inte innehålla hälsopåståenden. */
  description: string[];

  // --- Obligatorisk produktinformation (regulatoriskt krav) ---
  recommendedDailyIntake: RecommendedDailyIntake;
  /** Produktspecifika varningar. Lagstadgade varningar läggs till automatiskt. */
  warnings: string[];
  ingredients: Ingredient[];
  nutrients: NutrientDeclaration[];
  netQuantity: NetQuantity;
  storage: string;

  // --- Hälsopåståenden och dokumentation ---
  healthClaims: HealthClaim[];
  documentation: SourceDocument[];

  // --- Kommersiellt ---
  price: ProductPrice;
  availability: Availability;
  images: ProductImage[];

  /** Granskningsstatus för hela produktsidans regulatoriska innehåll. */
  reviewStatus: ReviewStatus;
  /** ISO-datum för senaste innehållsgranskning. null = aldrig granskad. */
  reviewedAt: string | null;
};
