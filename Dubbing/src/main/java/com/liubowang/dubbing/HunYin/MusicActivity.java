package com.liubowang.dubbing.HunYin;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.MediaUtil;
import com.liubowang.dubbing.Util.Mp3Info;
import com.liubowang.dubbing.Util.SBUtil;

import java.io.File;
import java.util.List;

public class MusicActivity extends DBBaseActiviry {

    private static final String TAG = MusicActivity.class.getSimpleName();
    private RecyclerView musicRecycleView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_music);
        initUI();
    }

    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_music);
        myToolbar.setTitle("");
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_music);
        setStatusBar(imageView);
        musicRecycleView = (RecyclerView) findViewById(R.id.rv_music_recycle_view);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        List<Mp3Info> list = MediaUtil.getMp3Infos(this);
        musicRecycleView.setLayoutManager(layoutManager);
        MusicAdapter adapter = new MusicAdapter(musicItemClickListener,list);
        musicRecycleView.setAdapter(adapter);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    private static final int REQUEST_MUSIC_CODE_HY = 298;
    private MusicAdapter.OnMusicItemClickListener musicItemClickListener = new MusicAdapter.OnMusicItemClickListener() {
        @Override
        public void onItemClick(Mp3Info info) {
            Intent intent = getIntent();
            intent.putExtra("MUSIC_INFO",info);
            setResult(REQUEST_MUSIC_CODE_HY,intent);
            finish();
        }
    };

    @Override
    protected ViewGroup getBannerViewContainer() {
        LinearLayout container = (LinearLayout) findViewById(R.id.ll_banner_container_main);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
