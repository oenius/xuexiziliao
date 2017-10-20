package com.liubowang.dubbing.Util;

import android.app.Activity;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;

/**
 * Created by heshaobo on 2017/10/18.
 */

public class ChooseFileUtil {

    private static final String TAG = ChooseFileUtil.class.getSimpleName();

    public enum FileType {
        IMAGE,AUDIO,VIDEO
    }

    public static void chooseFile(@NonNull Activity activity, FileType fileType , int resultCode){
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        switch (fileType){
            case IMAGE:
                intent.setType("image/*");
                break;
            case VIDEO:
                intent.setType("video/*");
                break;
            case AUDIO:
                intent.setType("audio/*");
                break;
        }
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(activity.getPackageManager()) != null){
            activity.startActivityForResult(intent,resultCode);
        }else {
            Log.d(TAG,"文件选择启动失败");
        }
    }
}
