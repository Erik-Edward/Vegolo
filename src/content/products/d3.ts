import type { Product } from "@/lib/products/types";

/**
 * PLATSHÅLLARINNEHÅLL. Se kommentaren i b12.ts — samma villkor gäller här.
 */
export const d3: Product = {
  slug: "d3-lavbaserad",
  name: "Vegolo D3",
  tagline: "D3 från lav, inte lanolin",
  form: "kapsel",
  sku: "VG-D3-90",
  ean: null,

  description: [
    "Vitamin D3 (kolekalciferol) utvunnet ur lav, i en vegansk kapsel av växtcellulosa.",
    "Vanligt D3-tillskott utvinns nästan alltid ur lanolin, ett fett från fårull. Den här produkten använder i stället en lavbaserad råvara, vilket gör den lämplig för dig som lever helt växtbaserat.",
    "Ursprungsintyg för lavråvaran finns under Dokumentation.",
  ],

  recommendedDailyIntake: {
    text: "1 kapsel per dag, gärna tillsammans med ett mål som innehåller fett.",
    dosesPerDay: 1,
  },

  warnings: [
    "Rådgör med läkare vid graviditet, amning eller pågående medicinering.",
    "Kombinera inte med andra tillskott som innehåller vitamin D utan att räkna samman den totala mängden.",
  ],

  ingredients: [
    { name: "Kallpressad kokosolja", role: "barare" },
    { name: "Kapsel: hydroxipropylmetylcellulosa (HPMC)", role: "kapsel", note: "Växtcellulosa, ej gelatin" },
    { name: "Vitamin D3 (kolekalciferol) från lav", role: "aktiv", note: "Lichen-baserad, ej lanolin" },
  ],

  nutrients: [
    { name: "Vitamin D3 (kolekalciferol)", amountPerDailyDose: "25 µg (1000 IE)", nrvPercent: 500 },
  ],

  netQuantity: {
    unitCount: 90,
    unitLabel: "kapslar",
    netWeightGram: 32,
  },

  storage: "Förvaras torrt och mörkt i rumstemperatur. Tillslut burken väl efter användning.",

  healthClaims: [
    {
      text: "D-vitamin bidrar till att bibehålla normal benstomme.",
      nutrient: "Vitamin D",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin D (15 % av RI).",
      status: "draft",
    },
    {
      text: "D-vitamin bidrar till immunsystemets normala funktion.",
      nutrient: "Vitamin D",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin D (15 % av RI).",
      status: "draft",
    },
    {
      text: "D-vitamin bidrar till normal muskelfunktion.",
      nutrient: "Vitamin D",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Produkten måste vara minst en källa till vitamin D (15 % av RI).",
      status: "draft",
    },
  ],

  documentation: [
    {
      title: "Ursprungsintyg för lavbaserat D3",
      description: "Intyg från råvaruleverantören om att kolekalciferolet utvinns ur lav och inte ur lanolin.",
      href: "",
      verifiedAt: null,
    },
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
    grossOre: 21900,
    currency: "SEK",
    vatCategory: "food_supplement",
  },

  availability: "coming_soon",

  images: [{ src: "", alt: "Vegolo D3, burk med 90 kapslar" }],

  reviewStatus: "draft",
  reviewedAt: null,
};
