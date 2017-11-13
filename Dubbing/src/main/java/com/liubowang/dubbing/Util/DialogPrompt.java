package com.liubowang.dubbing.Util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/11/4.
 */

public class DialogPrompt {

        public static void showText(String text, Activity activity){
            AlertDialog.Builder builder = new AlertDialog
                    .Builder(activity);
            builder.setMessage(text);

            builder.setPositiveButton(activity.getString(R.string.sure), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    dialogInterface.dismiss();
                }
            });
            final AlertDialog dialog = builder.create();
            dialog.show();
        }
}
