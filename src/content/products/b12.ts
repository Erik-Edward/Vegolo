import type { Product } from "@/lib/products/types";

/**
 * PLATSHÅLLARINNEHÅLL.
 *
 * Alla texter, siffror och priser nedan är utkast och måste ersättas med
 * uppgifter från den faktiska white label-leverantörens specifikation innan
 * lansering. Hälsopåståendena har status "draft" och visas därför inte i
 * skarp drift — de måste stämmas av ord för ord mot EU:s register över
 * godkända hälsopåståenden och sättas till "approved" av en människa.
 */
export const b12: Product = {
  slug: "b12-metylkobalamin",
  name: "Vegolo B12",
  tagline: "Metylkobalamin i vegansk kapsel",
  form: "kapsel",
  sku: "VG-B12-90",
  ean: null,

  description: [
    "Vitamin B12 i formen metylkobalamin, i en vegansk kapsel av växtcellulosa.",
    "B12 bildas av bakterier och finns naturligt i animaliska livsmedel. Den B12 som används här är framställd genom bakteriell fermentering och innehåller inga animaliska råvaror i något steg.",
    "Tillverkas hos en EU-baserad producent. Analyscertifikat för varje tillverkningssats finns under Dokumentation.",
  ],

  recommendedDailyIntake: {
    text: "1 kapsel per dag, med eller utan mat.",
    dosesPerDay: 1,
  },

  warnings: [
    "Rådgör med läkare vid graviditet, amning eller pågående medicinering.",
  ],

  ingredients: [
    { name: "Mikrokristallin cellulosa", role: "barare", note: "Fyllnadsmedel" },
    { name: "Kapsel: hydroxipropylmetylcellulosa (HPMC)", role: "kapsel", note: "Växtcellulosa, ej gelatin" },
    { name: "Metylkobalamin (vitamin B12)", role: "aktiv" },
    { name: "Magnesiumsalter av fettsyror", role: "antiklumpmedel", note: "Vegetabiliskt ursprung" },
  ],

  nutrients: [
    { name: "Vitamin B12 (metylkobalamin)", amountPerDailyDose: "100 µg", nrvPercent: 4000 },
  ],

  netQuantity: {
    unitCount: 90,
    unitLabel: "kapslar",
    netWeightGram: 27,
  },

  storage: "Förvaras torrt och mörkt i rumstemperatur. Tillslut burken väl efter användning.",

  healthClaims: [
    {
      text: "Vitamin B12 bidrar till normal energiomsättning.",
      nutrient: "Vitamin B12",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin B12 (15 % av RI).",
      status: "draft",
    },
    {
      text: "Vitamin B12 bidrar till nervsystemets normala funktion.",
      nutrient: "Vitamin B12",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin B12 (15 % av RI).",
      status: "draft",
    },
    {
      text: "Vitamin B12 bidrar till att minska trötthet och utmattning.",
      nutrient: "Vitamin B12",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin B12 (15 % av RI).",
      status: "draft",
    },
  ],

  documentation: [
    {
      title: "Vegansk deklaration från tillverkaren",
      description: "Intyg om att inga animaliska råvaror eller processhjälpmedel används.",
      href: "",
      verifiedAt: null,
    },
    {
      title: "Analyscertifikat (CoA)",
      description: "Innehåll och renhet per tillverkningssats.",
      href: "",
      verifiedAt: null,
    },
  ],

  price: {
    grossOre: 19900,
    currency: "SEK",
    vatCategory: "food_supplement",
  },

  availability: "coming_soon",

  images: [{ src: "", alt: "Vegolo B12, burk med 90 kapslar" }],

  reviewStatus: "draft",
  reviewedAt: null,
};
