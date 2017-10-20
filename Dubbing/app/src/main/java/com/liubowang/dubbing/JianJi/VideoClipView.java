package com.liubowang.dubbing.JianJi;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Loader;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Looper;
import android.support.annotation.AttrRes;
import android.support.annotation.FloatRange;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.support.annotation.StyleRes;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.BitmpUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

/**
 * Created by heshaobo on 2017/10/18.
 */

public class VideoClipView extends RelativeLayout {

    private static final String TAG = VideoClipView.class.getSimpleName();
    private ImageView leftImageView;
    private ImageView rightImageView;
    private VideoFrameView frameView;
    private RelativeLayout leftMaskView;
    private RelativeLayout rightMaskView;
    private OnValueChangedListener valueChangedListener;
    private ImageView currentTouchImageView;
    private Context context;
    private float leftValue = 0;
    private float rightValue = 1;

    public VideoClipView(@NonNull Context context) {
        super(context);
        initSubViews(context);
    }

    public VideoClipView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initSubViews(context);
    }

    public VideoClipView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubViews(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public VideoClipView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr, @StyleRes int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubViews(context);
    }

    private void initSubViews(Context context){
        this.context = context;
        LayoutInflater inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_video_clip,this,true);

        leftImageView =  findViewById(R.id.iv_tip_left);
        leftImageView.setOnTouchListener(touchListener);
        rightImageView = findViewById(R.id.iv_tip_right);
        rightImageView.setOnTouchListener(touchListener);
        frameView =  findViewById(R.id.vfv_frame_view);
        leftMaskView = findViewById(R.id.rl_left_mask_view);
        rightMaskView = findViewById(R.id.rl_right_mask_view);

    }
    public float getLeftValue() {
        return leftValue;
    }

    public float getRightValue() {
        return rightValue;
    }

    public void setValueChangedListener(OnValueChangedListener valueChangedListener) {
        this.valueChangedListener = valueChangedListener;
    }

    private OnTouchListener touchListener = new OnTouchListener() {
        @Override
        public boolean onTouch(View view, MotionEvent motionEvent) {
            if (view == leftImageView){
                currentTouchImageView = leftImageView;
            }
            else if (view == rightImageView){
                currentTouchImageView = rightImageView;
            }
            moveView(motionEvent);
            return true;
        }
    };

    private void moveView(MotionEvent motionEvent){
        float x = motionEvent.getX();
        float lastX = 0;
        switch(motionEvent.getAction()){
            case MotionEvent.ACTION_DOWN:
                lastX = x;
                break;
            case MotionEvent.ACTION_MOVE:
                //计算移动的距离
                float offX = x - lastX;
                if (canMoveImageView(offX)){
                    Log.d(TAG,"currentTouchImageView.offsetLeftAndRight"+ offX);
                    if (currentTouchImageView == leftImageView){
                        adjustLeftImageView(offX);
                        adjustLeftMaskView();
                    }else {
                        adjustRightImageView(offX);
                        adjustRightMaskView();
                    }
                    sendAction();
                }
                break;
        }
    }

    private void adjustLeftImageView(float offsetX){
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) leftImageView.getLayoutParams();
        layoutParams.leftMargin += offsetX;
        leftImageView.setLayoutParams(layoutParams);
    }

    private void adjustLeftMaskView(){
        int width = leftImageView.getRight() - leftImageView.getWidth() / 2 - leftMaskView.getLeft();
        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams)leftMaskView.getLayoutParams();
        lp.width = width;
        leftMaskView.setLayoutParams(lp);
    }
    private void adjustRightImageView(float offsetX){
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) rightImageView.getLayoutParams();
        layoutParams.rightMargin -= offsetX;
        rightImageView.setLayoutParams(layoutParams);
    }
    private void adjustRightMaskView(){
        int width = rightMaskView.getRight() - rightImageView.getWidth() / 2 - rightImageView.getLeft();

        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams)rightMaskView.getLayoutParams();
        lp.width = width;
        rightMaskView.setLayoutParams(lp);
    }

    private void sendAction(){
        if (valueChangedListener == null){
            return;
        }
        int youxiaoWidth = frameView.getWidth();
        if (currentTouchImageView == leftImageView){
            int distance =   (leftImageView.getLeft() + leftImageView.getWidth() / 2)
                              - frameView.getLeft();
            leftValue = (distance*1.0f) / (youxiaoWidth*1.0f);
            if (leftValue >=0 && leftValue <= 1.0){
                valueChangedListener.onLeftValueChanged(leftValue);
            }

        }else {
            int distance =   (rightImageView.getLeft() + rightImageView.getWidth() / 2)
                             - frameView.getLeft();
            rightValue = (distance*1.0f) / (youxiaoWidth*1.0f);
            if (rightValue >=0 && rightValue <= 1.0){
                valueChangedListener.onRightValueChanged(rightValue);
            }
        }
    }

    public void reset(){
        RelativeLayout.LayoutParams lpli = (RelativeLayout.LayoutParams) leftImageView.getLayoutParams();
        lpli.leftMargin = 0;
        leftImageView.setLayoutParams(lpli);

        RelativeLayout.LayoutParams lpri = (RelativeLayout.LayoutParams) rightImageView.getLayoutParams();
        lpri.rightMargin = 0;
        rightImageView.setLayoutParams(lpri);

        RelativeLayout.LayoutParams lplm = (RelativeLayout.LayoutParams)leftMaskView.getLayoutParams();
        lplm.width = 0;
        leftMaskView.setLayoutParams(lplm);
        RelativeLayout.LayoutParams lprm = (RelativeLayout.LayoutParams)rightMaskView.getLayoutParams();
        lprm.width = 0;
        rightMaskView.setLayoutParams(lprm);
    }

    private boolean canMoveImageView(float offsetX){
        boolean canMove = true;
        if (currentTouchImageView == leftImageView) {
            if (offsetX < 0) {
                if (leftImageView.getLeft() <= 0) {
                    canMove = false;
                }
            }
            else if (offsetX > 0) {
                if (leftImageView.getRight() >= rightImageView.getLeft()) {
                    canMove = false;
                }
            }
            else {
                canMove = false;
            }
        }else {
            if (offsetX > 0) {
                if (rightImageView.getRight() >= getWidth()) {
                    canMove = false;
                }
            }
            else if (offsetX < 0) {
                if (rightImageView.getLeft() <= leftImageView.getRight()) {
                    canMove = false;
                }
            }
            else {
                canMove = false;
            }
        }
        return canMove;
    }


    private MediaMetadataRetriever mediaMetadataRetriever;
    private int frameCount = 0;
    private ArrayList<Bitmap> videoFrames;
    private long videoDuration = 0;
    public void setVideoFrame(final String videoUri){
        new Thread(){
            @Override
            public void run() {
                mediaMetadataRetriever = new MediaMetadataRetriever();
                mediaMetadataRetriever.setDataSource(videoUri);
                videoDuration = Long.valueOf(mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)); // 播放时长单位为毫秒
//                float videoWidth = Float.valueOf(mediaMetadataRetriever.extractMetadata(
//                        android.media.MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));//宽
//                float videoHeight = Float.valueOf(mediaMetadataRetriever.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));//高
                Bitmap bp = mediaMetadataRetriever.getFrameAtTime(10);
                float videoWidth = bp.getWidth();
                float videoHeight = bp.getHeight();
                bp.recycle();
                float scale = videoWidth/videoHeight;
                float frameHeight = frameView.getHeight();
                float frameWidth = frameHeight * scale;
                frameCount = (int) ((frameView.getWidth()*1.0f) / frameWidth * 2);
                videoFrames = new ArrayList<>();
                Log.d(TAG,"frameWidth" + frameWidth);
                Log.d(TAG,"frameHeight" + frameHeight);

                loadVideoFrames(0,(int) frameWidth,(int) frameHeight);
            }
        }.start();

    }

    private void loadVideoFrames(final int index , final int frameWidth ,final int frameHeight){
        new Thread(){
            @Override
            public void run() {
                if (index > frameCount) {
                    return;
                }
                long timedistance  = videoDuration / frameCount;
                long frameTime = index * timedistance;
                if (frameTime > videoDuration) {
                    frameTime = videoDuration;
                }
                Log.d(TAG,"frameTime:"+ frameTime);
                Bitmap bp = mediaMetadataRetriever.getFrameAtTime(frameTime*1000,MediaMetadataRetriever.OPTION_CLOSEST_SYNC);
//                Bitmap bitmap = mmr.getFrameAtTime(seekbar.getProgress(),
//                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC);
                Bitmap newbp = Bitmap.createScaledBitmap(bp, frameWidth,frameHeight,false);
                videoFrames.add(newbp);
                bp.recycle();
                Activity activity = getActivity();
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        frameView.setVideoFrames(videoFrames);
                        loadVideoFrames(index + 1,frameWidth,frameHeight);
                    }
                });
            }
        }.start();
    }

    private Activity getActivity() {
        Context context = getContext();
        while (context instanceof ContextWrapper) {
            if (context instanceof Activity) {
                return (Activity)context;
            }
            context = ((ContextWrapper)context).getBaseContext();
        }
        return null;
    }


    interface OnValueChangedListener{
        void onLeftValueChanged(@FloatRange(from = 0.0,to = 1.0) float leftValue);
        void onRightValueChanged(@FloatRange(from = 0.0,to = 1.0) float rightValue);
    }

}
