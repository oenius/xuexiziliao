package com.liubowang.dubbing.JianJi;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by heshaobo on 2017/10/19.
 */

public class TimeRulerView extends View {

    private static final String TAG = TimeRulerView.class.getSimpleName();
    public int timeLength = 0;
    public int minUnit = 10;
    private String text;
    private float p;
    public TimeRulerView(Context context) {
        super(context);
        setup();
    }

    public TimeRulerView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setup();
        initAttributeSet(attrs);
    }

    public TimeRulerView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setup();
        initAttributeSet(attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TimeRulerView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        setup();
        initAttributeSet(attrs);
    }


    private void setup(){

    }

    private void initAttributeSet(AttributeSet attributeSet){

    }

    public void setTimeLength(int timeLength) {
        this.timeLength = timeLength;
        invalidate();
    }

    public void setMinUnit(int minUnit) {
        this.minUnit = minUnit;
        invalidate();
    }

    public void setDrawText(String text,float p){
        this.text = text;
        this.p = p;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        setBackgroundColor(Color.parseColor("#1D1D1D"));
        int width = canvas.getWidth();
        int height = canvas.getHeight();
        int density = canvas.getDensity();
        int marign = 0;
        int lineCount = (width - marign - marign) / minUnit;
        float startX = 0;
        float stopX = 0;
        float stopY = height;
        Paint  paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.parseColor("#FFFFFF"));
        paint.setStrokeWidth(1);
        for(int i = 0; i < lineCount; i ++){
            startX =  1 + i * minUnit;
            stopX = startX;
            float startY = height - height / 2 / 2;
            paint.setStrokeWidth(1);
            if (i % 5 == 0){
                startY = height - height / 3;
            }
            if (i % 10 == 0){
                paint.setStrokeWidth(2);
                startY = height / 2 ;
            }
            canvas.drawLine(startX,startY,stopX,stopY,paint);
        }
        if (text != null && text.length() >0){
            Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            textPaint.setTextSize(canvas.getHeight() / 2);
            textPaint.setColor(Color.parseColor("#FFFFFF"));
            Rect rect = new Rect();
            textPaint.getTextBounds(text,0,text.length(),rect);
            Paint.FontMetricsInt fontMetrics = textPaint.getFontMetricsInt();
            int baseline = (height - fontMetrics.bottom + fontMetrics.top) / 2 - fontMetrics.top;
            int x = (int) (canvas.getWidth() * p);
            if (x + rect.right > canvas.getWidth()){
                x = canvas.getWidth() - rect.right;
            }
            canvas.drawText(text,x,baseline,textPaint);
        }

    }

}
