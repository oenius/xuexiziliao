package com.liubowang.dubbing.PeiYin;

import android.content.Intent;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
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

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.JianJi.TimeBoardView;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Record.AudioFileUtils;
import com.liubowang.dubbing.Record.AudioRecorder;
import com.liubowang.dubbing.Util.ChooseFileUtil;
import com.liubowang.dubbing.Util.Command;
import com.liubowang.dubbing.Util.DialogPrompt;
import com.liubowang.dubbing.Util.FFmpegUtil;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.ProgressHUD;
import com.liubowang.dubbing.Videos.VideoPlayActivity;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URISyntaxException;

public class PeiYinActivity extends DBBaseActiviry {

    enum RecordStatus{
        AUDIO_RECORDING,AUDIO_PAUSE,AUDIO_STOP
    }

    private static final String TAG = PeiYinActivity.class.getSimpleName();
    private static final int DELAY_TIME = 80;
    private static final int REQUEST_VIDEO_CODE_PY = 434;
    private Button pauseButton;
    private ImageButton playButton;
    private VideoView videoView;
    private String videoPath;
    private TimeBoardView timeBoardView;
    private SeekBar timeSeekBar;
    private int videoDuration;
    private RecordView recordView;
    private RecordStatus status = RecordStatus.AUDIO_STOP;
    private AudioRecorder audioRecorder = AudioRecorder.getInstance();
    private String recordPath;
    private MediaPlayer audioPlayer = new MediaPlayer();
    private Button previewButton;
    private boolean isFirstPreview;
    private TextView promptView ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pei_yin);
        initUI();
        setOverflowShowingAlways();
    }


    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_py);
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_py);
        setStatusBar(imageView);
        pauseButton = (Button) findViewById(R.id.b_pause_button_py);
        pauseButton.setSoundEffectsEnabled(false);
        pauseButton.setOnClickListener(onButtonListener);
        pauseButton.setEnabled(false);
        playButton = (ImageButton) findViewById(R.id.ib_play_py);
        playButton.setOnClickListener(onButtonListener);
        playButton.setTag(false);
        videoView = (VideoView) findViewById(R.id.vv_video_view_py);
        videoView.setZOrderOnTop(true);
        timeBoardView = (TimeBoardView) findViewById(R.id.tbv_time_board_py);
        timeSeekBar = (SeekBar) findViewById(R.id.sb_video_controll_py);
        timeSeekBar.setOnSeekBarChangeListener(seekBarChangeListener);
        recordView = (RecordView) findViewById(R.id.rv_record_view_py);
        recordView.setOnClickListener(onButtonListener);
        previewButton = (Button) findViewById(R.id.b_preview_button_py);
        previewButton.setSoundEffectsEnabled(false);
        previewButton.setOnClickListener(onButtonListener);
        previewButton.setEnabled(false);
        promptView = (TextView) findViewById(R.id.tv_prompt_py);
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
                    if (i <= audioPlayer.getDuration()){
                        audioPlayer.seekTo(i);
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

    private View.OnClickListener onButtonListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()){
                case R.id.b_pause_button_py:
                    recordPauseClick();
                    break;
                case R.id.ib_play_py:
                    if (status == RecordStatus.AUDIO_STOP){
                        boolean isPlaying = (Boolean) playButton.getTag();
                        if (isPlaying){
                            playButtonToPlay(false);
                        }else {
                            playButtonToPlay(true);
                        }
                    }
                    break;
                case R.id.rv_record_view_py:
                    recordViewClick();
                    break;
                case R.id.b_preview_button_py:
                    previewButtonClick();
                    break;
                default:
                    break;
            }
        }
    };

    private void previewButtonClick(){
        int position = videoView.getCurrentPosition();
        if (position > 200 ){
            videoView.seekTo(0);
        }
        stopVideoPosition = 0;
        if (isFirstPreview){
            try {
                audioPlayer.setDataSource(recordPath);
                audioPlayer.setLooping(false);
                audioPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mediaPlayer) {
                        audioPlayer.setVolume(1.0f, 1.0f);
                        if (stopVideoPosition <= 0){
                            playButtonToPlay(true);
                        }

                    }
                });
                audioPlayer.prepare();
                isFirstPreview = false;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }else {
            audioPlayer.seekTo(0);
            audioPlayer.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {
                @Override
                public void onSeekComplete(MediaPlayer mediaPlayer) {
                    if (stopVideoPosition <= 0){
                        playButtonToPlay(true);
                    }
                }
            });
        }

    }

    private void playButtonToPlay(boolean toPlay){
        int position = videoView.getCurrentPosition();
        if (toPlay){
            playButton.setTag(true);
            playButton.setImageResource(R.drawable.pause);
            videoView.start();
            if (status == RecordStatus.AUDIO_STOP && position < audioPlayer.getDuration()){
                audioPlayer.start();
            }
            timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
        }else {
            playButton.setTag(false);
            playButton.setImageResource(R.drawable.play);
            if (status == RecordStatus.AUDIO_STOP){
                audioPlayer.pause();
            }
            videoView.pause();
        }
    }

    private void recordPauseClick(){
        if (status == RecordStatus.AUDIO_RECORDING) {
            status = RecordStatus.AUDIO_PAUSE;
            audioRecorder.pauseRecord();
            pauseButton.setText(getString(R.string.continue_dubbing));
            playButtonToPlay(false);
        } else if (status == RecordStatus.AUDIO_PAUSE) {
            status = RecordStatus.AUDIO_RECORDING;
            audioRecorder.startRecord(null);
            pauseButton.setText(getString(R.string.pause_dubbing));
            playButtonToPlay(true);
        }
    }

    private void recordViewClick(){
        if (status == RecordStatus.AUDIO_STOP){
            requestRecordPermission();
        }else {
            stopRecord(false);
        }
    }

    private void stopRecord(boolean autoEnd){
        status = RecordStatus.AUDIO_STOP;
        timeSeekBar.setEnabled(true);
        audioRecorder.stopRecord();
        recordView.setText(getString(R.string.re_dubbing));
        pauseButton.setEnabled(false);
        pauseButton.setText(getString(R.string.pause_dubbing));
        previewButton.setEnabled(true);
        recordView.setPlayProgress(0f);
        playButtonToPlay(false);
        timeSeekBar.setProgress(0);
        timeBoardView.setTime(videoDuration);
        if (autoEnd){
            recordView.setRecordProgress(1.0f);
        }
        isFirstPreview = true;
    }

    private void startRecord(){
        if (videoPath == null){
            DialogPrompt.showText(getString(R.string.please_choose_video),PeiYinActivity.this);
            return;
        }
        status = RecordStatus.AUDIO_RECORDING;
        timeSeekBar.setEnabled(false);
        recordView.setText(getString(R.string.stop_dubbing));
        previewButton.setEnabled(false);
        pauseButton.setEnabled(true);
        recordView.setPlayProgress(0f);
        String fileName = "temp";
        AudioFileUtils.setRootPath("Dubbing");
        recordPath = AudioFileUtils.getWavFileAbsolutePath(fileName);
        audioRecorder.createDefaultAudio(fileName);
        audioRecorder.startRecord(null);
        videoView.seekTo(0);
        playButtonToPlay(true);

        if (audioPlayer != null) {
            audioPlayer.stop();
            audioPlayer.release();
            audioPlayer = null;
        }
        audioPlayer = new MediaPlayer();
    }

    @Override
    public void permissionRecordAllow() {
        startRecord();
    }

    private Runnable onPlayPosition = new Runnable() {
        @Override
        public void run() {
            if (videoView.isPlaying()) {
                int position = videoView.getCurrentPosition();
                timeSeekBar.setProgress(position);
                timeBoardView.setTime(position);
                timeSeekBar.postDelayed(onPlayPosition, DELAY_TIME);
                float value = (position * 1.0f) / videoDuration;
                if (status == RecordStatus.AUDIO_RECORDING){
                    recordView.setRecordProgress(value);
                }
                else if (status == RecordStatus.AUDIO_STOP && recordPath != null){
                    recordView.setPlayProgress(value);
                }
                if (recordPath != null
                        &&  audioPlayer != null
                        &&  position < audioPlayer.getDuration()
                        &&  !audioPlayer.isPlaying()){
                    audioPlayer.seekTo(position);
                    audioPlayer.start();
                }
            }
        }
    };

    /*
   * 提取无声视频
   * */
    private void extractVideo() {

        ProgressHUD.show(PeiYinActivity.this,
                getString(R.string.please_wait_),
                getString(R.string.processing_in_progress));

        final String filePath = FileUtil.getCurrentTimeMillisPath(FileUtil.getSuffix(videoPath));
        String[] commands = Command.getInstance().extractVideo(videoPath, filePath);;
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:" + s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.processing_failed),PeiYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                ProgressHUD.dismiss(0);
                videoPath = filePath;
                prepareVideo(filePath);
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
    * 音频视频合并
    * */
    private void mixVideoAndAudio(){
        ProgressHUD.show(PeiYinActivity.this,getString(R.string.saving),null);
        final String result = FileUtil.getVideoResultPath(System.currentTimeMillis()+"",FileUtil.getSuffix(videoPath));
        int duration = videoDuration;
        String[] commands = Command.getInstance().addVideoBGMusic(videoPath,recordPath,result,duration);
        FFmpegUtil.getInstance().execFFmpegBinary(commands, new FFmpegUtil.FFmpegListener() {
            @Override
            public void onNotSupport() {

            }

            @Override
            public void onFailure(String s) {
                Log.d(TAG,"onFailure:"+s);
                ProgressHUD.dismiss(0);
                DialogPrompt.showText(getString(R.string.save_filed),PeiYinActivity.this);
            }

            @Override
            public void onSuccess(String s) {
                Log.d(TAG,"outPath:"+result);
                ProgressHUD.dismiss(0);
                saveSuccess(result);
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
    private void saveSuccess(String path){
        FileUtil.removeTmpFile();
        ProgressHUD.dismiss(0);
        Log.d(TAG,"resultPath:" + path);
        Intent play = new Intent(PeiYinActivity.this,VideoPlayActivity.class);
        play.putExtra("VIDEO_URL",path);
        if (play.resolveActivity(getPackageManager()) != null){
            startActivity(play);
        }
    }

    private void saveItemClick(){
        if (videoPath == null){
            DialogPrompt.showText(getString(R.string.please_choose_video),PeiYinActivity.this);
            return;
        }
        if (recordPath == null){
            DialogPrompt.showText(getString(R.string.can_not_save),PeiYinActivity.this);
            return;
        }
        mixVideoAndAudio();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_py,menu);
        MenuItem item = menu.findItem(R.id.menu_save_py);
        SpannableString spannableString = new SpannableString(item.getTitle());
        spannableString.setSpan(new ForegroundColorSpan(Color.WHITE), 0, spannableString.length(), 0);
        item.setTitle(spannableString);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
            case R.id.menu_add_py:
                requestSDCardPermission();
                return true;
            case R.id.menu_save_py:
                saveItemClick();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void permissionSDCardAllow() {
        ChooseFileUtil.chooseFile(PeiYinActivity.this, ChooseFileUtil.FileType.VIDEO,REQUEST_VIDEO_CODE_PY);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_VIDEO_CODE_PY&& resultCode == RESULT_OK && null != data) {
            Uri selectedVideo = data.getData();
            try {
                String path = FileUtil.getPath(PeiYinActivity.this,selectedVideo);
                Log.d(TAG,"videoPath = " + path);
                File videoFile = new File(path);
                if (videoFile.exists()){
                    videoPath = path;
                    videoDuration = 0;
                    stopVideoPosition = 0;
                    promptView.setVisibility(View.GONE);
                    resetRecord();
                    extractVideo();
                }else {
                    DialogPrompt.showText(getString(R.string.unable_to_load_the_file),PeiYinActivity.this);
                }
            } catch (URISyntaxException e) {
                e.printStackTrace();
                DialogPrompt.showText(getString(R.string.unable_to_load_the_file),PeiYinActivity.this);
            }
        }
    }

    private void resetRecord(){
        if (audioPlayer != null) {
            audioPlayer.stop();
            audioPlayer.release();
            audioPlayer = null;
        }
        audioPlayer = new MediaPlayer();
        pauseButton.setEnabled(false);
        previewButton.setEnabled(false);
        recordView.setText(getString(R.string.start_dubbing));
        recordView.setPlayProgress(0);
        recordView.setRecordProgress(0);
        pauseButton.setText(getString(R.string.pause_dubbing));
        status = RecordStatus.AUDIO_STOP;
        recordPath = null;
    }

    private void prepareVideo(String videoPath) {
        if (videoView.getVisibility() == View.INVISIBLE){
            videoView.setVisibility(View.VISIBLE);
        }
        videoView.setVideoPath(videoPath);
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                videoDuration = videoView.getDuration();
                Log.d(TAG,"getDuration" + videoDuration);
                timeSeekBar.setMax(videoDuration);
                if (stopVideoPosition > 0){
                    //视图生命周期处理
                    dealWithOnPauseAfter();
                }else {
                    Log.d(TAG,"stopVideoPosition <= 0");
                    timeBoardView.setTime(0);
                    playButtonToPlay(true);
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
                recordView.setPlayProgress(0f);
                if (audioPlayer != null && audioPlayer.isPlaying()){
                    audioPlayer.pause();
                }
                if (status == RecordStatus.AUDIO_RECORDING||status == RecordStatus.AUDIO_PAUSE){
                    stopRecord(true);
                }
            }
        });
        videoView.requestFocus();
    }

    private void dealWithOnPauseAfter(){
        if (status == RecordStatus.AUDIO_PAUSE){
            videoView.seekTo(stopVideoPosition);
            float value = stopVideoPosition * 1.0f / (videoDuration * 1.0f);
            recordView.setRecordProgress(value);
        }
        if (status == RecordStatus.AUDIO_STOP){
            videoView.seekTo(stopVideoPosition);
            if (recordPath != null){
                audioPlayer.seekTo(stopVideoPosition);
                float value = stopVideoPosition * 1.0f / (videoDuration * 1.0f);
                recordView.setPlayProgress(value);
            }
        }
    }

    private int stopVideoPosition = 0;
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG,"onPause");
        stopVideoPosition = videoView.getCurrentPosition();
        Log.d(TAG,"stopVideoPosition="+stopVideoPosition);
        //录音状态
        if (status == RecordStatus.AUDIO_RECORDING ){
            Log.d(TAG,"录音状态");
            recordPauseClick();
        }
        //播放状态
        else if (status == RecordStatus.AUDIO_STOP){
            Log.d(TAG,"非录音状态");
            playButtonToPlay(false);
        }
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
        LinearLayout container = (LinearLayout) findViewById(R.id.banner_container_py);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
