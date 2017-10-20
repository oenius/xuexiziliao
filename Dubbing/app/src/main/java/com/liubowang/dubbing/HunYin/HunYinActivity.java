package com.liubowang.dubbing.HunYin;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;

import com.jaeger.library.StatusBarUtil;
import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;

public class HunYinActivity extends DBBaseActiviry {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hun_yin);
        initUI();
        setStatusBar();
    }
    protected void setStatusBar() {
        StatusBarUtil.setColorNoTranslucent(this,getResources().getColor(R.color.colorPrimary));
    }

    private void initUI(){
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_hy,menu);
        return super.onCreateOptionsMenu(menu);
    }

}
