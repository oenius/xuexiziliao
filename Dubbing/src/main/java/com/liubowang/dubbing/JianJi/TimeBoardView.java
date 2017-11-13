package com.liubowang.dubbing.JianJi;

import android.content.Context;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/10/25.
 */

public class TimeBoardView extends LinearLayout {

    private Context context;
    private int time;
    private TextView hourTextView;
    private TextView minuteTextView;
    private TextView secondTextView;
    private TextView millisecondTextView;
    public TimeBoardView(Context context) {
        super(context);
        initSubViews(context);
    }

    public TimeBoardView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initSubViews(context);
    }

    public TimeBoardView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubViews(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TimeBoardView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubViews(context);
    }
    private void initSubViews(final Context context) {
        this.context = context;
        LayoutInflater inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_time_board, this, true);
        hourTextView = findViewById(R.id.tv_hour_tbv);
        minuteTextView = findViewById(R.id.tv_minute_tbv);
        secondTextView = findViewById(R.id.tv_second_tbv);
        millisecondTextView = findViewById(R.id.tv_millisecond_tbv);
    }

    public void setTime(int time) {
        this.time = time;
        int timeMS = (time % 1000)/10;
        int second = time / 1000;
        int timeH = second / 3600;
        int timeS = second % 60;
        int timeM = second % 3600 / 60;
        hourTextView.setText(String.format("%02d",timeH));
        minuteTextView.setText(String.format("%02d",timeM));
        secondTextView.setText(String.format("%02d",timeS));
        millisecondTextView.setText(String.format("%02d",timeMS));
    }
}
