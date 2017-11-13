package com.liubowang.dubbing.HunYin;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.liubowang.dubbing.JianJi.TimeRulerView;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.SBUtil;

/**
 * Created by heshaobo on 2017/10/26.
 */

public class MusicPickerView extends RelativeLayout {

    private static final String TAG  = MusicPickerView.class.getSimpleName();
    private MusicTextView musicTextView;
    private FrameLayout verticalView;
    private FrameLayout previewVerticalView;
    private TimeRulerView timeRulerView;
    private float lastX;
    private int videoDuration;
    private int musicDuration;
    private float clipValue = 0;
    private float startValue = 0;
    private boolean isCanClipMusic = false;
    private Context context;
    public MusicPickerView(Context context) {
        super(context);
        initSubViews(context);
    }

    public MusicPickerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initSubViews(context);
    }


    public MusicPickerView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubViews(context);
    }
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public MusicPickerView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubViews(context);
    }

    public float getClipValue() {
        return clipValue;
    }

    public float getStartValue() {
        return startValue;
    }

    public boolean isCanClipMusic(){
        return isCanClipMusic;
    }
    public void setMusicTitle(String title){
        musicTextView.setTitle(title);
    }


    private void initSubViews(Context context){
        this.context = context;
        LayoutInflater inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_music_pciker,this,true);
        musicTextView = findViewById(R.id.mtv_music_length_mpv);
        musicTextView.setOnTouchListener(touchListener);
        verticalView = findViewById(R.id.rl_vertical_mpv);
        timeRulerView = findViewById(R.id.trv_ruler_mpv);
        previewVerticalView = findViewById(R.id.rl_preview_vertical_mpv);
    }

    public void relayout(int videoDuration,int musicDuration){
        this.videoDuration = videoDuration;
        this.musicDuration = musicDuration;
        float scale = 1;
        if (musicDuration > 0 && videoDuration > 0){
            scale = (musicDuration * 1.0f ) / (videoDuration * 1.0f);
        }
        isCanClipMusic = false;
        clipValue = 0;
        startValue = 0;
        float width = getWidth() * scale;
        musicTextView.layout(0,musicTextView.getTop(),(int)width,musicTextView.getBottom());
        adjustVerticalView();
    }

    public void setPreviewVisibility(boolean visibility){
        if (visibility){
            previewVerticalView.setVisibility(VISIBLE);
        }else {
            previewVerticalView.setVisibility(INVISIBLE);
        }
    }

    public void setPreviewValue(int position){
        float value = (position * 1.0f) / (videoDuration* 1.0f);
        int left = (int)(getWidth()*value);
        previewVerticalView.layout(left,
                previewVerticalView.getTop(),
                left + 1,
                previewVerticalView.getBottom());
    }

    private OnTouchListener touchListener = new OnTouchListener() {
        @Override
        public boolean onTouch(View view, MotionEvent motionEvent) {
            float x = motionEvent.getX();
            switch(motionEvent.getAction()){
                case MotionEvent.ACTION_DOWN:
                    lastX = x;
                    break;
                case MotionEvent.ACTION_MOVE:
                    //计算移动的距离
                    float offX = x - lastX;
                    moveView((int) offX);
                    break;
                case MotionEvent.ACTION_UP:
                    timeRulerView.setDrawText(null,0);
                    musicTextView.setClipTime(null,0);
                    break;
            }
            return true;
        }
    };

    private void moveView(int offsetX){
        if (musicTextView.getLeft() < getWidth()){
            musicTextView.offsetLeftAndRight(offsetX);
        }
        adjustVerticalView();
    }

    private void adjustVerticalView(){
        int verleft = musicTextView.getLeft();
        if (verleft < 0) verleft = 0;
        if (verleft > getWidth()) verleft = getWidth() - 1;
        verticalView.layout(verleft,
                verticalView.getTop(),
                verleft + 1,
                verticalView.getBottom());
        startValue =(verleft * 1.0f) / (getWidth() * 1.0f) ;
        if (videoDuration > 0 && musicTextView.getLeft() >= 0){
            float startTime = videoDuration * startValue;
            String startTimeString = SBUtil.getTimeFormat((int) startTime);
            timeRulerView.setDrawText(startTimeString,startValue);
        }else {
            timeRulerView.setDrawText(null,startValue);
        }

        if (musicTextView.getLeft() < 0){
            isCanClipMusic = true;
            int clip = Math.abs(musicTextView.getLeft());
            clipValue = (clip * 1.0f) / (musicTextView.getWidth() * 1.0f);
            if (musicDuration > 0){
                float clipTime = musicDuration * clipValue;
                String clipTimeString = SBUtil.getTimeFormat((int) clipTime);
                musicTextView.setClipTime(clipTimeString,clipValue);
            }
        }else {
            isCanClipMusic = false;
        }
    }

}
