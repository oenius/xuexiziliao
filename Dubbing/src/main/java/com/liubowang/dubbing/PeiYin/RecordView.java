package com.liubowang.dubbing.PeiYin;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/11/2.
 */

public class RecordView extends RelativeLayout {

    private FrameLayout verticalView;
    private FrameLayout progressView;
    private TextView textView;
    private String text;
    private float recordProgress;
    private float playProgress;

    public RecordView(Context context) {
        super(context);
        initSubView(context);
    }

    public RecordView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initSubView(context);
    }

    public RecordView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubView(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public RecordView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubView(context);
    }

    private void initSubView(Context context){
        LayoutInflater.from(context).inflate(R.layout.view_record,this,true);
        verticalView = findViewById(R.id.rl_vertical_rv);
        progressView = findViewById(R.id.rl_progress_rv);
        textView = findViewById(R.id.tv_text_rv);
    }

    public void setText(String text) {
        this.text = text;
        textView.setText(text);
    }

    public void setPlayProgress(float playProgress) {
        this.playProgress = playProgress;
        float left = getWidth() * playProgress;
        verticalView.layout((int) left,verticalView.getTop(),(int) left +1,verticalView.getBottom());
    }

    public void setRecordProgress(float recordProgress) {
        this.recordProgress = recordProgress;
        float width = getWidth() * recordProgress;
        progressView.layout(0,progressView.getTop(),(int) width,progressView.getBottom());
    }
}
