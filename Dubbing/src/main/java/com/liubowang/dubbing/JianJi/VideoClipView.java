package com.liubowang.dubbing.JianJi;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Loader;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Environment;
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
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.BitmpUtil;
import com.liubowang.dubbing.Util.Command;
import com.liubowang.dubbing.Util.FFmpegUtil;
import com.liubowang.dubbing.Util.FileCreateObserver;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.SBUtil;

import java.io.File;
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
    private FrameLayout leftMaskView;
    private FrameLayout rightMaskView;
    private FrameLayout leftVerticalView;
    private FrameLayout rightVerticalView;
    private FrameLayout previewVerticalView;
    private ProgressBar progressBar;
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
        leftVerticalView = findViewById(R.id.rl_left_vertical_view);
        rightVerticalView = findViewById(R.id.rl_right_vertical_view);
        progressBar = findViewById(R.id.pb_frames_progress_vcv);
        previewVerticalView = findViewById(R.id.rl_preview_vertical_view);

    }

    public float getLeftValue() {
        return leftValue;
    }

    public float getRightValue() {
        return rightValue;
    }

    public void onPreview(float value){
        if (previewVerticalView.getVisibility() == INVISIBLE){
            previewVerticalView.setVisibility(VISIBLE);
        }
        int youxiaoWidth = frameView.getWidth();
        int leftDistance = (int)(youxiaoWidth * value);
        int left = frameView.getLeft() + leftDistance;
        previewVerticalView.layout(left,
                previewVerticalView.getTop(),
                left + 1,
                previewVerticalView.getBottom());
    }

    public void stopPreview(){
        if (previewVerticalView.getVisibility() == VISIBLE){
            previewVerticalView.setVisibility(INVISIBLE);
        }
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
        leftImageView.offsetLeftAndRight((int) offsetX);
        leftVerticalView.offsetLeftAndRight((int) offsetX);
    }

    private void adjustLeftMaskView(){
        int width = leftImageView.getRight() - leftImageView.getWidth() / 2 - leftMaskView.getLeft();
        leftMaskView.layout(leftMaskView.getLeft(),
                            leftMaskView.getTop(),
                            leftMaskView.getLeft() + width,
                            leftMaskView.getBottom());
    }

    private void adjustRightImageView(float offsetX){
        rightImageView.offsetLeftAndRight((int) offsetX);
        rightVerticalView.offsetLeftAndRight((int) offsetX);
    }

    private void adjustRightMaskView(){
        int width = rightMaskView.getRight() - rightImageView.getWidth() / 2 - rightImageView.getLeft();
        rightMaskView.layout(rightMaskView.getRight() - width,
                rightMaskView.getTop(),
                rightMaskView.getRight(),
                rightMaskView.getBottom());
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

    public void setLeftValue(float leftValue) {
        if (leftValue > rightValue){
            this.leftValue = rightValue - 0.01f;
        }else {
            this.leftValue = leftValue;
        }

        int youxiaoWidth = frameView.getWidth();
        int leftDistance = (int)(youxiaoWidth * this.leftValue);
        int left = frameView.getLeft() + leftDistance - leftImageView.getWidth()/2;
        leftImageView.layout(
                left,
                leftImageView.getTop(),
                left + leftImageView.getWidth() + 1,
                leftImageView.getBottom());
        leftVerticalView.layout(leftImageView.getLeft()+leftImageView.getWidth()/2,
                leftVerticalView.getTop(),
                leftImageView.getLeft()+leftImageView.getWidth()/2+1,
                leftVerticalView.getBottom());
        adjustLeftMaskView();
    }

    public void setRightValue(float rightValue) {
        if (rightValue < leftValue){
            this.rightValue = leftValue - 0.01f;
        }else {
            this.rightValue = rightValue;
        }
        int youxiaoWidth = frameView.getWidth();
        int leftDistance = (int)(youxiaoWidth * this.rightValue);
        int left = frameView.getLeft() + leftDistance - rightImageView.getWidth()/2;
        rightImageView.layout(
                left,
                rightImageView.getTop(),
                left + rightImageView.getWidth() - 1,
                rightImageView.getBottom());
        rightVerticalView.layout(rightImageView.getLeft() + rightImageView.getWidth()/2 ,
                rightVerticalView.getTop(),
                rightImageView.getLeft() + rightImageView.getWidth()/2 + 1,
                rightVerticalView.getBottom());
        adjustRightMaskView();
    }

    public void reset(){
        leftImageView.layout(1,
                leftImageView.getTop(),
                leftImageView.getWidth()+1,
                leftImageView.getBottom());
//        leftVerticalView.layout(leftImageView.getWidth()/2,
//                leftVerticalView.getTop(),
//                leftImageView.getWidth()/2+1,
//                leftVerticalView.getBottom());
        leftVerticalView.layout(leftImageView.getLeft()+leftImageView.getWidth()/2,
                leftVerticalView.getTop(),
                leftImageView.getLeft()+leftImageView.getWidth()/2+1,
                leftVerticalView.getBottom());

//        leftMaskView.layout(leftMaskView.getLeft(),
//                leftMaskView.getTop(),
//                0,
//                leftMaskView.getBottom());
        adjustLeftMaskView();

        rightImageView.layout(getWidth() - rightImageView.getWidth() -1,
                rightImageView.getTop(),
                getWidth()-1,
                rightImageView.getBottom());
//        rightVerticalView.layout(getWidth() - rightImageView.getWidth()/2 - 1,
//                rightVerticalView.getTop(),
//                getWidth()- rightImageView.getWidth()/2,
//                rightVerticalView.getBottom());
        rightVerticalView.layout(rightImageView.getLeft() + rightImageView.getWidth()/2 ,
                rightVerticalView.getTop(),
                rightImageView.getLeft() + rightImageView.getWidth()/2 + 1,
                rightVerticalView.getBottom());
        adjustRightMaskView();
//        rightMaskView.layout(getWidth(),
//                rightMaskView.getTop(),
//                getWidth()-rightImageView.getWidth()/2,
//                rightMaskView.getBottom());
        frameView.setClean(true);
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

    private ArrayList<Bitmap> videoFrames = new ArrayList<>();
    private FileCreateObserver fileCreateObserver;
    private int imageCount;

    public void setVideoFramesFFmpeg(final String videoPath){
        progressBar.setVisibility(VISIBLE);
        new Thread(){
            @Override
            public void run() {
                MediaMetadataRetriever mmr = new MediaMetadataRetriever();
                mmr.setDataSource(videoPath);
                long videoLength = Long.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                int VIDEO_WIDTH = Integer.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
                int VIDEO_HEIGHT = Integer.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
                int VIDEO_ROTATION = Integer.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)) ;
                Log.d(TAG,"VIDEO_WIDTH:"+VIDEO_WIDTH);
                Log.d(TAG,"VIDEO_HEIGHT:"+VIDEO_HEIGHT);
                Log.d(TAG,"VIDEO_ROTATION:"+VIDEO_ROTATION);
                float videoWidth = 50;
                float videoHeight = 100;
                if (VIDEO_ROTATION == 90|| VIDEO_ROTATION == 270){
                    videoHeight = VIDEO_WIDTH*1.0f;
                    videoWidth = VIDEO_HEIGHT*1.0f;
                }
                if (VIDEO_ROTATION == 0||VIDEO_ROTATION == 180){
                    videoHeight = VIDEO_HEIGHT*1.0f;
                    videoWidth = VIDEO_WIDTH*1.0f;
                }
                float scale = videoWidth/videoHeight;
                float frameHeight = frameView.getHeight();
                if (frameHeight < 100){
                    frameHeight = 100;
                }
                float frameWidth = frameHeight * scale;
                imageCount = (int) (((frameView.getWidth()*1.0f) / frameWidth) * 1.2) + 1;
                if (imageCount < 8){
                    imageCount = 8;//最低十张
                }
                String tmpPath = FileUtil.getTmpPath();
                String fileSuffix = ".jpg";
                String tmpImagesDirPath = tmpPath+System.currentTimeMillis();
                File dir = new File(tmpImagesDirPath);
                int fileNo = 0;
                while (dir.exists()) {
                    fileNo++;
                    dir = new File(tmpImagesDirPath+fileNo);
                }
                dir.mkdir();

                {//FFmpeg方法
                    File dest = new File(dir,"%03d" + fileSuffix);
                    float numberPerSec = imageCount / (videoLength*1.0f / 1000);
                    String[] commands = Command.getInstance().extractImage(
                            videoPath,
                            dest.getAbsolutePath(),
                            0,
                            videoLength*1.0f/1000,
                            numberPerSec,
                            (int) frameWidth,
                            (int) frameHeight);
                    FFmpegLoadFrameImages(commands,dir);
                }

//                {
//                    final File finalDir = dir;
//                    getActivity().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            progressBar.setVisibility(INVISIBLE);
//                            String filePath = finalDir.getAbsolutePath();
//                            fileCreateObserver = new FileCreateObserver(filePath);
//                            fileCreateObserver.setFileCreatedListener(new FileCreateObserver.OnFileCreatedListener() {
//                                @Override
//                                public void onFileCreated(String path) {
//                                    loadVideoFrames(finalDir);
//                                }
//                            });
//                            fileCreateObserver.startWatching();
//                        }
//                    });
//                    int numberPerSec = (int) (videoLength / imageCount);
//                    Log.d(TAG,"videoLength = "+ videoLength);
//                    for (int i = 0;i < imageCount; i++){
//                        int time = numberPerSec * i;
//                        Log.d(TAG,"time = " + time );
//                        Bitmap bitmap = mmr.getFrameAtTime(time);
////                        bitmap =BitmpUtil.scaleBitmpToMaxSize(bitmap,200);
//                        if (bitmap == null){
//                            continue;
//                        }
//                        bitmap = Bitmap.createScaledBitmap(bitmap,(int) frameWidth,(int) frameHeight,true);
//                        File filePath = new File(dir,i + ".png");
//                        SBUtil.writeBitmap(filePath,bitmap);
//                    }
//                    getActivity().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            loadVideoFrames(finalDir);
//                            if (fileCreateObserver != null){
//                                fileCreateObserver.stopWatching();
//                            }
//                        }
//                    });
//
//                }


            }
        }.start();
    }

    private void FFmpegLoadFrameImages(String[] commands, final File imageFile){
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {
                Log.d(TAG,"onNotSupport");
            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:" + s);
            }

            @Override
            public void onSuccess(String s) {
                loadVideoFrames(imageFile);
            }

            @Override
            public void onProgress(String s) {
                Log.d(TAG,"onProgress:" + s);
            }
            @Override
            public void onStart() {
                Log.d(TAG,"onStart");
                Log.d(TAG,"Thread:"+Thread.currentThread().getName());
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        progressBar.setVisibility(INVISIBLE);
                        String filePath = imageFile.getAbsolutePath();
                        fileCreateObserver = new FileCreateObserver(filePath);
                        fileCreateObserver.setFileCreatedListener(new FileCreateObserver.OnFileCreatedListener() {
                            @Override
                            public void onFileCreated(String path) {
                                loadVideoFrames(imageFile);
                            }
                        });
                        fileCreateObserver.startWatching();
                    }
                });
            }

            @Override
            public void onFinish() {
                Log.d(TAG,"onFinish");
                if (fileCreateObserver != null){
                    fileCreateObserver.stopWatching();
                }
            }
        });
    }


    private synchronized void loadVideoFrames(final File imageFile){
        File[] listFile = imageFile.listFiles();
        if (listFile.length == videoFrames.size()){
            return;
        }
        videoFrames = new ArrayList<>();
        for(File e:listFile)
        {
            String path = e.getAbsolutePath();
            Bitmap bitmap = BitmapFactory.decodeFile(path);
            videoFrames.add(bitmap);
        }
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                int count = Math.max(videoFrames.size(),imageCount);
                frameView.setVideoFrames(videoFrames,count);
            }
        });
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
