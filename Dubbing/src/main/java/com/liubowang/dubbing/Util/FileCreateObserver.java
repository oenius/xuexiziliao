package com.liubowang.dubbing.Util;

import android.os.FileObserver;
import android.util.Log;

/**
 * Created by heshaobo on 2017/10/24.
 */

public class FileCreateObserver extends FileObserver {

    private OnFileCreatedListener fileCreatedListener;

    public FileCreateObserver(String filepath){
        super(filepath,FileObserver.CREATE);
    }

    public void setFileCreatedListener(OnFileCreatedListener fileCreatedListener) {
        this.fileCreatedListener = fileCreatedListener;
    }

    @Override
    public void onEvent(int i, String s) {
        if (i == CREATE){
            if (fileCreatedListener != null){
                fileCreatedListener.onFileCreated(s);
            }
        }
    }

    public interface OnFileCreatedListener{
        void onFileCreated(String path);
    }

}
