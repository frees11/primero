/* eslint-disable import/prefer-default-export */
import { fromJS } from "immutable";

import { SAVING } from "../../../config";

import NAMESPACE from "./namespace";

export const getCurrentUser = state => {
  return state.getIn(["records", NAMESPACE, "user"], fromJS({}));
};

export const getSavingRecord = state => state.getIn(["records", NAMESPACE, SAVING], false);
