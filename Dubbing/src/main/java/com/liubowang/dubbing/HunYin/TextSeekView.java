package com.liubowang.dubbing.HunYin;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/10/26.
 */

public class TextSeekView extends LinearLayout {

    private TextView textView;
    private TextView valueText;
    private SeekBar seekBar;
    private int textColor;
    private int seekMax;
    private int progress;
    private String text;
    private OnTextSeekValueChangedListener onTextSeekValueChangedListener;
    public TextSeekView(Context context) {
        super(context);
        initSubViews(context);
    }

    public TextSeekView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initSubViews(context);
        initAttributeSet(context,attrs);
    }

    public TextSeekView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubViews(context);
        initAttributeSet(context,attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TextSeekView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubViews(context);
        initAttributeSet(context,attrs);
    }

    private void initAttributeSet(Context context, AttributeSet attributeSet){
        TypedArray typedArray = context.getTheme().obtainStyledAttributes(
                                                    attributeSet,
                                                    R.styleable.TextSeekView,
                                                            0,
                                                            0);

        textColor = typedArray.getColor(R.styleable.TextSeekView_textColor, Color.parseColor("#000000"));
        textView.setTextColor(textColor);
        valueText.setTextColor(textColor);
        seekMax = typedArray.getInteger(R.styleable.TextSeekView_seekMax,100);
        seekBar.setMax(seekMax);
        progress = typedArray.getInteger(R.styleable.TextSeekView_progress,50);
        seekBar.setProgress(progress);
        text = typedArray.getString(R.styleable.TextSeekView_text);
        textView.setText(text);
        typedArray.recycle();
    }

    private void initSubViews(Context context){
        LayoutInflater inflater = LayoutInflater.from(context);
        inflater.inflate(R.layout.view_text_seek,this,true);
        textView = findViewById(R.id.tv_text_tsv);
        seekBar = findViewById(R.id.sb_seek_tsv);
        seekBar.setOnSeekBarChangeListener(seekBarChangeListener);
        valueText = findViewById(R.id.tv_value_tsv);
    }

    public void setOnTextSeekValueChangedListener(OnTextSeekValueChangedListener onTextSeekValueChangedListener) {
        this.onTextSeekValueChangedListener = onTextSeekValueChangedListener;
    }

    private SeekBar.OnSeekBarChangeListener seekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            progress = i;
            valueText.setText("" + i + "%");
            if (onTextSeekValueChangedListener != null){
                onTextSeekValueChangedListener.onValueChange(TextSeekView.this,i,b);
            }
        }
        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {

        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {

        }
    };

    public void setText(String text) {
        this.text = text;
        textView.setText(text);
    }

    public void setTextColor(int textColor) {
        this.textColor = textColor;
        textView.setTextColor(textColor);
    }

    public void setProgress(int progress) {
        this.progress = progress;
        seekBar.setProgress(progress);
    }

    public void setSeekMax(int seekMax) {
        this.seekMax = seekMax;
        seekBar.setMax(seekMax);
    }

    public int getProgress() {
        return seekBar.getProgress();
    }

    interface OnTextSeekValueChangedListener{
        void onValueChange(TextSeekView textSeekView, int value, boolean b);
    }

}
