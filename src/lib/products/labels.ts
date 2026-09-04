import type { Availability, IngredientRole, ProductForm } from "./types";

/** Etiketter för kund. Ligger samlat så att språket blir konsekvent. */

export const availabilityLabels: Record<Availability, string> = {
  in_stock: "I lager",
  coming_soon: "Kommer snart",
  out_of_stock: "Tillfälligt slut",
};

export const formLabels: Record<ProductForm, string> = {
  kapsel: "Kapslar",
  mjukgelkapsel: "Mjukgelkapslar",
  tablett: "Tabletter",
  droppar: "Droppar",
  pulver: "Pulver",
};

export const ingredientRoleLabels: Record<IngredientRole, string> = {
  aktiv: "Aktiv ingrediens",
  kapsel: "Kapsel",
  barare: "Bärare",
  antiklumpmedel: "Antiklumpmedel",
  ovrigt: "Övrigt",
};
