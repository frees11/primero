import { useCallback, useEffect, useRef } from "react";
import { workerTimers } from "react-idle-timer";
import { useDispatch } from "react-redux";

import { PUSH_NOTIFICATION_SUBSCRIPTION_REFRESH_INTERVAL } from "../../config/constants";
import useMemoizedSelector from "../../libs/use-memoized-selector";
import { getNotificationSubscription } from "../user/selectors";
import { toServerDateFormat } from "../../libs";

import { refreshNotificationSubscription } from "./action-creators";

let refreshTimer;

function usePushNotifications() {
  const dispatch = useDispatch();
  const endpoint = useRef();
  const notificationEndpoint = useMemoizedSelector(state => getNotificationSubscription(state));

  useEffect(() => {
    endpoint.current = notificationEndpoint;
  }, [notificationEndpoint]);

  const startRefreshNotificationTimer = useCallback(() => {
    refreshTimer = workerTimers.setInterval(() => {
      dispatch(
        refreshNotificationSubscription({
          data: {
            updated_at: toServerDateFormat(Date.now(), { includeTime: true }),
            notification_url: endpoint.current
          }
        })
      );
    }, PUSH_NOTIFICATION_SUBSCRIPTION_REFRESH_INTERVAL);
  }, [notificationEndpoint]);

  const stopRefreshNotificationTimer = useCallback(() => {
    if (refreshTimer) {
      workerTimers.clearInterval(refreshTimer);
    }
  });

  return {
    startRefreshNotificationTimer,
    stopRefreshNotificationTimer
  };
}

export default usePushNotifications;
