package com.sip.linphone;

import android.app.Dialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.Resources;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

public class LinphoneDeviceUtils {
    private static final Intent[] POWERMANAGER_INTENTS = {
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.letv.android.letvsafe",
                            "com.letv.android.letvsafe.AutobootManageActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.huawei.systemmanager",
                            "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.huawei.systemmanager",
                            "com.huawei.systemmanager.optimize.process.ProtectActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.coloros.safecenter",
                            "com.coloros.safecenter.startupapp.StartupAppListActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.oppo.safe",
                            "com.oppo.safe.permission.startup.StartupAppListActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.samsung.android.lool",
                            "com.samsung.android.sm.ui.battery.BatteryActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.htc.pitroad",
                            "com.htc.pitroad.landingpage.activity.LandingPageActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.asus.mobilemanager", "com.asus.mobilemanager.MainActivity")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.asus.mobilemanager",
                            "com.asus.mobilemanager.autostart.AutoStartActivity")),
            new Intent()
                    .setComponent(
                            new ComponentName(
                                    "com.asus.mobilemanager",
                                    "com.asus.mobilemanager.entry.FunctionActivity"))
                    .setData(Uri.parse("mobilemanager://function/entry/AutoStart")),
            new Intent()
                    .setComponent(
                    new ComponentName(
                            "com.dewav.dwappmanager",
                            "com.dewav.dwappmanager.memory.SmartClearupWhiteList"))
    };

    public static Intent getDevicePowerManagerIntent(Context context) {
        for (Intent intent : POWERMANAGER_INTENTS) {
            if (LinphoneDeviceUtils.isIntentCallable(context, intent)) {
                return intent;
            }
        }
        return null;
    }

    public static boolean hasDevicePowerManager(Context context) {
        return getDevicePowerManagerIntent(context) != null;
    }

    public static void displayDialogIfDeviceHasPowerManagerThatCouldPreventPushNotifications(final Resources R, final Context context) {
        if (LinphonePreferences.instance().hasPowerSaverDialogBeenPrompted()) {
            return;
        }

        List<Intent> intents = new ArrayList();

        for (final Intent intent : POWERMANAGER_INTENTS) {
            if (LinphoneDeviceUtils.isIntentCallable(context, intent)) {
                Log.w("LinphoneDeviceUtils",
                        android.os.Build.MANUFACTURER +
                        " device with power saver detected: " +
                        intent.getComponent().getClassName());
                Log.w("LinphoneDeviceUtils", "[Hacks] Asking power saver for whitelist !");
/*
                String name = "Настройки";

                try {
                    android.util.Log.d("DeviceUtils", intent.getComponent().getPackageName());

                    ApplicationInfo app = context.getPackageManager().getApplicationInfo(intent.getComponent().getPackageName(), 0);

                    name = (String) (app != null ? context.getPackageManager().getApplicationLabel(app) : "");

                    android.util.Log.d("DeviceUtils", name);
                } catch (NameNotFoundException e) {
                    android.util.Log.d("DeviceUtils", "error");
                }
*/
                final Dialog dialog = new Dialog(context);
                dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
                Drawable d =
                        new ColorDrawable(0xFF444444);
                d.setAlpha(200);
//
//                dialog.setContentView((View) R.getLayout(R.getIdentifier("dialog","layout", context.getPackageName())));
//                dialog.getWindow()
//                        .setLayout(
//                                WindowManager.LayoutParams.MATCH_PARENT,
//                                WindowManager.LayoutParams.MATCH_PARENT);
//                dialog.getWindow().setBackgroundDrawable(d);
//
//                TextView customText = dialog.findViewById(R.id.dialog_message);
//                customText.setText("Чтобы приложение могло принимать звонки домофона в фоновом режиме, используя push-уведомления, приложение должно быть в белом списке.");
//
//                TextView customTitle = dialog.findViewById(R.id.dialog_title);
//                customTitle.setText("Обнаружено энергосбережение!");
//
//                dialog.findViewById(R.id.dialog_do_not_ask_again_layout)
//                        .setVisibility(View.VISIBLE);
//                final CheckBox doNotAskAgain = dialog.findViewById(R.id.doNotAskAgain);
//                dialog.findViewById(R.id.doNotAskAgainLabel)
//                        .setOnClickListener(
//                                new View.OnClickListener() {
//                                    @Override
//                                    public void onClick(View v) {
//                                        doNotAskAgain.setChecked(!doNotAskAgain.isChecked());
//                                    }
//                                });
//
//                Button accept = dialog.findViewById(R.id.dialog_ok_button);
//                accept.setVisibility(View.VISIBLE);
//                accept.setText("Настройки");
//                accept.setOnClickListener(
//                        new View.OnClickListener() {
//                            @Override
//                            public void onClick(View v) {
//                                Log.w(
//                                        "[Hacks] Power saver detected, user is going to settings :)");
//                                // If user is going into the settings,
//                                // assume it will make the change so don't prompt again
//                                LinphonePreferences.instance().powerSaverDialogPrompted(true);
//
//                                try {
//                                    context.startActivity(intent);
//                                } catch (SecurityException se) {
//                                    Log.e(
//                                            "[Hacks] Couldn't start intent [",
//                                            intent.getComponent().getClassName(),
//                                            "], security exception was thrown: ",
//                                            se);
//                                }
//                                dialog.dismiss();
//                            }
//                        });
//
//                Button cancel = dialog.findViewById(R.id.dialog_cancel_button);
//                cancel.setText("Пропустить");
//                cancel.setOnClickListener(
//                        new View.OnClickListener() {
//                            @Override
//                            public void onClick(View v) {
//                                Log.w(
//                                        "[Hacks] Power saver detected, user didn't go to settings :(");
//                                if (doNotAskAgain.isChecked()) {
//                                    LinphonePreferences.instance()
//                                            .powerSaverDialogPrompted(true);
//                                }
//                                dialog.dismiss();
//                            }
//                        });
//
//                Button delete = dialog.findViewById(R.id.dialog_delete_button);
//                delete.setVisibility(View.GONE);
//
//                dialog.show();

                return;
            }
        }
    }

    private static boolean isIntentCallable(Context context, Intent intent) {
        List<ResolveInfo> list =
                context.getPackageManager()
                        .queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
        return list.size() > 0;
    }
}
