package com.liubowang.dubbing.XiaoYin;

import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.VideoView;

import com.jaeger.library.StatusBarUtil;
import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.JianJi.TimeBoardView;
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

public class XiaoYinActivity extends DBBaseActiviry {

    private static final String TAG = XiaoYinActivity.class.getSimpleName();
    private static final int DELAY_TIME = 100;
    private static final int REQUEST_VIDEO_CODE_XY = 434;
    private Button startButton;
    private ImageButton playButton;
    private VideoView videoView;
    private String videoPath;
    private TimeBoardView timeBoardView;
    private SeekBar timeSeekBar;
    private int videoDuration;
    private TextView promptView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_xiao_yin);
        initUI();
        setOverflowShowingAlways();
    }



    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_xy);
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_xy);
        setStatusBar(imageView);
        startButton = (Button) findViewById(R.id.b_start_button_xy);
        startButton.setSoundEffectsEnabled(false);
        startButton.setOnClickListener(onButtonListener);
        playButton = (ImageButton) findViewById(R.id.ib_play_xy);
        playButton.setOnClickListener(onButtonListener);
        playButton.setTag(false);
        videoView = (VideoView) findViewById(R.id.vv_video_view_xy);
        videoView.setZOrderOnTop(true);
        timeBoardView = (TimeBoardView) findViewById(R.id.tbv_time_board_xy);
        timeSeekBar = (SeekBar) findViewById(R.id.sb_video_controll_xy);
        timeSeekBar.setOnSeekBarChangeListener(seekBarChangeListener);
        promptView = (TextView) findViewById(R.id.tv_prompt_xy);
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

    private View.OnClickListener onButtonListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()){
                case R.id.b_start_button_xy:
                    startXiaoYin();
                    break;
                case R.id.ib_play_xy:
                    boolean isPlaying = (Boolean) playButton.getTag();
                    if (isPlaying){
                        playButtonToPlay(false);
                    }else {
                        playButtonToPlay(true);
                    }
                    break;
                default:
                    break;
            }
        }
    };

    private void playButtonToPlay(boolean toPlay){
        if (toPlay){
            playButton.setTag(true);
            playButton.setImageResource(R.drawable.pause);
            videoView.start();
            timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
        }else {
            playButton.setTag(false);
            playButton.setImageResource(R.drawable.play);
            videoView.pause();
        }
    }

    private Runnable onPlayPosition = new Runnable() {
        @Override
        public void run() {
            if (videoView.isPlaying()) {
                int position = videoView.getCurrentPosition();
                timeSeekBar.setProgress(position);
                timeBoardView.setTime(position);
                timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
            }
        }
    };

    private void startXiaoYin(){
        if (videoPath == null){
            DialogPrompt.showText(getString(R.string.please_choose_video),XiaoYinActivity.this);
            return;
        }
        ProgressHUD.show(XiaoYinActivity.this,getString(R.string.processing),null);
        final String filePath = FileUtil.getVideoResultPath(System.currentTimeMillis()+"",FileUtil.getSuffix(videoPath));
        String[] complexCommand = Command.getInstance().extractVideo(videoPath,filePath);
        FFmpegUtil.getInstance().execFFmpegBinary(complexCommand, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {
                Log.d(TAG,"onNotSupport");
            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:" + s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),XiaoYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                Log.d(TAG,"onSuccess:" + s);
                Log.d(TAG,""+Thread.currentThread().getName());
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
        Intent play = new Intent(XiaoYinActivity.this,VideoPlayActivity.class);
        play.putExtra("VIDEO_URL",path);
        if (play.resolveActivity(getPackageManager()) != null){
            startActivity(play);
        }
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_xy,menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
            case R.id.menu_add_xy:
                requestSDCardPermission();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void permissionSDCardAllow() {
        ChooseFileUtil.chooseFile(XiaoYinActivity.this, ChooseFileUtil.FileType.VIDEO,REQUEST_VIDEO_CODE_XY);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.d(TAG,"onActivityResult");
        if (requestCode == REQUEST_VIDEO_CODE_XY&& resultCode == RESULT_OK && null != data) {
            Uri selectedVideo = data.getData();
            try {
                String path = FileUtil.getPath(XiaoYinActivity.this,selectedVideo);
                Log.d(TAG,"videoPath = " + path);
                File videoFile = new File(path);
                if (videoFile.exists()){
                    videoPath = path;
                    videoDuration = 0;
                    stopVideoPosition = 0;
                    promptView.setVisibility(View.GONE);
                    playVideo(videoFile);
                }else {
                    DialogPrompt.showText(getString(R.string.unable_to_load_the_file),XiaoYinActivity.this);
                }
            } catch (URISyntaxException e) {
                e.printStackTrace();
                DialogPrompt.showText(getString(R.string.unable_to_load_the_file),XiaoYinActivity.this);
            }
        }
    }

    private void playVideo(final File videoFile) {
        if (videoView.getVisibility() == View.INVISIBLE){
            videoView.setVisibility(View.VISIBLE);
        }
        if (videoFile.exists()) {
            final String path = videoFile.getAbsolutePath();
            videoView.setVideoPath(path);
            videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
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
                        timeBoardView.setTime(0);
                    }
                }
            });
            videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    playButton.setTag(false);
                    playButton.setImageResource(R.drawable.play);
                    timeSeekBar.setProgress(0);
                    timeBoardView.setTime(videoDuration);

                }
            });
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
        LinearLayout container = (LinearLayout) findViewById(R.id.banner_container_xy);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
