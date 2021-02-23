package com.sip.linphone;

import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import org.json.JSONException;
import org.json.JSONObject;
import org.linphone.core.Core;

import java.util.Map;

public class LinphoneFirebaseMessaging extends FirebaseMessagingService {
    private static final String TAG = "LinphoneSip";

    private Runnable mPushReceivedRunnable =
		() -> {
			if (!LinphoneContext.isReady()) {
				Log.i(TAG, "[Push Notification] Starting context");
				new LinphoneContext(getApplicationContext(), true);
			} else {
				Log.i(TAG, "[Push Notification] Notifying Core");
				if (LinphoneMiniManager.getInstance() != null) {
					Core core = LinphoneMiniManager.mCore;
					if (core != null) {
						Log.i(TAG, "[Push Notification] ensureRegisterede");
						core.refreshRegisters();
					}
				}
			}
		};


    @Override
    public void onNewToken(final String token) {
        Log.d(TAG, "[Push Notification] Refreshed token: " + token);

        LinphoneContext.dispatchOnUIThread(
			() -> LinphonePreferences.instance().setPushNotificationRegistrationID(token)
		);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "[Push Notification] onMessageReceived  type:" + remoteMessage.getData());

        String type = remoteMessage.getData().get("type");
        if (type == null || !type.equalsIgnoreCase("intercom")) {
			Log.d(TAG, "[Push Notification] message wrong type. no action needed");
			return;
		}

		//TODO check for existing sip registration
        LinphoneContext.dispatchOnUIThread(mPushReceivedRunnable);
    }
}
