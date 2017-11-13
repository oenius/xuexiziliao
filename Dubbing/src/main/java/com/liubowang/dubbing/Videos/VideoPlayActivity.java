package com.liubowang.dubbing.Videos;

import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.VideoView;

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.JianJi.TimeBoardView;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.DialogPrompt;

import java.io.File;
import java.lang.reflect.Field;

public class VideoPlayActivity extends DBBaseActiviry {
    private static final String TAG = VideoPlayActivity.class.getSimpleName();
    private static final int DELAY_TIME = 100;
    private ImageButton playButton;
    private VideoView videoView;
    private TimeBoardView timeBoardView;
    private SeekBar timeSeekBar;
    private String videoUrl = null;
    private Toolbar myToolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_play);
        initUI();
        setOverflowShowingAlways();

        Intent intent = getIntent();
        if (intent.hasExtra("VIDEO_URL")){
            videoUrl = intent.getStringExtra("VIDEO_URL");
        }
        if (videoUrl != null){
            File file = new File(videoUrl);
            if (file.exists()){
                playVideo(videoUrl);
                myToolbar.setTitle(file.getName());
            }
        }else {
            DialogPrompt.showText(getString(R.string.video_can_not_be_played),this);
        }
    }


    private void initUI() {
        myToolbar = (Toolbar) findViewById(R.id.tb_play);
        myToolbar.setTitle("");
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_play);
        setStatusBar(imageView);
        playButton = (ImageButton) findViewById(R.id.ib_play_play);
        playButton.setOnClickListener(onButtonListener);
        playButton.setTag(false);
        videoView = (VideoView) findViewById(R.id.vv_video_view_play);
        videoView.setZOrderOnTop(true);
        timeBoardView = (TimeBoardView) findViewById(R.id.tbv_time_board_play);
        timeSeekBar = (SeekBar) findViewById(R.id.sb_video_controll_play);
        timeSeekBar.setOnSeekBarChangeListener(seekBarChangeListener);
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
            if (b) {
                int position = videoView.getCurrentPosition();
                if (Math.abs(position - i) > 400) {
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
            switch (view.getId()) {
                case R.id.ib_play_play:
                    playButtonClick();
                    break;
                default:
                    break;
            }
        }
    };

    private void playButtonClick(){
        boolean isPlaying = (Boolean) playButton.getTag();
        if (isPlaying) {
            playButtonToPlay(false);
        } else {
            playButtonToPlay(true);
        }
    }


    private void playButtonToPlay(boolean toPlay) {
        if (toPlay) {
            playButton.setTag(true);
            playButton.setImageResource(R.drawable.pause);
            videoView.start();
            timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
        } else {
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

    private void playVideo(String path) {
        if (videoView.getVisibility() == View.INVISIBLE) {
            videoView.setVisibility(View.VISIBLE);
        }
        videoView.setVideoPath(path);
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                timeSeekBar.setMax(videoView.getDuration());
                timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);

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
                timeBoardView.setTime(videoView.getDuration());

            }
        });
        videoView.start();
        videoView.requestFocus();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
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
    protected ViewGroup getBannerViewContainer() {
        LinearLayout container = (LinearLayout) findViewById(R.id.banner_container_play);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}

