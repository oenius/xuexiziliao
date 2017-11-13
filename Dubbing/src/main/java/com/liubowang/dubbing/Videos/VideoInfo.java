package com.liubowang.dubbing.Videos;

import java.io.File;

/**
 * Created by heshaobo on 2017/11/3.
 */

public class VideoInfo {

    public String videoUrl;
    public String thumUrl;
    public String duration;
    public String videoSize;
    public String videoName;
    public File videoFile;

    private VideoInfo(){
        super();
    }

    public VideoInfo(File videoFile){
        super();
        this.videoName = videoFile.getName();
        this.videoFile = videoFile;
        this.videoUrl = videoFile.getAbsolutePath();
    }

}
