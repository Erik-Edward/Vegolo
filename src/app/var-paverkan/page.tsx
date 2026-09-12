import type { Metadata } from "next";
import { Punkt } from "@/components/Punkt";
import { donation, donationReports, impact } from "@/content/site";
import {
  describeDonation,
  formatPaidAt,
  hasDonationReports,
  totalDonatedOre,
} from "@/lib/donation";
import { formatOreCompact } from "@/lib/money";

/*
 * Vår påverkan.
 *
 * Sidan har två lägen och byter själv mellan dem:
 *   - Innan mekanismen är beslutad står det att den beslutas, och räknaren
 *     visar ett tankstreck. Ingen siffra hittas på.
 *   - När donation och rapporter finns i src/content/site.ts visas summan av
 *     rapporterna och tabellen med kvitton.
 *
 * Figuren (punkten med ögon) hör inte hemma här. Det här är sidan där vi ber
 * om förtroende, och då ska tonen vara saklig.
 */

export const metadata: Metadata = {
  title: "Vår påverkan",
  description: impact.lede,
};

export default function ImpactPage() {
  const reports = donationReports;
  const published = hasDonationReports();
  const mechanism = describeDonation();
  const columns = impact.reportsColumns;

  return (
    <div className="mx-auto max-w-5xl px-6 pt-8 pb-16">
      <section className="on-dark rounded-2xl bg-brand px-7 py-14 text-brand-ink sm:px-12 sm:py-16">
        <p className="font-mono text-[11px] tracking-[0.14em] uppercase opacity-70">
          {impact.eyebrow}
        </p>
        <h1 className="mt-6 max-w-2xl text-5xl leading-[1.02] sm:text-6xl">
          {impact.heading}
          <Punkt />
        </h1>
        <p className="mt-6 max-w-xl text-lg leading-relaxed opacity-85">
          {impact.lede}
        </p>

        <div className="mt-12 border-t border-brand-ink/20 pt-8">
          <p className="font-mono text-[11px] tracking-[0.12em] uppercase opacity-70">
            {impact.counterLabel}
          </p>
          <p className="mt-3 text-6xl tabular-nums sm:text-7xl">
            {published ? formatOreCompact(totalDonatedOre()) : "— kr"}
          </p>
          <p className="mt-3 max-w-md text-sm leading-relaxed opacity-75">
            {published ? impact.counterLive : impact.counterPending}
          </p>
        </div>
      </section>

      <section className="mt-16">
        <h2 className="text-3xl">{impact.mechanismHeading}</h2>
        <div className="mt-4 max-w-2xl space-y-3 leading-relaxed text-muted">
          {mechanism ? (
            <>
              <p className="text-ink">{mechanism}</p>
              {donation.recipient ? (
                <p>
                  {donation.recipient.note}{" "}
                  <a
                    href={donation.recipient.url}
                    className="text-ink underline decoration-dot-deep decoration-2 underline-offset-4"
                  >
                    {donation.recipient.name}
                  </a>
                </p>
              ) : null}
            </>
          ) : (
            <p>{impact.mechanismPending}</p>
          )}
        </div>
      </section>

      <section className="mt-16">
        <h2 className="text-3xl">{impact.methodHeading}</h2>
        <div className="mt-8 grid gap-8 sm:grid-cols-3">
          {impact.methodPoints.map((point) => (
            <div key={point.title} className="border-t border-line pt-4">
              <h3 className="text-lg">{point.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted">
                {point.body}
              </p>
            </div>
          ))}
        </div>
      </section>

      <section className="mt-16">
        <h2 className="text-3xl">{impact.reportsHeading}</h2>

        {published ? (
          <div className="mt-6 overflow-x-auto">
            <table className="w-full min-w-xl text-sm">
              <thead>
                <tr className="border-b border-line text-left text-muted">
                  <th scope="col" className="pb-2 font-normal">
                    {columns.period}
                  </th>
                  <th scope="col" className="pb-2 font-normal">
                    {columns.amount}
                  </th>
                  <th scope="col" className="pb-2 font-normal">
                    {columns.recipient}
                  </th>
                  <th scope="col" className="pb-2 font-normal">
                    {columns.paidAt}
                  </th>
                  <th scope="col" className="pb-2 font-normal">
                    {columns.receipt}
                  </th>
                </tr>
              </thead>
              <tbody>
                {reports.map((report) => (
                  <tr
                    key={`${report.period}-${report.paidAt}`}
                    className="border-b border-line last:border-0"
                  >
                    <td className="py-3">{report.period}</td>
                    <td className="py-3 font-mono text-xs tabular-nums">
                      {formatOreCompact(report.amountOre)}
                    </td>
                    <td className="py-3">{report.recipient}</td>
                    <td className="py-3 font-mono text-xs tabular-nums">
                      {formatPaidAt(report.paidAt)}
                    </td>
                    <td className="py-3">
                      {report.receiptHref ? (
                        <a
                          href={report.receiptHref}
                          className="underline decoration-dot-deep decoration-2 underline-offset-4"
                        >
                          Kvitto
                        </a>
                      ) : (
                        <span className="text-muted">Publiceras</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <p className="mt-4 max-w-xl rounded-xl border border-line bg-surface p-6 text-sm leading-relaxed text-muted">
            {impact.reportsEmpty}
          </p>
        )}
      </section>
    </div>
  );
}
