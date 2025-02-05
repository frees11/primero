import { setMsalConfig, getLoginRequest, getTokenRequest } from "./utils";

describe("auth-utils", () => {
  let idp;

  before(() => {
    idp = {
      name: "UNICEF",
      unique_id: "unicef",
      provider_type: "b2c",
      client_id: "123",
      authorization_url: "authorization",
      identity_scope: ["123"],
      verification_url: "verification",
      domain_hint: "unicef"
    };
  });

  it("returns provider details", () => {
    const expected = {
      auth: {
        clientId: "123",
        authority: "authorization",
        validateAuthority: false,
        knownAuthorities: ["unicefpartners.b2clogin.com"],
        redirectUri: `${window.location.protocol}//${window.location.host}/login/b2c`
      },
      cache: {
        cacheLocation: "sessionStorage",
        storeAuthStateInCookie: false
      }
    };

    expect(setMsalConfig(idp)).to.deep.equal(expected);
  });

  it("returns login request", () => {
    const expected = {
      scopes: ["123"],
      extraQueryParameters: { domain_hint: "domain" }
    };

    expect(getLoginRequest(["123"], "domain")).to.deep.equal(expected);
  });

  it("returns token request", () => {
    const expected = {
      scopes: ["123"]
    };

    expect(getTokenRequest(["123"])).to.deep.equal(expected);
  });
});
