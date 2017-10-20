package com.liubowang.dubbing.JianJi;

import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.FloatRange;
import android.support.v4.view.MenuItemCompat;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.ViewConfiguration;
import android.widget.MediaController;
import android.widget.VideoView;

import com.jaeger.library.StatusBarUtil;
import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.ChooseFileUtil;
import com.liubowang.dubbing.Util.FFmpegUtil;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.SBUtil;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class JianJiActivity extends DBBaseActiviry {
    private static final String TAG = JianJiActivity.class.getSimpleName();
    private static final int REQUEST_VIDEO_CODE_JJ = 834;
    private VideoView videoview;
    private VideoClipView clipView;
    private String videoUrl;
    private String startTime;
    private String timeLength;
    private int videoDuration = -1;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_jian_ji);
        initUI();
        setStatusBar();
        setOverflowShowingAlways();
    }
    protected void setStatusBar() {
        StatusBarUtil.setColorNoTranslucent(this,getResources().getColor(R.color.colorPrimary));
    }

    private void initUI(){
        setTitle(getString(R.string.jianji));
        videoview = (VideoView) findViewById(R.id.videoView);
        clipView = (VideoClipView) findViewById(R.id.vcv_video_clip);
        clipView.setValueChangedListener(valueChangedListener);

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

    private VideoClipView.OnValueChangedListener valueChangedListener = new VideoClipView.OnValueChangedListener() {
        @Override
        public void onLeftValueChanged(@FloatRange(from = 0.0, to = 1.0) float leftValue) {
            Log.d(TAG,"leftValue:" + leftValue);
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
            case R.id.menu_start_jj:
                Log.d(TAG,"onOptionsItemSelected --> R.id.menu_start_jj");
                startClipVideo();
                return true;
            default:
                return super.onOptionsItemSelected(item);

        }
    }

    private void startClipVideo(){
        String storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + "Dubbing";
        final File appDir = new File(storePath);
        if (!appDir.exists()) {
            if (appDir.mkdir()){
                Log.d(TAG,"创建文件夹成功");
            }
        }
        String fileName[] = {System.currentTimeMillis() + ".mp4"};
        File outPutFile = new File(appDir, fileName[0]);
        if (videoDuration < 0 && videoview != null){
            videoDuration = videoview.getDuration();
        }
        try {
            outPutFile.createNewFile();
            //        int durationS = videoDuration  1000;
            float leftTime = videoDuration * clipView.getLeftValue();
            String startTime = SBUtil.getTimeFormat((int) (leftTime / 1000));
            float timeLen = videoDuration * clipView.getRightValue() - leftTime;
            String timeLength = SBUtil.getTimeFormat((int)(timeLen / 1000));
            String[] command = FFmpegUtil.Command.clipVideo(videoUrl,
                    outPutFile.getAbsolutePath(),
                    startTime,
                    timeLength);

            Log.d(TAG,"videoUrl"+videoUrl);
            Log.d(TAG,"outputUrl:"+outPutFile.getAbsolutePath());
            Log.d(TAG,"startTime:" + startTime);
            Log.d(TAG,"timeLength:" + timeLength);
            FFmpegUtil.execFFmpegBinary(command, new FFmpegUtil.FFmpegListener() {
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
                    Log.d(TAG,"onSuccess:" + s);
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
        } catch (IOException e) {
            e.printStackTrace();
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
                videoUrl = path;
                File videoFile = new File(path);
                playVideo(videoFile);
            } catch (URISyntaxException e) {
                e.printStackTrace();
            }

        }else {
            Log.d(TAG,"视频文件选取失败");
        }
    }
    public void playVideo(File videoFile) {
        // Uri videoUri = Uri.parse("http://www.androidbegin.com/tutorial/AndroidCommercial.3gp");
        // vv_videoview.setVideoURI(videoUri);
        if (videoFile.exists()) {
            final String path = videoFile.getAbsolutePath();
            videoview.setVideoPath(path);
            videoview.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    Log.d(TAG,"getDuration" + videoview.getDuration());
//                    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
//                    mmr.setDataSource(path);
//                    String duration = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION); // 播放时长单位为毫秒
//                    String width = mmr.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);//宽
//                    String height = mmr.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);//高
//                    Log.d(TAG,duration);
//                    mmr.getFrameAtTime(100)
                }
            });
            videoDuration = -1;
            clipView.reset();
            clipView.setVideoFrame(path);
            videoview.start();
            videoview.requestFocus();
        }
    }

}
