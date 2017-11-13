package com.liubowang.dubbing.Videos;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.liubowang.dubbing.Base.DBBaseActiviry;
import com.liubowang.dubbing.R;

import java.lang.reflect.Field;

public class VideosActivity extends DBBaseActiviry {

    private static final String TAG = VideosActivity.class.getSimpleName();
    private RecyclerView recycleView;
    private VideosAdapter adapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_videos);
        initUI();
        setOverflowShowingAlways();
    }

    private void initUI(){
        Toolbar myToolbar = (Toolbar) findViewById(R.id.tb_videos);
        setSupportActionBar(myToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ImageView imageView = (ImageView) findViewById(R.id.iv_top_image_videos);
        setStatusBar(imageView);
        recycleView = (RecyclerView) findViewById(R.id.rv_recycle_view_videos);
        GridLayoutManager manager = new GridLayoutManager(this,2);
        manager.setOrientation(LinearLayoutManager.VERTICAL);
        recycleView.setLayoutManager(manager);
        adapter = new VideosAdapter(videoItemListener);
        recycleView.setAdapter(adapter);
        recycleView.setItemAnimator(new DefaultItemAnimator());
    }

    private void setOverflowShowingAlways() {
        try {
            ViewConfiguration config = ViewConfiguration.get(this);
            Field menuKeyField = ViewConfiguration.class.getDeclaredField("sHasPermanentMenuKey");
            menuKeyField.setAccessible(true);
            menuKeyField.setBoolean(config, false);
        } catch (Exception e) {
            e.printStackTrace();
        }
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

    private VideosAdapter.OnVideoItemListener videoItemListener = new VideosAdapter.OnVideoItemListener() {
        @Override
        public void onItemDidClick(VideoInfo videoInfo, int infoIndex) {
            Log.d(TAG,"onItemDidClick:" + infoIndex );
            Intent intent = new Intent(VideosActivity.this,VideoPlayActivity.class);
            intent.putExtra("VIDEO_URL",videoInfo.videoUrl);
            if (intent.resolveActivity(getPackageManager()) != null){
                startActivity(intent);
            }
        }

        @Override
        public void onItemMoreButtonClick(VideoInfo videoInfo,  int infoIndex) {
//            Log.d(TAG,"onItemMoreButtonClick:" + infoIndex );
            final int clickIndex = infoIndex;
            String message = getString(R.string.delete_video) + " " + videoInfo.videoName + "?";
            AlertDialog dialog = new AlertDialog.Builder(VideosActivity.this)
                    .setMessage(message)
                    .setNegativeButton(getString(R.string.delete), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            adapter.removeItem(clickIndex);
                        }
                    }).setPositiveButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {

                        }
                    }).create();
            dialog.show();
        }
    };
    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected ViewGroup getBannerViewContainer() {
        LinearLayout container = (LinearLayout) findViewById(R.id.ll_banner_container_videos);
        return container;
    }

    @Override
    protected boolean shouldShowBannerView() {
        return true;
    }
}
