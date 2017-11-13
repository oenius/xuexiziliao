package com.liubowang.dubbing.Main;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Handler;
import android.support.v7.app.ActionBar;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.lafonapps.common.Common;
import com.lafonapps.common.base.BaseCommentActivity;
import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.HunYin.HunYinActivity;
import com.liubowang.dubbing.JianJi.JianJiActivity;
import com.liubowang.dubbing.PeiYin.PeiYinActivity;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Videos.VideosActivity;
import com.liubowang.dubbing.XiaoYin.XiaoYinActivity;

import java.util.List;

public class MainActivity extends DBBaseActiviry {

    private static final String TAG = MainActivity.class.getSimpleName();

    private TextImageButton jianjiIb;
    private TextImageButton xiaoyinIb;
    private TextImageButton hunyinIb;
    private TextImageButton peiyinIb;
    private TextView myFilesButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initUI();
    }



    private void initUI(){
        ActionBar ab = getSupportActionBar();
        if (ab != null)
        {
            ab.hide();
        }
        setStatusBar(null);
        jianjiIb = (TextImageButton) findViewById(R.id.tib_jianji_main);
        jianjiIb.setOnClickListener(buttonListener);
        xiaoyinIb = (TextImageButton) findViewById(R.id.tib_xiaoyin_main);
        xiaoyinIb.setOnClickListener(buttonListener);
        hunyinIb = (TextImageButton) findViewById(R.id.tib_hunyin_main);
        hunyinIb.setOnClickListener(buttonListener);
        peiyinIb = (TextImageButton) findViewById(R.id.tib_peiyin_main);
        peiyinIb.setOnClickListener(buttonListener);
        myFilesButton = (TextView) findViewById(R.id.tv_my_files_main);
        myFilesButton.setSoundEffectsEnabled(false);
        myFilesButton.setOnClickListener(buttonListener);
        ImageButton set = (ImageButton) findViewById(R.id.ib_set_main);
        set.setOnClickListener(buttonListener);

    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
        FileUtil.removeTmpFile();
    }

    private View.OnClickListener buttonListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()){
                case R.id.tib_jianji_main:
                    jianjiClick();
                    break;
                case R.id.tib_xiaoyin_main:
                    xiaoyinClick();
                    break;
                case R.id.tib_hunyin_main:
                    hunyinClick();
                    break;
                case R.id.tib_peiyin_main:
                    peiyinClick();
                    break;
                case R.id.tv_my_files_main:
                    myFilesButtonClick();
                    break;
                case R.id.ib_set_main:
                    setButtonClick();
                    break;
            }
        }
    };

    private void setButtonClick(){
        Intent set = new Intent(MainActivity.this, SettingsActivity.class);
        if (set.resolveActivity(getPackageManager()) != null){
            startActivity(set);
        }
    }

    private void myFilesButtonClick(){
        requestSDCardPermission();
    }

    @Override
    public void permissionSDCardAllow() {
        Intent videosIntent = new Intent(MainActivity.this, VideosActivity.class);
        if (videosIntent.resolveActivity(getPackageManager()) != null){
            startActivity(videosIntent);
        }
    }

    private void jianjiClick(){
        Intent jianjiIntent = new Intent(MainActivity.this, JianJiActivity.class);
        if (jianjiIntent.resolveActivity(getPackageManager()) != null)
        {
            startActivity(jianjiIntent);
        }
        else
        {
            Log.d(TAG,"打开剪辑失败");
        }
    }

    private void xiaoyinClick(){
        Intent xiaoyinIntent = new Intent(MainActivity.this, XiaoYinActivity.class);
        if (xiaoyinIntent.resolveActivity(getPackageManager()) != null)
        {
            startActivity(xiaoyinIntent);
        }
        else
        {
            Log.d(TAG,"打开消音失败");
        }
    }

    private void hunyinClick(){
        Intent hunyinIntent = new Intent(MainActivity.this, HunYinActivity.class);
        if (hunyinIntent.resolveActivity(getPackageManager()) != null)
        {
            startActivity(hunyinIntent);
        }
        else
        {
            Log.d(TAG,"打开混音失败");
        }
    }

    private void peiyinClick(){
        Intent peiyinIntent = new Intent(MainActivity.this, PeiYinActivity.class);
        if (peiyinIntent.resolveActivity(getPackageManager()) != null)
        {
            startActivity(peiyinIntent);
        }
        else
        {
            Log.d(TAG,"打开配音失败");
        }
    }

    @Override
    protected ViewGroup getBannerViewContainer() {
        LinearLayout container = (LinearLayout) findViewById(R.id.ll_banner_container_main);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
//--------------------------------------------------------------------------------------------------
//                                          以下评分的方法
// -------------------------------------------------------------------------------------------------
    private boolean mIsExit;
    private boolean isPingfen;

    /**
     * 弹出评分窗口,请求评分    类方法
     */
    public static void scoreView(final Context context){
        new AlertDialog.Builder(context).setTitle("☺☺☺☺☺")//设置对话框标题

                .setMessage(context.getString(com.lafonapps.common.R.string.score_app))//设置显示的内容

                .setPositiveButton(context.getString(com.lafonapps.common.R.string.hard_top_finish),
                        new DialogInterface.OnClickListener() {//添加确定按钮



                    @Override

                    public void onClick(DialogInterface dialog, int which) {//确定按钮的响应事件

                        // TODO Auto-generated method stub
                        if (hasAnyMarketInstalled(context)){
                            Uri uri = Uri.parse("market://details?id="+context.getPackageName());
                            Intent intentpf = new Intent(Intent.ACTION_VIEW,uri);
                            intentpf.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            context.startActivity(intentpf);
                        }else {
                            Toast.makeText(context, context.getString(com.lafonapps.common.R.string.toast),
                                    Toast.LENGTH_SHORT).show();
                        }

                    }

                }).setNegativeButton(context.getString(com.lafonapps.common.R.string.hard_top_cancel),
                new DialogInterface.OnClickListener() {//添加返回按钮



            @Override

            public void onClick(DialogInterface dialog, int which) {//响应事件

                // TODO Auto-generated method stub



            }

        }).show();//在按键响应事件中显示此对话框
    }

    /**
     * 弹出评分窗口,请求评分    对象方法
     */
    public void scoreView(){

        new AlertDialog.Builder(MainActivity.this).setTitle("☺☺☺☺☺")//设置对话框标题

                .setMessage(this.getString(com.lafonapps.common.R.string.score_app))//设置显示的内容

                .setPositiveButton(this.getString(com.lafonapps.common.R.string.hard_top_finish),
                        new DialogInterface.OnClickListener() {//添加确定按钮



                    @Override

                    public void onClick(DialogInterface dialog, int which) {//确定按钮的响应事件

                        // TODO Auto-generated method stub
                        if (hasAnyMarketInstalled(MainActivity.this)){
                            Uri uri = Uri.parse("market://details?id="+getPackageName());
                            Intent intentpf = new Intent(Intent.ACTION_VIEW,uri);
                            intentpf.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intentpf);
                        }else {
                            Toast.makeText(MainActivity.this, getString(com.lafonapps.common.R.string.toast),
                                    Toast.LENGTH_SHORT).show();
                        }

                    }

                }).setNegativeButton(this.getString(com.lafonapps.common.R.string.hard_top_cancel),
                new DialogInterface.OnClickListener() {//添加返回按钮



            @Override

            public void onClick(DialogInterface dialog, int which) {//响应事件

                // TODO Auto-generated method stub



            }

        }).show();//在按键响应事件中显示此对话框
    }

    public static boolean hasAnyMarketInstalled(Context context){

        Intent intent = new Intent();
        intent.setData(Uri.parse("market://details?id=android.browser"));
        List list = context.getPackageManager().queryIntentActivities(intent,
                PackageManager.MATCH_DEFAULT_ONLY);

        return 0 != list.size();
    }


    /**
     * 双击返回键退出
     */
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (Common.isApkDebugable()){
            mIsExit = true;
        }

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (mIsExit) {
                this.finish();

            } else {
                if (!isPingfen){
                    scoreView();
                    isPingfen = true;
                }else {
                    Toast.makeText(this, this.getString(com.lafonapps.common.R.string.exit_app),
                            Toast.LENGTH_SHORT).show();
                    mIsExit = true;
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            mIsExit = false;
                        }
                    }, 2000);
                }


            }
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }
}
