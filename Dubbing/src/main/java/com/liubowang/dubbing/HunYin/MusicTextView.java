package com.liubowang.dubbing.HunYin;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by heshaobo on 2017/10/30.
 */

public class MusicTextView extends View {

    private String title;
    private String clipTime;
    private float clipValue;

    public MusicTextView(Context context) {
        super(context);
    }

    public MusicTextView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public MusicTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public MusicTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public void setTitle(String title) {
        this.title = title;
        invalidate();
    }

    public void setClipTime(String clipTime,float clipValue) {
        this.clipTime = clipTime;
        this.clipValue = clipValue;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (title != null && title.length() >0){
            Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            textPaint.setTextSize(canvas.getHeight() / 3);
            textPaint.setColor(Color.parseColor("#FFFFFF"));
            Rect rect = new Rect();
            textPaint.getTextBounds(title,0,title.length(),rect);
            Paint.FontMetricsInt fontMetrics = textPaint.getFontMetricsInt();
            int baseline = (canvas.getHeight() - fontMetrics.bottom + fontMetrics.top) / 2 - fontMetrics.top;
            int x = 20;//(int) (canvas.getWidth() * 0.0f);
            if (x + rect.right > canvas.getWidth()){
                x = canvas.getWidth() - rect.right;
            }
            canvas.drawText(title,x,baseline,textPaint);
        }

        if (clipTime != null && clipTime.length() > 0){
            int height = canvas.getHeight();
            Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            textPaint.setTextSize(height / 5);
            textPaint.setColor(Color.parseColor("#FFFFFF"));
            Rect rect = new Rect();
            textPaint.getTextBounds(clipTime,0,clipTime.length(),rect);
            Paint.FontMetricsInt fontMetrics = textPaint.getFontMetricsInt();
            int y = height - fontMetrics.leading - 3;
            int x = (int) (getWidth() * clipValue);
            canvas.drawText(clipTime,x,y,textPaint);
        }
    }
}
