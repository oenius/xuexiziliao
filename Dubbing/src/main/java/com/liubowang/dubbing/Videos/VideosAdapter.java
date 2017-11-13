package com.liubowang.dubbing.Videos;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.BitmpUtil;
import com.liubowang.dubbing.Util.FileSizeUtil;
import com.liubowang.dubbing.Util.FileUtil;
import com.liubowang.dubbing.Util.SBUtil;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by heshaobo on 2017/11/3.
 */

public class VideosAdapter extends RecyclerView.Adapter<VideosAdapter.VideosHolder> {

    private static final String TAG = VideosAdapter.class.getSimpleName();
    private static int INDEX = 0;
    public OnVideoItemListener onVideoItemListener;
    public List<VideoInfo> videoList = new ArrayList<>();
    private VideosAdapter (){ super();}

    public VideosAdapter(OnVideoItemListener listener){
        super();
        this.onVideoItemListener = listener;
        initData();
    }
    /*
    * 文件过滤
    * */
    private FileFilter fileFilter= new FileFilter() {
        @Override
        public boolean accept(File file) {
            String s = file.getName().toLowerCase();
            if (s.endsWith(".mp4")|| s.endsWith(".3gp")||s.endsWith(".mov")){
                return true;
            }
            return false;
        }
    };

    private void initData(){
        String resultPath = FileUtil.getVideoResultPath();
        File videosFile = new File(resultPath);
        File[] files = videosFile.listFiles(fileFilter);
        videoList = new ArrayList<>();
        for (int i = 0 ;i < files.length; i ++){
            File file = files[i];
            VideoInfo info = new VideoInfo(file);
            videoList.add(info);
        }
    }

    public boolean removeItem(int index){
        if (index < 0 || index >= videoList.size()){
            return false;
        }
        VideoInfo info = videoList.remove(index);
        if (info.videoFile.exists()) {
            if (info.videoFile.delete()) {
                notifyItemRemoved(index);
                return true;
            }else {
                videoList.add(index,info);
                return false;
            }
        }else {
            return false;
        }
    }



    @Override
    public VideosHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        View view = LayoutInflater.from(context).inflate(R.layout.view_video_item,parent,false);
        VideosHolder holder = new VideosHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(VideosHolder holder, int position) {
        VideoInfo info = videoList.get(position);
        holder.bind(info,position);
    }

    @Override
    public int getItemCount() {
        return videoList.size();
    }


    class VideosHolder extends RecyclerView.ViewHolder {
        private ImageView imageView;
        private TextView videoName;
        private TextView videoSize;
        private TextView videoDuration;
        private ImageButton moreButton;
        private VideoInfo videoInfo;
        private int infoIndex;
        public VideosHolder(View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.iv_video_image_videos);
            videoName = itemView.findViewById(R.id.tv_video_name_videos);
            videoSize = itemView.findViewById(R.id.tv_video_size_videos);
            videoDuration = itemView.findViewById(R.id.tv_video_duration_videos);
            moreButton = itemView.findViewById(R.id.ib_more_button_videos);
            itemView.setOnClickListener(clickListener);
            moreButton.setOnClickListener(clickListener);
        }

        public void bind(VideoInfo videoInfo,int position){
            this.videoInfo = videoInfo;
            this.infoIndex = position;
            videoName.setText(videoInfo.videoName);
            videoDuration.setText(videoInfo.duration);
            if (videoInfo.videoSize == null){
                String size = FileSizeUtil.getAutoFileOrFilesSize(videoInfo.videoUrl);
                videoInfo.videoSize = size;
            }
            videoSize.setText(videoInfo.videoSize);
            videoDuration.setText(videoInfo.duration);
            if (videoInfo.thumUrl != null){
                Bitmap bitmap = BitmapFactory.decodeFile(videoInfo.thumUrl);
                imageView.setImageBitmap(bitmap);
            }else {
                new VideoInfoTask().execute();
            }

        }

        private View.OnClickListener clickListener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (view.getId() == R.id.ib_more_button_videos){
                    if (onVideoItemListener != null){
                        onVideoItemListener.onItemMoreButtonClick(videoInfo,infoIndex);
                    }
                }else {
                    if (onVideoItemListener != null){
                        onVideoItemListener.onItemDidClick(videoInfo,infoIndex);
                    }
                }
            }
        };
        private class VideoInfoTask extends AsyncTask<Void,Void,Bitmap>{

            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                imageView.setImageBitmap(null);
            }

            @Override
            protected Bitmap doInBackground(Void... voids) {
                MediaMetadataRetriever mmr = new MediaMetadataRetriever();
                if (!videoInfo.videoFile.exists()){
                    return  null;
                }
                mmr.setDataSource(videoInfo.videoUrl);
                if (videoInfo.duration == null){
                    long videoLength = Long.valueOf(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                    String duration = SBUtil.getTimeFormatShort((int) videoLength);
                    videoInfo.duration = duration;
                }
                if (videoInfo.thumUrl == null){
                    Bitmap bitmap = mmr.getFrameAtTime(10);
                    bitmap =BitmpUtil.scaleBitmpToMaxSize(bitmap,200);
                    if (bitmap == null) return null;

                    String filePath = FileUtil.getTmpPath() + INDEX + ".png";
                    INDEX++;
                    File outPutFile = new File(filePath);
                    videoInfo.thumUrl = filePath;
                    SBUtil.writeBitmap(outPutFile,bitmap);
                    return bitmap;
                }else {
                    Bitmap bitmap = BitmapFactory.decodeFile(videoInfo.thumUrl);
                    return bitmap;
                }
            }

            @Override
            protected void onPostExecute(Bitmap bitmap) {
                videoDuration.setText(videoInfo.duration);
                imageView.setImageBitmap(bitmap);
            }
        }
    }

    interface OnVideoItemListener{
        void onItemDidClick(VideoInfo videoInfo,int infoIndex);
        void onItemMoreButtonClick(VideoInfo videoInfo,int infoIndex);
    }




}
