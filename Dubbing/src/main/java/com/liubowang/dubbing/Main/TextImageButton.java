package com.liubowang.dubbing.Main;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/11/2.
 */

public class TextImageButton extends RelativeLayout {
    private ImageView imageView;
    private TextView textView;
    private String text;
    private int textColor;
    private Drawable image;


    public TextImageButton(Context context) {
        super(context);
        initSubView(context);

    }

    public TextImageButton(Context context, AttributeSet attrs) {
        super(context, attrs);
        initSubView(context);
        initAttr(context,attrs);
    }

    public TextImageButton(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initSubView(context);
        initAttr(context,attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TextImageButton(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initSubView(context);
        initAttr(context,attrs);
    }

    private void initSubView(Context context){
        LayoutInflater.from(context).inflate(R.layout.view_text_image_button,this,true);
        imageView = findViewById(R.id.tib_image_view);
        textView = findViewById(R.id.tib_text_view);
    }

    private void initAttr(Context context, AttributeSet attributeSet){
        TypedArray typedArray = context.obtainStyledAttributes(attributeSet,R.styleable.TextImageButton,0,0);
        image = typedArray.getDrawable(R.styleable.TextImageButton_tib_image);
        text = typedArray.getString(R.styleable.TextImageButton_tib_text);
        textColor = typedArray.getColor(R.styleable.TextImageButton_tib_textColor, Color.parseColor("#000000"));
        imageView.setImageDrawable(image);
        textView.setText(text);
        textView.setTextColor(textColor);
        typedArray.recycle();
    }

    public void setText(String text) {
        this.text = text;
        textView.setText(text);
    }

    public void setImage(Drawable image) {
        this.image = image;
        imageView.setImageDrawable(image);
    }

    public void setTextColor(int textColor) {
        this.textColor = textColor;
        textView.setTextColor(textColor);
    }

}
