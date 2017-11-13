package com.liubowang.dubbing.Util;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;
import android.util.Log;

import com.github.hiteshsondhi88.libffmpeg.ExecuteBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.FFmpeg;
import com.github.hiteshsondhi88.libffmpeg.LoadBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegCommandAlreadyRunningException;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegNotSupportedException;

/**
 * Created by heshaobo on 2017/10/17.
 */

public class FFmpegUtil {

    private static final String TAG = FFmpegUtil.class.getSimpleName();
    private static  FFmpeg mFFmpeg;
    private static FFmpegUtil singleton = null;
    private FFmpegUtil(){};
    public static FFmpegUtil getInstance() {
        if (singleton == null) {
            synchronized (FFmpegUtil.class) {
                if (singleton == null) {
                    singleton = new FFmpegUtil();
                }
            }
        }
        return singleton;
    }

    public void initFFmpeg(Context context){
        mFFmpeg = FFmpeg.getInstance(context);
        Log.d(TAG,"initFFmpeg()");
        loadFFMpegBinary(null);
    }

    private void loadFFMpegBinary(final FFmpegListener listener){
        try {
            mFFmpeg.loadBinary(new LoadBinaryResponseHandler() {
                @Override
                public void onFailure() {
                    if (listener != null){
                        listener.onNotSupport();
                    }
                }
            });
        } catch (FFmpegNotSupportedException e) {
            if (listener != null){
                listener.onNotSupport();
            }
        }
    }

    public boolean isFFmpegCommandRunning(){
        return mFFmpeg.isFFmpegCommandRunning();
    }

    public boolean killRunningProcesses(){
        return mFFmpeg.killRunningProcesses();
    }

    public void execFFmpegBinary(String[] command, final FFmpegListener listener) {
        if (isFFmpegCommandRunning()){
            Log.d(TAG,"FFmpeg正在执行上个命令，无法执行新命令");
            return;
        }
        try {
            mFFmpeg.execute(command, new ExecuteBinaryResponseHandler() {
                @Override
                public void onFailure(String s) {
                    listener.onFailure(s);
                }

                @Override
                public void onSuccess(String s) {
                    listener.onSuccess(s);
                }

                @Override
                public void onProgress(String s) {
                    listener.onProgress(s);
                }

                @Override
                public void onStart() {
                    listener.onStart();
                }

                @Override
                public void onFinish() {
                    listener.onFinish();
                }
            });
        } catch (FFmpegCommandAlreadyRunningException e) {
            // do nothing for now
        }
    }


    public interface FFmpegListener {
        void onNotSupport();
        void onFailure(String s);
        void onSuccess(String s);
        void onProgress(String s);
        void onStart();
        void onFinish();
    }


}
