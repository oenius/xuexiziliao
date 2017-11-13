package com.liubowang.dubbing.HunYin;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.liubowang.dubbing.R;
import com.liubowang.dubbing.Util.MediaUtil;
import com.liubowang.dubbing.Util.Mp3Info;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by heshaobo on 2017/10/30.
 */

public class MusicAdapter extends RecyclerView.Adapter<MusicAdapter.MusicViewHolder> {

    private static final String TAG = MusicAdapter.class.getSimpleName();
    private List<Mp3Info> musicList = new ArrayList<>();
    private OnMusicItemClickListener musicItemClickListener;
    private Context context;
    private MusicAdapter(){
        super();
    }

    public MusicAdapter(OnMusicItemClickListener listener,List<Mp3Info> dataSource){
        super();
        this.musicItemClickListener = listener;
        this.musicList = dataSource;
    }


    @Override
    public MusicViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        this.context = context;
        View view = LayoutInflater.from(context).inflate(R.layout.view_music_item,parent,false);
        MusicViewHolder holder = new MusicViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(MusicViewHolder holder, int position) {
        Mp3Info info = musicList.get(position);
        holder.bind(info);
    }

    @Override
    public int getItemCount() {
        return musicList.size();
    }

    class MusicViewHolder extends RecyclerView.ViewHolder{

        public ImageView musicImageView;
        public ImageView accessView;
        public TextView nameTextView;
        public TextView singerTextView;
        public TextView durationTextView;
        private Mp3Info mp3Info;
        public MusicViewHolder(View itemView) {
            super(itemView);
            musicImageView = itemView.findViewById(R.id.iv_music_image_item);
            accessView = itemView.findViewById(R.id.iv_access_view_item);
            nameTextView = itemView.findViewById(R.id.tv_music_name_item);
            singerTextView = itemView.findViewById(R.id.tv_music_singer_item);
            durationTextView = itemView.findViewById(R.id.tv_music_duration_item);
            itemView.setOnClickListener(clickListener);
        }

        private View.OnClickListener clickListener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (musicItemClickListener != null){
                    musicItemClickListener.onItemClick(mp3Info);
                }
            }
        };
        void bind(Mp3Info info){
            this.mp3Info = info;
//            public ImageView musicImageView;
//            public ImageView accessView;
//            public TextView nameTextView;
//            public TextView singerTextView;
//            public TextView durationTextView;
//            Bitmap bmp = MediaUtil.getArtwork(context, info.getId(), info.getAlbumId(), true, true);
//            musicImageView.setImageBitmap(bmp);
            nameTextView.setText(info.getTitle());
            singerTextView.setText(info.getArtist());
            String duration = MediaUtil.formatTime(info.getDuration());
            durationTextView.setText(duration);
        }

    }

    interface OnMusicItemClickListener{
        void onItemClick(Mp3Info info);
    }
}
