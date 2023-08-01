/* eslint-disable no-return-await */
import { InteractionRequiredAuthError } from "@azure/msal-common";
import { isImmutable } from "immutable";

import { SELECTED_IDP } from "../../../user/constants";

import { setMsalApp, setMsalConfig, getLoginRequest, getTokenRequest } from "./utils";

let msalApp;
let forceStandardOIDC = false;

function createNewGuid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }

  return `${s4() + s4()}-${s4()}-${s4()}-${s4()}-${s4()}${s4()}${s4()}`;
}

async function getToken(tokenRequest) {
  try {
    return await msalApp.acquireTokenSilent(tokenRequest);
  } catch (error) {
    if (error instanceof InteractionRequiredAuthError) {
      return await msalApp.acquireTokenPopup(tokenRequest).catch(popupError => {
        // eslint-disable-next-line no-console
        console.error(popupError);
      });
    }

    // eslint-disable-next-line no-console
    console.warn("Failed to acquire token", error);

    return undefined;
  }
}

const setupMsal = (idp, historyObj) => {
  const idpObj = isImmutable(idp) ? idp.toJS() : idp;

  const identityScope = idpObj.identity_scope || [""];
  const domainHint = idpObj.domain_hint;
  const msalConfig = setMsalConfig(idpObj);
  const loginRequest = getLoginRequest(identityScope, domainHint);
  const tokenRequest = getTokenRequest(identityScope);

  if (!msalApp) {
    forceStandardOIDC = idpObj.force_standard_oidc === true;
    msalApp = setMsalApp(msalConfig, forceStandardOIDC, historyObj);
  }

  localStorage.setItem(SELECTED_IDP, idpObj.unique_id);

  return { loginRequest, tokenRequest };
};

const handleResponse = async (tokenRequest, successCallback) => {
  const tokenResponse = await getToken(tokenRequest);

  if (tokenResponse) {
    successCallback();
  }
};

export const refreshIdpToken = async (idp, successCallback, historyObj) => {
  const { tokenRequest } = setupMsal(idp, historyObj);

  handleResponse(tokenRequest, successCallback);
};

export const signIn = async (idp, callback, historyObj) => {
  sessionStorage.clear();

  const { loginRequest } = setupMsal(idp, historyObj);

  try {
    const response = await msalApp.loginPopup(loginRequest);

    localStorage.setItem("cachedIdToken", response.idToken);
    callback(response.idToken);
  } catch (error) {
    throw new Error(error);
  }
};

export const signOut = () => {
  if (msalApp) {
    if (forceStandardOIDC) {
      // OIDC front-channel logout can take a post_logout_redirect_uri parameter, which we set in the msal config
      // However, if this parameter is included, either client_id or id_token_hint is required
      // https://openid.net/specs/openid-connect-rpinitiated-1_0.html#RPLogout
      // Since MSAL does not offer any way to add parameters to logout, we piggyback on the correlationId argument
      // The GUID is what msal uses as the default when the argument is not specified
      msalApp.logout(`${createNewGuid()}&client_id=${encodeURIComponent(msalApp.config.auth.clientId)}`);
    } else {
      msalApp.logout();
    }
    msalApp = null;
    forceStandardOIDC = false;
    localStorage.removeItem("cachedIdToken");
  }
};
