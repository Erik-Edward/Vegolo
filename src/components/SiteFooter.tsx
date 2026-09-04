import { site } from "@/content/site";

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-line">
      <div className="mx-auto max-w-5xl px-6 py-12">
        <p className="font-display text-xl text-brand">{site.name}</p>
        <p className="mt-2 max-w-md text-sm leading-relaxed text-muted">
          {site.description}
        </p>

        <p className="mt-8 text-xs leading-relaxed text-muted">
          Vegolo AB (under bildande). Priser visas inklusive moms.
          Kosttillskott bör inte användas som ett alternativ till en varierad
          och balanserad kost och en hälsosam livsstil.
        </p>

        <p className="mt-4 text-xs text-muted">
          Platshållartext. Organisationsnummer, kontaktuppgifter,
          köpvillkor och integritetspolicy läggs till innan lansering.
        </p>
      </div>
    </footer>
  );
}
