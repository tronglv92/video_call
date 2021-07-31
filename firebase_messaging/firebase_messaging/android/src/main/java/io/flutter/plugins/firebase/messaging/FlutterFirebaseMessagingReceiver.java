// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.messaging.RemoteMessage;
import java.util.HashMap;

public class FlutterFirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = "FLTFireMsgReceiver";
  static HashMap<String, RemoteMessage> notifications = new HashMap<>();
//  public void launchApp(Context context) {
//
//    PackageManager pm = context.getPackageManager();
//    Intent intent = pm.getLaunchIntentForPackage(context.getPackageName());
//    context.startActivity(intent);
//  }
  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(TAG, "broadcast received for message");
    if (ContextHolder.getApplicationContext() == null) {
      ContextHolder.setApplicationContext(context.getApplicationContext());
    }

    RemoteMessage remoteMessage = new RemoteMessage(intent.getExtras());

    Log.e(TAG,"broadcast received for message");
    // Store the RemoteMessage if the message contains a notification payload.
    Log.e(TAG,"remoteMessage.getNotification() "+remoteMessage.getNotification());
    if (remoteMessage.getData() != null) {
      notifications.put(remoteMessage.getMessageId(), remoteMessage);
      FlutterFirebaseMessagingStore.getInstance().storeFirebaseMessage(remoteMessage);
    }

    //  |-> ---------------------
    //      App in Foreground
    //   ------------------------
    if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
      Intent onMessageIntent = new Intent(FlutterFirebaseMessagingUtils.ACTION_REMOTE_MESSAGE);
      onMessageIntent.putExtra(FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE, remoteMessage);
      LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageIntent);
      return;
    }

    //  |-> ---------------------
    //    App in Background/Quit
    //   ------------------------

//    launchApp(context);

    Intent onBackgroundMessageIntent =
        new Intent(context, FlutterFirebaseMessagingBackgroundService.class);
    onBackgroundMessageIntent.putExtra(
        FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE, remoteMessage);
    FlutterFirebaseMessagingBackgroundService.enqueueMessageProcessing(
        context, onBackgroundMessageIntent);
  }
}
