package com.liubowang.dubbing.XiaoYin;

import android.os.Bundle;

import com.jaeger.library.StatusBarUtil;
import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;

public class XiaoYinActivity extends DBBaseActiviry {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_xiao_yin);
        initUI();
        setStatusBar();
    }
    protected void setStatusBar() {
        StatusBarUtil.setColorNoTranslucent(this,getResources().getColor(R.color.colorPrimary));
    }

    private void initUI(){

    }
}
