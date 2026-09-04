import type { Product } from "@/lib/products/types";

/**
 * PLATSHÅLLARINNEHÅLL. Se kommentaren i b12.ts — samma villkor gäller här.
 *
 * Extra kontrollpunkt: algoljan ska komma från en Schizochytrium-stam som är
 * godkänd som Novel Food inom EU. Godkännandet ska verifieras mot
 * leverantörens dokumentation och noteras i documentation-listan nedan.
 */
export const omega3: Product = {
  slug: "omega-3-algolja",
  name: "Vegolo Omega-3",
  tagline: "EPA och DHA från algolja",
  form: "mjukgelkapsel",
  sku: "VG-O3-60",
  ean: null,

  description: [
    "Omega-3 med EPA och DHA från algolja (Schizochytrium sp.), i vegansk mjukgelkapsel.",
    "EPA och DHA kommer annars nästan alltid från fisk- eller krillolja. Algolja är den ursprungliga källan i näringskedjan — fiskarna får sitt EPA och DHA genom att äta alger.",
    "Mjukgelkapseln är tillverkad utan gelatin. Dokumentation om Novel Food-godkännande och stam finns under Dokumentation.",
  ],

  recommendedDailyIntake: {
    text: "2 mjukgelkapslar per dag, tillsammans med mat.",
    dosesPerDay: 2,
  },

  warnings: [
    "Rådgör med läkare vid graviditet, amning, pågående medicinering eller blodförtunnande behandling.",
  ],

  ingredients: [
    { name: "Algolja från Schizochytrium sp.", role: "aktiv", note: "Novel Food-godkänd stam" },
    { name: "Kapsel: modifierad majsstärkelse, glycerol, karragenan", role: "kapsel", note: "Vegansk mjukgel, ej gelatin" },
    { name: "Solrosolja", role: "barare" },
    { name: "Blandade tokoferoler", role: "ovrigt", note: "Antioxidationsmedel" },
  ],

  nutrients: [
    { name: "Algolja", amountPerDailyDose: "1000 mg", nrvPercent: null },
    { name: "varav DHA", amountPerDailyDose: "500 mg", nrvPercent: null },
    { name: "varav EPA", amountPerDailyDose: "250 mg", nrvPercent: null },
  ],

  netQuantity: {
    unitCount: 60,
    unitLabel: "mjukgelkapslar",
    netWeightGram: 45,
  },

  storage: "Förvaras torrt och mörkt i rumstemperatur. Undvik direkt solljus.",

  healthClaims: [
    {
      text: "DHA bidrar till att bibehålla normal hjärnfunktion.",
      nutrient: "DHA",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Kräver ett dagligt intag om minst 250 mg DHA.",
      status: "draft",
    },
    {
      text: "DHA bidrar till att bibehålla normal synförmåga.",
      nutrient: "DHA",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Kräver ett dagligt intag om minst 250 mg DHA.",
      status: "draft",
    },
    {
      text: "EPA och DHA bidrar till hjärtats normala funktion.",
      nutrient: "EPA och DHA",
      source: "EU:s register över hälsopåståenden, förordning (EU) 432/2012",
      condition: "Kräver ett dagligt intag om minst 250 mg EPA och DHA.",
      status: "draft",
    },
  ],

  documentation: [
    {
      title: "Novel Food-godkännande för algstammen",
      description: "Underlag som visar att Schizochytrium-stammen är godkänd för livsmedelsbruk inom EU.",
      href: "",
      verifiedAt: null,
    },
    {
      title: "Vegansk deklaration från tillverkaren",
      description: "Intyg om att mjukgelkapseln är gelatinfri och att inga animaliska processhjälpmedel används.",
      href: "",
      verifiedAt: null,
    },
    {
      title: "Analyscertifikat (CoA)",
      description: "EPA- och DHA-halt, oxidationsvärden och renhet per tillverkningssats.",
      href: "",
      verifiedAt: null,
    },
  ],

  price: {
    grossOre: 34900,
    currency: "SEK",
    vatCategory: "food_supplement",
  },

  availability: "coming_soon",

  images: [{ src: "", alt: "Vegolo Omega-3, burk med 60 mjukgelkapslar" }],

  reviewStatus: "draft",
  reviewedAt: null,
};
