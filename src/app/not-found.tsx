import Link from "next/link";
import { Figur } from "@/components/Figur";
import { Punkt } from "@/components/Punkt";
import { missingPage } from "@/content/site";

/*
 * 404-sidan.
 *
 * Här får figuren synas: kunden ska inte fatta något beslut, bara hitta rätt
 * igen. Figuren står till höger om texten eftersom den tittar åt vänster,
 * tillbaka mot det som just sagts.
 */
export default function NotFound() {
  return (
    <div className="mx-auto flex max-w-5xl flex-col items-start gap-12 px-6 py-24 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p className="font-mono text-[11px] tracking-[0.14em] text-muted uppercase">
          {missingPage.label}
        </p>
        <h1 className="mt-3 text-4xl">
          {missingPage.heading}
          <Punkt />
        </h1>
        <p className="mt-3 max-w-md text-muted">{missingPage.body}</p>

        <div className="mt-8 flex flex-wrap items-center gap-x-8 gap-y-4">
          <Link
            href="/produkter"
            className="rounded-full bg-brand px-6 py-3 text-sm font-semibold text-brand-ink transition-opacity hover:opacity-90"
          >
            {missingPage.cta}
          </Link>
          <Link
            href="/"
            className="text-sm font-medium underline decoration-dot-deep decoration-2 underline-offset-4"
          >
            {missingPage.secondary}
          </Link>
        </div>
      </div>

      <Figur className="w-28 shrink-0 text-ink sm:w-36" />
    </div>
  );
}
