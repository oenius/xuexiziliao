package com.liubowang.dubbing.JianJi;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
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

    @Override
    protected void onDraw(Canvas canvas) {
        int width = canvas.getWidth();
        int height = canvas.getHeight();
        int density = canvas.getDensity();
        int marign = 0;
        int lineCount = (width - marign - marign) / minUnit;
        float startX = 0;
        float stopX = 0;
        float stopY = canvas.getHeight();
        Paint  paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.parseColor("#FFFFFF"));
        paint.setStrokeWidth(1);
        for(int i = 0; i < lineCount; i ++){
            startX =  1 + i * minUnit;
            stopX = startX;
            float startY = canvas.getHeight() - 15;
            paint.setStrokeWidth(1);
            if (i % 5 == 0){
                startY = canvas.getHeight() - 20;
            }
            if (i % 10 == 0){
                paint.setStrokeWidth(2);
                startY = canvas.getHeight() - 30;
            }
            canvas.drawLine(startX,startY,stopX,stopY,paint);
        }
    }
}
