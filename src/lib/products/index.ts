import { b12 } from "@/content/products/b12";
import { d3 } from "@/content/products/d3";
import { omega3 } from "@/content/products/omega3";
import type { Product } from "./types";

/**
 * Produktregister.
 *
 * Sortimentet är inte låst till tre produkter — lägg till en fil i
 * src/content/products/ och en rad i listan nedan. Ordningen här styr
 * visningsordningen i butiken.
 *
 * Funktionerna är async trots att de läser från filer. Det är avsiktligt:
 * om produktdata senare flyttas till ett CMS eller en databas behöver bara
 * den här filen skrivas om, inte sidorna som använder den.
 */
const registry: Product[] = [b12, d3, omega3];

const duplicateSlug = registry
  .map((product) => product.slug)
  .find((slug, index, slugs) => slugs.indexOf(slug) !== index);

if (duplicateSlug) {
  throw new Error(
    `Två produkter delar slug "${duplicateSlug}". Slugen används som URL och måste vara unik.`,
  );
}

export async function getAllProducts(): Promise<Product[]> {
  return registry;
}

export async function getProduct(slug: string): Promise<Product | null> {
  return registry.find((product) => product.slug === slug) ?? null;
}

export async function getProductSlugs(): Promise<string[]> {
  return registry.map((product) => product.slug);
}

export type { Product } from "./types";
