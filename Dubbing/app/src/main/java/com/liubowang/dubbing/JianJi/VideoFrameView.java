package com.liubowang.dubbing.JianJi;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.View;

import java.util.ArrayList;

/**
 * Created by heshaobo on 2017/10/18.
 */

public class VideoFrameView extends View {

    private ArrayList<Bitmap> videoFrames;

    public VideoFrameView(Context context) {
        super(context);
    }

    public VideoFrameView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public VideoFrameView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public VideoFrameView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public void setVideoFrames(ArrayList<Bitmap> videoFrames) {
        this.videoFrames = videoFrames;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (videoFrames == null || videoFrames.size() <= 0){
            super.onDraw(canvas);
        }else {
            for (int i = 0 ; i < videoFrames.size(); i ++){
                Bitmap bitmap = videoFrames.get(i);
                float width = bitmap.getWidth();
                float left = (width / 2) * i;
                canvas.drawBitmap(bitmap,left,0,null);
            }
        }

    }
}
