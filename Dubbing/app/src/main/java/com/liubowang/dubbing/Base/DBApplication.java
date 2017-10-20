package com.liubowang.dubbing.Base;

import android.app.Application;

import com.liubowang.dubbing.Util.FFmpegUtil;

/**
 * Created by heshaobo on 2017/10/17.
 */

public class DBApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        FFmpegUtil.initFFmpeg(this);
    }
}
