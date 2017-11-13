package com.liubowang.dubbing.HunYin;

import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
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
import com.liubowang.dubbing.PeiYin.PeiYinActivity;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.ChooseFileUtil;
import com.liubowang.dubbing.Util.Command;
import com.liubowang.dubbing.Util.DialogPrompt;
import com.liubowang.dubbing.Util.FFmpegUtil;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.Mp3Info;
import com.liubowang.dubbing.Util.ProgressHUD;
import com.liubowang.dubbing.Videos.VideoPlayActivity;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URISyntaxException;
import java.util.HashMap;

public class HunYinActivity extends DBBaseActiviry {

    private static final String TAG = HunYinActivity.class.getSimpleName();

    private static final String SILENT_VIDEO_PATH_KEY = "SILENT_VIDEO_PATH_KEY";
    private static final String VIDEO_AUDIO_PATH_KEY = "VIDEO_AUDIO_PATH_KEY";
    private static final String MUSIC_PATH_KEY = "MUSIC_PATH_KEY";
    private static final String VIDEO_AUDIO_SUB_1_PATH_KEY = "VIDEO_AUDIO_SUB_1_PATH_KEY";
    private static final String VIDEO_AUDIO_SUB_2_PATH_KEY = "VIDEO_AUDIO_SUB_2_PATH_KEY";
    private static final String AUDIO_MUSIC_MIX_PATH_KEY = "AUDIO_MUSIC_MIX_PATH_KEY";
    private static final String RESULT_PATH_KEY = "RESULT_PATH_KEY";

    private static final String AUDIO_CUT_START_TIME_1_KEY = "AUDIO_CUT_START_TIME_1_KEY";
    private static final String AUDIO_CUT_START_TIME_2_KEY = "AUDIO_CUT_START_TIME_2_KEY";
    private static final String AUDIO_CUT_DURATION_TIME_1_KEY = "AUDIO_CUT_DURATION_TIME_1_KEY";
    private static final String AUDIO_CUT_DURATION_TIME_2_KEY = "AUDIO_CUT_DURATION_TIME_2_KEY";
    private static final String MUSIC_CUT_START_TIME_KEY = "MUSIC_CUT_START_TIME_KEY";
    private static final String MUSIC_CUT_DURATION_TIME_KEY = "MUSIC_CUT_DURATION_TIME_KEY";

    private static final int MSG_CLIP_CUT_MUSIC = 135;
    private static final int MSG_CLIP_CHANGE_VIDEO_VOLUME = 208;
    private static final int MSG_CLIP_MIXING_MUSIC_AUDIO = 120;
    private static final int MSG_CLIP_MIXING_VIDEO_AM = 36;

    private static final int MSG_START_CUT_AUDIO_1 = 747;
    private static final int MSG_START_CUT_AUDIO_2 = 897;
    private static final int MSG_START_CUT_MUSIC = 833;
    private static final int MSG_START_MIXING_AUDIO_2_MUSIC = 835;
    private static final int MSG_START_APPEND_A_AM = 518;
    private static final int MSG_START_MIXING_VIDEO_AAM = 84;

    private static final int MSG_COMPLETE_RESULT = 519;

