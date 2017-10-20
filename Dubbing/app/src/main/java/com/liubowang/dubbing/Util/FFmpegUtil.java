package com.liubowang.dubbing.Util;

import android.content.Context;
import android.support.annotation.NonNull;
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

    public static void initFFmpeg(Context context){
        mFFmpeg = FFmpeg.getInstance(context);
        Log.d(TAG,"initFFmpeg()");
    }

    public static void loadFFMpegBinary(@NonNull final FFmpegListener listener){
        try {
            mFFmpeg.loadBinary(new LoadBinaryResponseHandler() {
                @Override
                public void onFailure() {
                    listener.onNotSupport();
                }
            });
        } catch (FFmpegNotSupportedException e) {
            listener.onNotSupport();
        }
    }


    public static void execFFmpegBinary(final String[] command,@NonNull final FFmpegListener listener) {
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

    public static class Command {
        public static String[] clipVideo(String videoUrl,
                                         String outputUrl,
                                         String beginTime,
                                         String timeLength){
            String[] commands = new String[12];
            commands[0] = "ffmpeg";
            commands[1] = "-i";
            commands[2] = videoUrl;
            commands[3] = "-ss";
            commands[4] = beginTime;
            commands[5] = "-t";
            commands[6] = timeLength;
            commands[7] = "-acodec";
            commands[8] = "copy";
            commands[9] = "-vcodec";
            commands[10] = "copy";
            commands[11] = outputUrl;
            return commands;
        }

        /**
         * 背景音乐
         */
        public static String[] addMusic(String musicUrl,
                                        String videoUrl,
                                        String outputUrl){
//        Log.d("LOGCAT","add music");
            String[] commands = new String[7];
            commands[0] = "ffmpeg";
            //输入
            commands[1] = "-i";
            commands[2] = videoUrl;
            //音乐
            commands[3] = "-i";
            commands[4] = musicUrl;
            //覆盖输出
            commands[5] = "-y";
            //输出文件
            commands[6] = outputUrl;
            return commands;
        }
    }



}
