package com.liubowang.dubbing.HunYin;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.StyleRes;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;

import com.liubowang.dubbing.R;

/**
 * Created by heshaobo on 2017/10/27.
 */

public class FileAlertDialog extends AlertDialog implements View.OnClickListener{

    private Context context;
    private Button videoButton;
    private Button musicButton;
    private OnActionListener actionListener;

    protected FileAlertDialog(Context context) {
        super(context);
        this.context = context;
    }

    protected FileAlertDialog(Context context, boolean cancelable, OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
        this.context = context;
    }

    protected FileAlertDialog(Context context, @StyleRes int themeResId) {
        super(context, themeResId);
        this.context = context;
    }

    public void setActionListener(OnActionListener actionListener) {
        this.actionListener = actionListener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.view_file_dialog);
        videoButton = findViewById(R.id.b_video_dl);
        videoButton.setOnClickListener(this);
        musicButton = findViewById(R.id.b_music_dl);
        musicButton.setOnClickListener(this);

    }

    @Override
    public void show() {
        Window dialogWindow = getWindow();
        WindowManager.LayoutParams p = dialogWindow.getAttributes(); // 获取对话框当前的参数值
        p.gravity = Gravity.BOTTOM;
        dialogWindow.setAttributes(p);
        super.show();
    }

    @Override
    public void onClick(View view) {
        if (actionListener == null) return;
        if (view.getId() == R.id.b_music_dl){
            actionListener.onMusicAction();
        }
        else if (view.getId() == R.id.b_video_dl){
            actionListener.onVideoAction();
        }
    }

    interface OnActionListener{
        void onVideoAction();
        void onMusicAction();
    }

}