    private static final int DELAY_TIME = 80;
    private static final int REQUEST_VIDEO_CODE_HY = 683;
    private static final int REQUEST_MUSIC_CODE_HY = 298;
    private ImageButton playButton;
    private VideoView videoView;
    private String videoPath;
    private Mp3Info musicInfo;
    private TimeBoardView timeBoardView;
    private SeekBar timeSeekBar;
    private int videoDuration;
    private MusicPickerView musicPickerView;
    private TextSeekView videoVolumeSeek;
    private TextSeekView musicVolumeSeek;
    private Button previewButton;
    private Button saveButton;
    private MediaPlayer audioPlayer;
    private MediaPlayer musicPlayer;
    private HashMap<String,String> mediaPathMap = new HashMap<>();
    private HashMap<String,Integer> mediaTimeMap = new HashMap<>();
    private boolean videoCanPlay;
    private boolean audioCanPlay;
    private boolean isPickerMusic;
    private int musicClipTime = -1;
    private int musicStartTime = -1;
    private boolean musicHasPlayed = false;
    private boolean isPreview = false;
    private TextView promptView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hun_yin);
        initUI();
        setOverflowShowingAlways();
    }


    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_hy);
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_hy);
        setStatusBar(imageView);
        playButton = (ImageButton) findViewById(R.id.ib_play_hy);
        playButton.setOnClickListener(onButtonListener);
        playButton.setTag(false);
        videoView = (VideoView) findViewById(R.id.vv_video_view_hy);
        videoView.setZOrderOnTop(true);
        timeBoardView = (TimeBoardView) findViewById(R.id.tbv_time_board_hy);
        timeSeekBar = (SeekBar) findViewById(R.id.sb_video_controll_hy);
        timeSeekBar.setOnSeekBarChangeListener(seekBarChangeListener);
        musicPickerView = (MusicPickerView) findViewById(R.id.mpv_music_picker_hy);
        musicPickerView.setMusicTitle(getString(R.string.click_to_select_the_file));
        videoVolumeSeek = (TextSeekView) findViewById(R.id.tsv_video_volume_seek_hy);
        videoVolumeSeek.setOnTextSeekValueChangedListener(videoVolumeListener);
        musicVolumeSeek = (TextSeekView) findViewById(R.id.tsv_music_volume_seek_hy);
        musicVolumeSeek.setOnTextSeekValueChangedListener(musicVolumeListener);
        previewButton = (Button) findViewById(R.id.b_preview_hy);
        previewButton.setSoundEffectsEnabled(false);
        previewButton.setOnClickListener(onButtonListener);
        saveButton = (Button) findViewById(R.id.b_save_hy);
        saveButton.setSoundEffectsEnabled(false);
        saveButton.setOnClickListener(onButtonListener);
        promptView = (TextView) findViewById(R.id.tv_prompt_hy);
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
                    audioPlayer.seekTo(i);
                    if (musicPlayer != null){
                        if (musicStartTime >= 0 ){
                            musicPlayer.seekTo(i - musicStartTime);
                        }else {
                            musicPlayer.seekTo( i + musicClipTime);
                        }
                        musicPlayer.pause();
                        musicHasPlayed = false;
                    }
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

    private TextSeekView.OnTextSeekValueChangedListener videoVolumeListener = new TextSeekView.OnTextSeekValueChangedListener() {
        @Override
        public void onValueChange(TextSeekView textSeekView, int value, boolean b) {
            float volume = value / 100f;
            Log.d(TAG,"videoVolumeListener:" + value);
            if (audioPlayer != null){
                audioPlayer.setVolume(volume, volume);
            }
        }
    };

    private TextSeekView.OnTextSeekValueChangedListener musicVolumeListener = new TextSeekView.OnTextSeekValueChangedListener() {
        @Override
        public void onValueChange(TextSeekView textSeekView, int value, boolean b) {
            float volume = value / 100f;
            Log.d(TAG,"musicVolumeListener:" + value);
            if (musicPlayer != null){
                musicPlayer.setVolume(volume, volume);
            }
        }
    };

    /*
    * 视频播放进度监听
    * */
    private Runnable onPlayPosition = new Runnable() {
        @Override
        public void run() {
            if (videoView.isPlaying()) {
                int position = videoView.getCurrentPosition();
                timeSeekBar.setProgress(position);
                timeBoardView.setTime(position);
                timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
                if (isPreview){
                    musicPickerView.setPreviewValue(position);
                }
                if (musicPlayer != null
                        && !musicPlayer.isPlaying()
                        && musicStartTime >= 0
                        && position >= musicStartTime
                        && !musicHasPlayed
                        && isPreview){
                    musicPlayer.start();
                    musicHasPlayed = true;
                }
            }
        }
    };


    private View.OnClickListener onButtonListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()){
                case R.id.ib_play_hy:
                    boolean isPlaying = (Boolean) playButton.getTag();
                    if (isPlaying){
                        playButtonToPlay(false);
                    }else {
                        playButtonToPlay(true);
                    }
                    break;
                case R.id.b_preview_hy:
                    previewButtonClick();
                    break;
                case R.id.b_save_hy:
                    saveButtonClick();
                    break;
                default:
                    break;
            }
        }
    };

    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                //-------------CLIP STEP-----------
                case MSG_CLIP_CUT_MUSIC:
                    Log.d(TAG,"MSG_CLIP_CUT_MUSIC:");
                    clipCutMusic();
                    break;
                case MSG_CLIP_CHANGE_VIDEO_VOLUME:
                    Log.d(TAG,"MSG_CLIP_CHANGE_VIDEO_VOLUME:");
                    clipModifyTheVideoSoundVolume();
                    break;
                case MSG_CLIP_MIXING_MUSIC_AUDIO:
                    Log.d(TAG,"MSG_CLIP_MIXING_MUSIC_AUDIO:");
                    clipMixAudioAndMusic();
                    break;
                case MSG_CLIP_MIXING_VIDEO_AM:
                    Log.d(TAG,"MSG_CLIP_MIXING_VIDEO_A_M:");
                    clipMixVideoAnd_A_M();
                    break;
                //-------------START STEP-----------
                case MSG_START_CUT_AUDIO_1:
                    Log.d(TAG,"MSG_START_CUT_AUDIO_1:");
                    startCutAudio1();
                    break;
                case MSG_START_CUT_AUDIO_2:
                    Log.d(TAG,"MSG_START_CUT_AUDIO_2:");
                    startCutAudio2();
                    break;
                case MSG_START_CUT_MUSIC:
                    Log.d(TAG,"MSG_START_CUT_MUSIC:");
                    startCutMusic();
                    break;
                case MSG_START_MIXING_AUDIO_2_MUSIC:
                    Log.d(TAG,"MSG_START_MIXING_AUDIO_2_MUSIC:");
                    startMixAudio2AndMusic();
                    break;
                case MSG_START_APPEND_A_AM:
                    Log.d(TAG,"MSG_START_APPEND_A_AM:");
                    startAppendAudio1AndAM();
                    break;
                case MSG_START_MIXING_VIDEO_AAM:
                    Log.d(TAG,"MSG_START_MIXING_VIDEO_AAM:");
                    startMixVideoAnd_AAM();
                    break;
                //-------------COMPLETE RESULT-----------
                case MSG_COMPLETE_RESULT:
                    saveSuccess();
                    break;
                default:break;
            }
        }
    };

    private void saveSuccess(){
        FileUtil.removeTmpFile();
        ProgressHUD.dismiss(0);
        String resultPath = mediaPathMap.get(RESULT_PATH_KEY);
        Log.d(TAG,"resultPath:" + resultPath);
        Intent play = new Intent(HunYinActivity.this,VideoPlayActivity.class);
        play.putExtra("VIDEO_URL",resultPath);
        if (play.resolveActivity(getPackageManager()) != null){
            startActivity(play);
        }
    }


    private void addItemClick(){
        final FileAlertDialog dialog = new FileAlertDialog(HunYinActivity.this);
        dialog.show();
        dialog.setActionListener(new FileAlertDialog.OnActionListener() {
            @Override
            public void onVideoAction() {
                isPickerMusic = false;
                requestSDCardPermission();
                dialog.dismiss();
            }

            @Override
            public void onMusicAction() {
                isPickerMusic = true;
                requestSDCardPermission();
                dialog.dismiss();
            }
        });
    }

    private void saveButtonClick(){
        if (!videoAndMusicExist()){
            return;
        }
        prepareMusicStartOrClipTime();
        ProgressHUD.showProgressUpdate(this,getString(R.string.please_wait_),getString(R.string.processing));
        ProgressHUD.setProgressUpdate(8);
        beginChuLiYinPin();
    }

    private void previewButtonClick(){
        if (!videoAndMusicExist()){
            return;
        }
        stopVideoPosition = 0;
        prepareMusicStartOrClipTime();
        if (musicPlayer.isPlaying()){
            musicPlayer.pause();
        }

        musicHasPlayed = false;
        isPreview = true;
        videoView.seekTo(0);
        if (musicClipTime == -1){
            musicPlayer.seekTo(0);
        }else {
            musicPlayer.seekTo(musicClipTime);
        }
        audioPlayer.seekTo(0);
        audioPlayer.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {
            @Override
            public void onSeekComplete(MediaPlayer mediaPlayer) {
                if (stopVideoPosition <= 0 && isPreview){
                    playVideoAndAudio();
                    musicPickerView.setPreviewVisibility(true);
                    if (musicClipTime >= 0){
                        musicPlayer.start();
                    }
                }

            }
        });


    }

    /*
    * 播放或暂停视频
    * */
    private void playButtonToPlay(boolean toPlay){
        if (toPlay){
            playButton.setTag(true);
            playButton.setImageResource(R.drawable.pause);
            videoView.start();
            if (audioPlayer != null){
                audioPlayer.start();
            }
            timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
            int position = videoView.getCurrentPosition();
            if (musicPlayer != null
                    && isPreview
                    && position >= musicStartTime){
                musicPlayer.start();
                Log.d(TAG,"musicPlayer.start();");
            }
        }else {
            playButton.setTag(false);
            playButton.setImageResource(R.drawable.play);
            videoView.pause();
            if (audioPlayer != null){
                audioPlayer.pause();
            }
            if (musicPlayer != null && isPreview){
                musicPlayer.pause();
            }
        }
    }

    /*
    * 播放视频
    * */
    private void playVideoAndAudio() {
        if (audioCanPlay && videoCanPlay){
            ProgressHUD.dismiss(0);
//            videoView.start();
//            audioPlayer.start();
            playButtonToPlay(true);
        }
    }

    /*
    * 停止播放音乐
    * */
    private void stopMusicPlayer(){
        try {
            if (musicPlayer != null) {
                musicPlayer.stop();
                musicPlayer.release();
                musicPlayer=null;
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    /*
    * 音乐文件播放的准备工作
    * */
    private void prepareMusic(){
        String musicPath = musicInfo.getUrl();
        stopMusicPlayer();
        musicPlayer = new MediaPlayer();
        try {
            musicPlayer.setDataSource(musicPath);
            musicPlayer.setLooping(false);
            musicPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    mediaPlayer.setVolume(0.5f, 0.5f);
                    musicVolumeSeek.setProgress(50);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            musicPickerView.relayout(videoDuration,(int) musicInfo.getDuration());
                            String musicTitle = musicInfo.getName() + "  (" + getString(R.string.drag_to_change_the_position) +")";
                            musicPickerView.setMusicTitle(musicTitle);
                        }
                    });
                }
            });
            musicPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
            musicInfo = null;
            ProgressHUD.show(HunYinActivity.this,getString(R.string.unable_to_load_the_file),null);
            ProgressHUD.dismiss(1500);
        }
    }

    /*
    * 判断视频和音乐文件是否都存在
    * */
    private boolean videoAndMusicExist(){
        if (videoPath == null){
            DialogPrompt.showText(getString(R.string.please_choose_video),this);
            return false;
        }
        if (musicInfo == null){
            DialogPrompt.showText(getString(R.string.please_choose_music),this);
            return false;
        }
        return true;
    }

    /*
    * 计算音乐文件的开始或加剪切时间
    * */
    private void prepareMusicStartOrClipTime(){
        if (musicPickerView.isCanClipMusic()){
            float clipValue = musicPickerView.getClipValue();
            musicClipTime =(int) (musicInfo.getDuration() * clipValue);
            musicStartTime = -1;
        }else {
            float startValue = musicPickerView.getStartValue();
            musicStartTime =(int) (videoDuration * startValue);
            musicClipTime = -1;
        }
        Log.d(TAG,"musicStartTime:"+ musicStartTime);
        Log.d(TAG,"musicClipTime:"+ musicClipTime);
    }

    /*
    * 提取无声视频
    * */
    private void extractVideo() {

        ProgressHUD.show(HunYinActivity.this,
                getString(R.string.please_wait_),
                getString(R.string.processing_in_progress));


        final String filePath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(videoPath));
        String[] commands = Command.getInstance().extractVideo(videoPath, filePath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                mediaPathMap.put(SILENT_VIDEO_PATH_KEY,filePath);
                extractAudio(null);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {
                videoView.seekTo(0);
                videoView.stopPlayback();
            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 提取视频的音频文件
    * */
    private void extractAudio(final String  audioType) {

        final String filePath = FileUtil.getCurrentTimeMillisPath("aac");
        String[] commands = null;
        if (audioType == null){
            commands = Command.getInstance().extractAudio(videoPath,filePath);
        }else {
            commands = Command.getInstance().extractAudio(videoPath,filePath,"aac");
        }
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                Log.d(TAG,"videoAudioSuccess:");
                Log.d(TAG,"Thread:"+Thread.currentThread().getName());
                mediaPathMap.put(VIDEO_AUDIO_PATH_KEY,filePath);
                String path = mediaPathMap.get(SILENT_VIDEO_PATH_KEY);
                if (videoView.getVisibility() == View.INVISIBLE){
                    videoView.setVisibility(View.VISIBLE);
                }
                videoView.setVideoPath(path);
                videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mediaPlayer) {
                        if (stopVideoPosition > 0){
                            //视图生命周期处理
                            videoView.seekTo(stopVideoPosition);
                            if (isPreview){
                                audioPlayer.seekTo(stopVideoPosition);
                                musicPlayer.seekTo(stopVideoPosition);
                                musicPickerView.setPreviewValue(stopVideoPosition);
                            }
                        }else {
                            videoDuration = videoView.getDuration();
                            int musicDuration = -1;
                            if (musicInfo != null){
                                musicDuration = (int) musicInfo.getDuration();
                            }
                            musicPickerView.relayout(videoDuration,musicDuration);
                            Log.d(TAG,"getDuration" + videoDuration);
                            timeSeekBar.setMax(videoView.getDuration());
                            timeSeekBar.postDelayed(onPlayPosition,DELAY_TIME);
                            playButton.setImageResource(R.drawable.pause);
                            playButton.setTag(true);
                            timeBoardView.setTime(0);
                            videoCanPlay = true;
                            playVideoAndAudio();
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
                        audioPlayer.pause();
                        audioPlayer.seekTo(0);
                        musicPickerView.setPreviewVisibility(false);
                        if (musicPlayer != null && musicPlayer.isPlaying()){
                            musicPlayer.pause();
                            isPreview = false;
                            Log.d(TAG,"isPreview = false;");
                        }
                    }
                });
                videoView.requestFocus();
                try {
                    audioPlayer.setDataSource(mediaPathMap.get(VIDEO_AUDIO_PATH_KEY));
                    audioPlayer.setLooping(false);
                    audioPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                        @Override
                        public void onPrepared(MediaPlayer mediaPlayer) {
                            audioPlayer.setVolume(0.5f, 0.5f);
                            videoVolumeSeek.setProgress(50);
                            audioCanPlay = true;
                            playVideoAndAudio();
                        }
                    });
                    audioPlayer.prepare();

                } catch (IOException e) {
                    if (audioType == null){
                        extractAudio("aac");
                    }else {
                        ProgressHUD.dismiss(0);
                        DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
                    }
                    e.printStackTrace();

                }
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {
                if (audioPlayer != null) {
                    audioPlayer.stop();
                    audioPlayer.release();
                    audioPlayer = null;
                }
                audioPlayer = new MediaPlayer();
            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 开始处理音频
    * */
    private void beginChuLiYinPin(){
        int cutStartTime = 0;
        int musicDuration = (int) musicInfo.getDuration();
        int cutDuration = musicDuration - cutStartTime;
        if (musicClipTime > 0){
            cutStartTime = musicClipTime;
            if ((cutStartTime + videoDuration) < musicDuration){
                cutDuration = videoDuration;
            }else {
                cutDuration = musicDuration - cutStartTime;
            }
            mediaTimeMap.put(MUSIC_CUT_START_TIME_KEY,cutStartTime);
            mediaTimeMap.put(MUSIC_CUT_DURATION_TIME_KEY,cutDuration);
            handler.sendEmptyMessage(MSG_CLIP_CUT_MUSIC);
        }else {
            if (musicStartTime < 300){//音频开始时间小于0.3 s 进行上面的简单操作
                mediaTimeMap.put(MUSIC_CUT_START_TIME_KEY,0);
                mediaTimeMap.put(MUSIC_CUT_DURATION_TIME_KEY,videoDuration);
                handler.sendEmptyMessage(MSG_CLIP_CUT_MUSIC);
            }else {

                int cut1 = 0;
                int duration1 = musicStartTime;
                mediaTimeMap.put(AUDIO_CUT_START_TIME_1_KEY,cut1);
                mediaTimeMap.put(AUDIO_CUT_DURATION_TIME_1_KEY,duration1);

                int cut2 = musicStartTime;
                int duration2 = videoDuration - musicStartTime;
                mediaTimeMap.put(AUDIO_CUT_START_TIME_2_KEY,cut2);
                mediaTimeMap.put(AUDIO_CUT_DURATION_TIME_2_KEY,duration2);

                int mCut = 0;
                int mDuration = musicDuration;
                if ((videoDuration - musicStartTime) < musicDuration ){
                    mDuration = videoDuration - musicStartTime;
                }

                mediaTimeMap.put(MUSIC_CUT_START_TIME_KEY,0);
                mediaTimeMap.put(MUSIC_CUT_DURATION_TIME_KEY,mDuration);

                handler.sendEmptyMessage(MSG_START_CUT_AUDIO_1);
            }
        }
    }

//**************************************************************************************************
//                                        CLIP STEP                                               *
//**************************************************************************************************
    /*
    * 1.剪切音乐并修改音量
    * */
    private void clipCutMusic(){
        String oldMusicPath = musicInfo.getUrl();
        final String newMusicPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(oldMusicPath));
        int beginTime = mediaTimeMap.get(MUSIC_CUT_START_TIME_KEY);
        int d = mediaTimeMap.get(MUSIC_CUT_DURATION_TIME_KEY);
        float vol = musicVolumeSeek.getProgress() / 100f;
        String[] commands = Command.getInstance().cutYinPin(oldMusicPath,beginTime,d,vol,newMusicPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                mediaPathMap.put(MUSIC_PATH_KEY,newMusicPath);
                Log.d(TAG,"onSuccess:"+s);
                ProgressHUD.setProgressUpdate(25);
                handler.sendEmptyMessage(MSG_CLIP_CHANGE_VIDEO_VOLUME);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }
    /*
    * 2.修改视频声音音量
    * */
    private void clipModifyTheVideoSoundVolume(){
        String oldAudioPath = mediaPathMap.get(VIDEO_AUDIO_PATH_KEY);
        final String newAudioPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(oldAudioPath));
        float volume = videoVolumeSeek.getProgress() / 100f;
        String[] commands = Command.getInstance().changeYinPinVolume(oldAudioPath,volume,newAudioPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:" + s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(50);
                mediaPathMap.put(VIDEO_AUDIO_PATH_KEY,newAudioPath);
                handler.sendEmptyMessage(MSG_CLIP_MIXING_MUSIC_AUDIO);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 3.混合视频声音和音乐声音
    * */
    private void clipMixAudioAndMusic(){

        final String audioMusicPath = FileUtil.getCurrentTimeMillisPath("aac");
        String audioPath = mediaPathMap.get(VIDEO_AUDIO_PATH_KEY);
        String musicPath = mediaPathMap.get(MUSIC_PATH_KEY);
        String[] commands = Command.getInstance().mixYinPin(audioPath,musicPath,audioMusicPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(75);
                mediaPathMap.put(AUDIO_MUSIC_MIX_PATH_KEY,audioMusicPath);
                handler.sendEmptyMessage(MSG_CLIP_MIXING_VIDEO_AM);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }
    /*
    * 4.混合视频和混合后声音
    * */
    private void clipMixVideoAnd_A_M(){
        String videoPath = mediaPathMap.get(SILENT_VIDEO_PATH_KEY);
        String musicPath = mediaPathMap.get(AUDIO_MUSIC_MIX_PATH_KEY);
        final String result = FileUtil.getVideoResultPath(System.currentTimeMillis()+"",FileUtil.getSuffix(videoPath));
        int duration = videoDuration;
        String[] commands = Command.getInstance().addVideoBGMusic(videoPath,musicPath,result,duration);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(100);
                mediaPathMap.put(RESULT_PATH_KEY,result);
                handler.sendEmptyMessage(MSG_COMPLETE_RESULT);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });

    }

//**************************************************************************************************

//**************************************************************************************************
//                                        START STEP                                               *
//**************************************************************************************************

    /*
    * 1.分割视频原声1 并修改音量
    * */
    private void startCutAudio1(){

        String oldAudioPath = mediaPathMap.get(VIDEO_AUDIO_PATH_KEY);
        final String outPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(oldAudioPath));
        float volume = videoVolumeSeek.getProgress() / 100f;
        int startTime = mediaTimeMap.get(AUDIO_CUT_START_TIME_1_KEY);
        int duration = mediaTimeMap.get(AUDIO_CUT_DURATION_TIME_1_KEY);
        String[] commands = Command.getInstance().cutYinPin(oldAudioPath,startTime,duration,volume,outPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(20);
                mediaPathMap.put(VIDEO_AUDIO_SUB_1_PATH_KEY,outPath);
                handler.sendEmptyMessage(MSG_START_CUT_AUDIO_2);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 2.分割视频原声2 并修改音量
    * */
    private void startCutAudio2(){

        String oldAudioPath = mediaPathMap.get(VIDEO_AUDIO_PATH_KEY);
        final String outPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(oldAudioPath));
        float volume = videoVolumeSeek.getProgress() / 100f;
        int startTime = mediaTimeMap.get(AUDIO_CUT_START_TIME_2_KEY);
        int duration = mediaTimeMap.get(AUDIO_CUT_DURATION_TIME_2_KEY);
        String[] commands = Command.getInstance().cutYinPin(oldAudioPath,startTime,duration,volume,outPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(36);
                mediaPathMap.put(VIDEO_AUDIO_SUB_2_PATH_KEY,outPath);
                handler.sendEmptyMessage(MSG_START_CUT_MUSIC);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 3.剪切音乐并修改音量
    * */
    private void startCutMusic(){

        String oldMusicPath = musicInfo.getUrl();
        final String newMusicPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(oldMusicPath));
        int beginTime = mediaTimeMap.get(MUSIC_CUT_START_TIME_KEY);
        int d = mediaTimeMap.get(MUSIC_CUT_DURATION_TIME_KEY);
        float vol = musicVolumeSeek.getProgress() / 100f;
        String[] commands = Command.getInstance().cutYinPin(oldMusicPath,beginTime,d,vol,newMusicPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(52);
                mediaPathMap.put(MUSIC_PATH_KEY,newMusicPath);
                handler.sendEmptyMessage(MSG_START_MIXING_AUDIO_2_MUSIC);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 4.混合视频声音第二段和音乐声音
    * */
    private void startMixAudio2AndMusic(){

        final String audioMusicPath = FileUtil.getCurrentTimeMillisPath("aac");
        String audioPath = mediaPathMap.get(VIDEO_AUDIO_SUB_2_PATH_KEY);
        String musicPath = mediaPathMap.get(MUSIC_PATH_KEY);
        String[] commands = Command.getInstance().mixYinPin(audioPath,musicPath,audioMusicPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(68);
                mediaPathMap.put(AUDIO_MUSIC_MIX_PATH_KEY,audioMusicPath);
                handler.sendEmptyMessage(MSG_START_APPEND_A_AM);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });
    }

    /*
    * 5.拼接视频第一段和第四部混合的声音
    * */
    private void startAppendAudio1AndAM(){

        String firstPath = mediaPathMap.get(VIDEO_AUDIO_SUB_1_PATH_KEY);
        String secondPath = mediaPathMap.get(AUDIO_MUSIC_MIX_PATH_KEY);
        final String outPath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(firstPath));
        String[] commands = Command.getInstance().appYinPin(firstPath,secondPath,outPath);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(84);
                mediaPathMap.put(AUDIO_MUSIC_MIX_PATH_KEY,outPath);
                handler.sendEmptyMessage(MSG_START_MIXING_VIDEO_AAM);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });

    }

    /*
    * 6.混合视频和混合后声音
    * */
    private void startMixVideoAnd_AAM(){

        String videoPath = mediaPathMap.get(SILENT_VIDEO_PATH_KEY);
        final String result = FileUtil.getVideoResultPath(System.currentTimeMillis()+"",FileUtil.getSuffix(videoPath));
        String musicPath = mediaPathMap.get(AUDIO_MUSIC_MIX_PATH_KEY);
        int duration = videoDuration;
        String[] commands = Command.getInstance().addVideoBGMusic(videoPath,musicPath,result,duration);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),HunYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.setProgressUpdate(100);
                mediaPathMap.put(RESULT_PATH_KEY,result);
                handler.sendEmptyMessage(MSG_COMPLETE_RESULT);
            }

            @Override
            public void onProgress(String s) {

            }

            @Override
            public void onStart() {

            }

            @Override
            public void onFinish() {

            }
        });

    }


