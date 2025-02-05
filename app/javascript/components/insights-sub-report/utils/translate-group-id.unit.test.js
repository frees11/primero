import { format, parseISO } from "date-fns";

import { MONTH, QUARTER, WEEK, YEAR } from "../../insights/constants";

import translateGroupId from "./translate-group-id";

describe("translateGroupId", () => {
  it("translates group of years", () => {
    const result = translateGroupId(2023, YEAR, format);

    expect(result).to.equals("2023");
  });

  it("translates group of months", () => {
    const result = translateGroupId("2023-03", MONTH, format);

    expect(result).to.equals("2023-Mar");
  });

  it("translates group of quarters", () => {
    const result = translateGroupId("2023-Q1", QUARTER, format);

    expect(result).to.equals("2023-Q1");
  });

  it("translates group of weeks", () => {
    const localizeDate = (value, dateFormat) => format(parseISO(value), dateFormat);

    const result = translateGroupId("2023-01-01 - 2023-01-07", WEEK, localizeDate);

    expect(result).to.equals("2023-Jan-01 - 2023-Jan-07");
  });
});
