package com.liubowang.dubbing.Main;

import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.HunYin.HunYinActivity;
import com.liubowang.dubbing.JianJi.JianJiActivity;
import com.liubowang.dubbing.PeiYin.PeiYinActivity;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.XiaoYin.XiaoYinActivity;

public class MainActivity extends DBBaseActiviry {

    private static final String TAG = MainActivity.class.getSimpleName();

    private ImageButton jianjiIb;
    private ImageButton xiaoyinIb;
    private ImageButton hunyinIb;
    private ImageButton peiyinIb;

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
        jianjiIb = (ImageButton) findViewById(R.id.ib_jianji_main);
        jianjiIb.setOnClickListener(buttonListener);
        xiaoyinIb = (ImageButton) findViewById(R.id.ib_xiaoyin_main);
        xiaoyinIb.setOnClickListener(buttonListener);
        hunyinIb = (ImageButton) findViewById(R.id.ib_hunyin_main);
        hunyinIb.setOnClickListener(buttonListener);
        peiyinIb = (ImageButton) findViewById(R.id.ib_peiyin_main);
        peiyinIb.setOnClickListener(buttonListener);

    }

    private View.OnClickListener buttonListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()){
                case R.id.ib_jianji_main:
                    jianjiClick();
                    break;
                case R.id.ib_xiaoyin_main:
                    xiaoyinClick();
                    break;
                case R.id.ib_hunyin_main:
                    hunyinClick();
                    break;
                case R.id.ib_peiyin_main:
                    peiyinClick();
                    break;
            }
        }
    };

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





}
