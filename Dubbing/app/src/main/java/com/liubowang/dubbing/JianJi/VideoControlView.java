package com.liubowang.dubbing.JianJi;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.SeekBar;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/10/20.
 */

public class VideoControlView extends RelativeLayout {

    private Context context;
    private ImageButton pauseButton;
    private SeekBar seekBar;

    public VideoControlView(Context context) {
        super(context);
        initSubViews(context);
    }

    public VideoControlView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initSubViews(context);
    }

    public VideoControlView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubViews(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public VideoControlView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubViews(context);
    }
    private void initSubViews(Context context){
        this.context = context;
        LayoutInflater inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_video_control,this,true);
        pauseButton = findViewById(R.id.ib_video_pause);
        seekBar = findViewById(R.id.sb_video_control);
    }
}
