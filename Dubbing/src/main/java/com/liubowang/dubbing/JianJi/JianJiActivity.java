package com.liubowang.dubbing.JianJi;

import android.content.Intent;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.FloatRange;
import android.support.v7.widget.Toolbar;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.VideoView;

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.ChooseFileUtil;
import com.liubowang.dubbing.Util.Command;
import com.liubowang.dubbing.Util.DialogPrompt;
import com.liubowang.dubbing.Util.FFmpegUtil;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.ProgressHUD;
import com.liubowang.dubbing.Videos.VideoPlayActivity;

import java.io.File;
import java.lang.reflect.Field;
import java.net.URISyntaxException;

public class JianJiActivity extends DBBaseActiviry implements View.OnClickListener {
    private static final String TAG = JianJiActivity.class.getSimpleName();
    private static final int REQUEST_VIDEO_CODE_JJ = 834;
    private static final int DELAY_TIME = 100;
    private static final int SHOW_PREVIEW_BUTTON_VIDEO_DURATION = 20000;
    private VideoView videoView;
    private VideoClipView clipView;
    private String videoPath;
    private int videoDuration;
    private ImageButton playButton;
    private ImageButton leftCutButton;
    private ImageButton rightCutButton;
    private ImageButton previewButton;
    private TimeBoardView timeBoardView;
    private SeekBar timeSeekBar;
    private TextView promptView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_jian_ji);
        initUI();
        setOverflowShowingAlways();
    }



    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_jj);
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_jj);
        setStatusBar(imageView);
        videoView = (VideoView) findViewById(R.id.vv_video_view_jj);
        videoView.setZOrderOnTop(true);
        clipView = (VideoClipView) findViewById(R.id.vcv_clip_view_jj);
        clipView.setValueChangedListener(valueChangedListener);
        playButton = (ImageButton) findViewById(R.id.ib_play_jj);
        playButton.setOnClickListener(this);
        playButton.setTag(false);
        leftCutButton = (ImageButton) findViewById(R.id.ib_left_cut_jj);
        leftCutButton.setOnClickListener(this);
        leftCutButton.setEnabled(false);
        rightCutButton = (ImageButton) findViewById(R.id.ib_right_cut_jj);
        rightCutButton.setOnClickListener(this);
        rightCutButton.setEnabled(false);
        previewButton  = (ImageButton) findViewById(R.id.ib_preview_jj);
        previewButton.setOnClickListener(this);
        previewButton.setTag(false);
        timeBoardView = (TimeBoardView) findViewById(R.id.tbv_time_board_jj);
        timeSeekBar = (SeekBar) findViewById(R.id.sb_video_controll_jj);
        timeSeekBar.setOnSeekBarChangeListener(seekBarChangeListener);
        promptView = (TextView) findViewById(R.id.tv_prompt_jj);
    }

    private void setOverflowShowingAlways() {
        try {
            ViewConfiguration config = ViewConfiguration.get(this);
            Field menuKeyField = ViewConfiguration.class.getDeclaredField("sHasPermanentMenuKey");
            menuKeyField.setAccessible(true);
            menuKeyField.setBoolean(config, false);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private SeekBar.OnSeekBarChangeListener seekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            if (b){
                int position = videoView.getCurrentPosition();
                if (Math.abs(position - i) > 400){
                    videoView.seekTo(i);
                }
            }
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {

        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {

        }
    };

    @Override
    public void onClick(View view) {
        switch (view.getId()){
            case R.id.ib_play_jj:
                boolean isPlaying = (Boolean) playButton.getTag();
                if (isPlaying){
                    playButtonToPlay(false);
                }else {
                    playButtonToPlay(true);
                }
                break;
            case R.id.ib_left_cut_jj:
                leftCurButtonClick();
                break;
            case R.id.ib_right_cut_jj:
                rightCutButtonClick();
                break;
            case R.id.ib_preview_jj:
                previewButtonClick();
                break;
            default:
                break;
        }
    }
    private Runnable onPlayPosition = new Runnable() {
        @Override
        public void run() {
            if (videoView.isPlaying()) {
                int position = videoView.getCurrentPosition();
                timeSeekBar.setProgress(position);
                timeBoardView.setTime(position);
                boolean isPreview = (Boolean) previewButton.getTag();
                if (isPreview){
                    float startValue = (position * 1.0f) / (videoDuration * 1.0f);
                    if (startValue >= clipView.getLeftValue()){
                        clipView.onPreview(startValue);
                    }
                    if (startValue >= clipView.getRightValue()){
                        stopPreview();
                    }
                }
                timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
            }
        }
    };

    private void previewButtonClick(){
        boolean isPreview = (Boolean) previewButton.getTag();
        if (isPreview){
            stopPreview();
        }else{
            startPreview();
        }
    }

    private void startPreview(){
        previewButton.setTag(true);
        int startPosition = (int) (videoDuration*1.0f * clipView.getLeftValue());
        Log.d(TAG,"videoDuration:"+videoDuration);
        Log.d(TAG,"getLeftValue:"+clipView.getLeftValue());
        Log.d(TAG,"startPosition:"+startPosition);
        videoView.seekTo(startPosition);
        playButtonToPlay(true);
    }

    private void stopPreview(){
        clipView.stopPreview();
        previewButton.setTag(false);
        playButtonToPlay(false);
    }

    private void playButtonToPlay(boolean toPlay){
        if (toPlay){
            playButton.setTag(true);
            leftCutButton.setEnabled(true);
            rightCutButton.setEnabled(true);
            playButton.setImageResource(R.drawable.pause);
            videoView.start();
            timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
        }else {
            playButton.setTag(false);
            leftCutButton.setEnabled(false);
            rightCutButton.setEnabled(false);
            playButton.setImageResource(R.drawable.play);
            videoView.pause();
        }
    }

    private void leftCurButtonClick(){
        if (videoView.isPlaying()){
            int leftPosition = videoView.getCurrentPosition();
            float leftValue = (leftPosition * 1.0f) / (videoDuration * 1.0f);
            clipView.setLeftValue(leftValue);
        }
    }

    private void rightCutButtonClick(){
        if (videoView.isPlaying()){
            int rightPosition = videoView.getCurrentPosition();
            float rightValue = (rightPosition * 1.0f) / (videoDuration * 1.0f);
            clipView.setRightValue(rightValue);
        }
    }

    private VideoClipView.OnValueChangedListener valueChangedListener = new VideoClipView.OnValueChangedListener() {
        @Override
        public void onLeftValueChanged(@FloatRange(from = 0.0, to = 1.0) float leftValue) {
            Log.d(TAG,"leftValue:" + leftValue);
            if (videoDuration == -1){
                videoDuration = videoView.getDuration();
            }
        }
        @Override
        public void onRightValueChanged(@FloatRange(from = 0.0, to = 1.0) float rightValue) {
            Log.d(TAG,"rightValue:" + rightValue);

        }
    };

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_jj,menu);
        MenuItem item = menu.findItem(R.id.menu_save_jj);
        SpannableString spannableString = new SpannableString(item.getTitle());
        spannableString.setSpan(new ForegroundColorSpan(Color.parseColor("#FFFFFF")), 0, spannableString.length(), 0);
        item.setTitle(spannableString);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId())
        {
            case android.R.id.home:
                finish();
                return true;
            case R.id.menu_add_jj:
                Log.d(TAG,"onOptionsItemSelected --> R.id.menu_add_jj");
                requestSDCardPermission();
                return true;
            case R.id.menu_save_jj:
                startClipVideo(false);
                return true;
            default:
                return super.onOptionsItemSelected(item);

        }
    }

    private void startClipVideo(final boolean audioRecode){
        if (videoPath == null){
            DialogPrompt.showText(getString(R.string.please_choose_video),JianJiActivity.this);
            return;
        }
        if (FFmpegUtil.getInstance().isFFmpegCommandRunning()){
            DialogPrompt.showText(getString(R.string.please_wait_),JianJiActivity.this);
            return;
        }
        ProgressHUD.show(JianJiActivity.this,getString(R.string.saving),null);


        final String filePath = FileUtil.getVideoResultPath(System.currentTimeMillis()+"",FileUtil.getSuffix(videoPath));
        if (videoDuration == -1){
            videoDuration = videoView.getDuration();
        }
        float startTime = clipView.getLeftValue() * videoDuration;
        float endTime = clipView.getRightValue() * videoDuration ;
        Log.d(TAG,"startTime" + startTime);
        Log.d(TAG,"duration" + (endTime - startTime));
        String[] complexCommand = Command.getInstance().clipVideo(videoPath,
                                                                  filePath,
                                                                   ""+startTime/1000,
                                                                   ""+(endTime - startTime)/1000,
                                                                   audioRecode);

        FFmpegUtil.getInstance().execFFmpegBinary(complexCommand, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {
                Log.d(TAG,"onNotSupport");
            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:" + s);
                if (audioRecode){
                    ProgressHUD.dismiss(0);
                    DialogPrompt.showText(getString(R.string.save_filed),JianJiActivity.this);
                }else {
                    startClipVideo(true);
                }

            }

            @Override
            public void onSuccess(String s) {
                Log.d(TAG,"onSuccess:" + s);
                ProgressHUD.dismiss(0);
                saveSuccess(filePath);
            }

            @Override
            public void onProgress(String s) {
                Log.d(TAG,"onProgress:" + s);
            }

            @Override
            public void onStart() {
                Log.d(TAG,"onStart");
            }

            @Override
            public void onFinish() {
                Log.d(TAG,"onFinish");
            }
        });


    }
    private void saveSuccess(String path){
        FileUtil.removeTmpFile();
        ProgressHUD.dismiss(0);
        Log.d(TAG,"resultPath:" + path);
        Intent play = new Intent(JianJiActivity.this,VideoPlayActivity.class);
        play.putExtra("VIDEO_URL",path);
        if (play.resolveActivity(getPackageManager()) != null){
            startActivity(play);
        }
    }
    @Override
    public void permissionSDCardAllow() {
        ChooseFileUtil.chooseFile(JianJiActivity.this, ChooseFileUtil.FileType.VIDEO,REQUEST_VIDEO_CODE_JJ);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_VIDEO_CODE_JJ&& resultCode == RESULT_OK && null != data) {
            Uri selectedVideo = data.getData();
            try {
                String path = FileUtil.getPath(JianJiActivity.this,selectedVideo);
                Log.d(TAG,"videoPath = " + path);
                File videoFile = new File(path);
                if (videoFile.exists()){
                    videoPath = path;
                    videoDuration = 0;
                    stopVideoPosition = 0;
                    promptView.setVisibility(View.GONE);
                    playVideo(videoFile);
                }else {
                    DialogPrompt.showText(getString(R.string.unable_to_load_the_file),JianJiActivity.this);
                }

            } catch (URISyntaxException e) {
                e.printStackTrace();
                DialogPrompt.showText(getString(R.string.unable_to_load_the_file),JianJiActivity.this);
            }
        }
    }

    private void playVideo(File videoFile) {
        if (videoView.getVisibility() == View.INVISIBLE){
            videoView.setVisibility(View.VISIBLE);
        }
        if (videoFile.exists()) {
            final String path = videoFile.getAbsolutePath();
            videoView.setVideoPath(path);
            videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    videoDuration = videoView.getDuration();
                    Log.d(TAG,"getDuration" + videoDuration);
                    timeSeekBar.setMax(videoView.getDuration());
                    timeSeekBar.postDelayed(onPlayPosition,DELAY_TIME);
                    if (stopVideoPosition > 0){
                        //视图生命周期处理
                        videoView.seekTo(stopVideoPosition);
                        playButtonToPlay(false);
                    }else {
                        playButton.setImageResource(R.drawable.pause);
                        playButton.setTag(true);
                        rightCutButton.setEnabled(true);
                        leftCutButton.setEnabled(true);
                        timeBoardView.setTime(0);
                    }
                }
            });
            videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    playButton.setTag(false);
                    rightCutButton.setEnabled(false);
                    leftCutButton.setEnabled(false);
                    playButton.setImageResource(R.drawable.play);
                    timeSeekBar.setProgress(0);
                    timeBoardView.setTime(videoDuration);
                    boolean isPreview = (Boolean) previewButton.getTag();
                    if (isPreview){
                        stopPreview();
                    }
                }
            });
            stopPreview();
            clipView.reset();
            clipView.setVideoFramesFFmpeg(path);
            videoView.start();

            videoView.requestFocus();
        }
    }
    private int stopVideoPosition = 0;
    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG,"onPause");
        stopVideoPosition = videoView.getCurrentPosition();
        Log.d(TAG,"stopVideoPosition="+stopVideoPosition);
        playButtonToPlay(false);
    }
    @Override
    protected void onRestart() {
        super.onRestart();
        Log.d(TAG,"onRestart");

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected ViewGroup getBannerViewContainer() {
        LinearLayout container = (LinearLayout) findViewById(R.id.banner_container_jj);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
