import { Logo } from "@/components/Logo";
import { Punkt } from "@/components/Punkt";
import { site } from "@/content/site";

export function SiteFooter() {
  return (
    <footer className="on-dark mt-24 bg-brand text-brand-ink">
      <div className="mx-auto max-w-5xl px-6 py-14">
        <div className="flex flex-wrap items-end justify-between gap-8">
          <Logo className="h-7 w-auto" />
          <p className="font-mono text-xs tracking-wide opacity-75">
            Veganska kosttillskott
          </p>
        </div>

        <p className="mt-8 max-w-md text-sm leading-relaxed opacity-85">
          {site.description}
        </p>

        <p className="mt-10 max-w-2xl text-xs leading-relaxed opacity-70">
          Vegolo AB (under bildande). Priser visas inklusive moms. Kosttillskott
          bör inte användas som ett alternativ till en varierad och balanserad
          kost och en hälsosam livsstil.
        </p>

        <p className="mt-4 text-xs leading-relaxed opacity-70">
          Platshållartext. Organisationsnummer, kontaktuppgifter, köpvillkor och
          integritetspolicy läggs till innan lansering
          <Punkt />
        </p>
      </div>
    </footer>
  );
}