//**************************************************************************************************

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_hy,menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
            case R.id.menu_add_hy:
                addItemClick();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    /*
    * 权限允许进行文件选择
    * */
    @Override
    public void permissionSDCardAllow() {
        if (isPickerMusic){
//            ChooseFileUtil.chooseFile(HunYinActivity.this, ChooseFileUtil.FileType.AUDIO,REQUEST_MUSIC_CODE_HY);
            Intent musicIntent = new Intent(HunYinActivity.this,MusicActivity.class);
            if (musicIntent.resolveActivity(getPackageManager()) != null){
                startActivityForResult(musicIntent,REQUEST_MUSIC_CODE_HY);
            }
        }else {
            ChooseFileUtil.chooseFile(HunYinActivity.this, ChooseFileUtil.FileType.VIDEO,REQUEST_VIDEO_CODE_HY);
        }
    }

    /*
    * 文件选择回调
    * */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_VIDEO_CODE_HY&& resultCode == RESULT_OK && null != data) {
            Uri selectedVideo = data.getData();
            try {
                String path = FileUtil.getPath(HunYinActivity.this,selectedVideo);
                Log.d(TAG,"videoPath = " + path);
                File videoFile = new File(path);
                if (videoFile.exists()){
                    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
                    mmr.setDataSource(path);
                    long videoLength = Long.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                    if (videoLength >  (60 * 1000)){
                        DialogPrompt.showText(getString(R.string.video_time_too_long),HunYinActivity.this);
                    }else {
                        videoPath = path;
                        audioCanPlay = false;
                        videoCanPlay = false;
                        videoDuration = 0;
                        musicStartTime = 0;
                        musicClipTime = -1;
                        isPreview = false;
                        stopVideoPosition = 0;
                        promptView.setVisibility(View.GONE);
                        if (musicPlayer != null && musicPlayer.isPlaying()){
                            musicPlayer.pause();
                        }
                        musicPickerView.setPreviewVisibility(false);
                        extractVideo();
                    }
                }else {
                    DialogPrompt.showText(getString(R.string.unable_to_load_the_file),HunYinActivity.this);
                }

            } catch (URISyntaxException e) {
                e.printStackTrace();
                DialogPrompt.showText(getString(R.string.unable_to_load_the_file),HunYinActivity.this);
            }
        }
        else if (requestCode == REQUEST_MUSIC_CODE_HY && null != data){
            Mp3Info music = data.getParcelableExtra("MUSIC_INFO");
            File musicFile = new File(music.getUrl());
            if (musicFile.exists()){
                music.setName(musicFile.getName());
                musicInfo = music;
                Log.d(TAG,music.toString());
                musicStartTime = 0;
                musicClipTime = -1;
                isPreview = false;
                promptView.setVisibility(View.GONE);
                musicPickerView.setPreviewVisibility(false);
                prepareMusic();
            }else {
                DialogPrompt.showText(getString(R.string.unable_to_load_the_file),HunYinActivity.this);
            }
        }
    }
    private int stopVideoPosition = 0;
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");
        stopVideoPosition = videoView.getCurrentPosition();
        Log.d(TAG, "stopVideoPosition=" + stopVideoPosition);
        playButtonToPlay(false);
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
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
        LinearLayout container = (LinearLayout) findViewById(R.id.banner_container_hy);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
