/**
 * Vegolo-punkten: den gröna punkt som avslutar rubriker.
 *
 * Regeln är att punkten bara avslutar påståenden vi kan belägga — ursprung,
 * innehåll, donationer. Den sätts aldrig efter ett hälsopåstående: de står
 * alltid ordagrant som i EU:s register, utan varumärkesgrepp.
 */
export function Punkt() {
  return <span className="punkt">.</span>;
}
