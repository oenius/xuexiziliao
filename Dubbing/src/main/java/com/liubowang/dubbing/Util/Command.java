package com.liubowang.dubbing.Util;

import android.util.Log;

/**
 * Created by heshaobo on 2017/10/23.
 */

public class Command {
    private static Command singleton = null;

    private Command(){};

    public static Command getInstance() {
        if (singleton == null) {
            synchronized (Command.class) {
                if (singleton == null) {
                    singleton = new Command();
                }
            }
        }
        return singleton;
    }

    public String getFFmpegTimeFormat(int time){
        int timeMMS = time % 1000;
        int second = time / 1000;
        int timeH = second / 3600;
        int timeS = second % 60;
        int timeM = second % 3600 / 60;
        return String.format("%02d:%02d:%02d.%03d",timeH,timeM,timeS,timeMMS);
    }

    public String[] clipVideo(String videoUrl,  String outputUrl, String beginTime,  String duration,
                                     boolean audioRecode){
        String[] commands = new String[12];
        commands[0] = "-ss";
        commands[1] = beginTime;
        commands[2] = "-y";
        commands[3] = "-i";
        commands[4] = videoUrl;
        commands[5] = "-t";
        commands[6] = duration;
        commands[7] = "-vcodec";
        commands[8] = "copy";
        if (audioRecode){
            commands[9] = "-b:a";
            commands[10] = "48000";
        }else {
            commands[9] = "-acodec";
            commands[10] = "copy";
        }
        commands[11] = outputUrl;//        String[] complexCommand = {
        return commands;
    }

    public String[] extractVideo(String videoPath, String outputPath){
        String[] commands = new String[7];
        commands[0] = "-i";
        commands[1] = videoPath;
        commands[2] = "-vcodec";
        commands[3] = "copy";
        commands[4] = "-an";
        commands[5] = "-y";
        commands[6] = outputPath;
        return commands;
    }

    public String[] extractAudio(String videoUrl, String outUrl) {
        String[] commands = extractAudio(videoUrl,outUrl,"copy");
        return commands;
    }

    public String[] extractAudio(String videoUrl, String outUrl, String audioType) {
        String[] commands = new String[7];
        commands[0] = "-i";
        commands[1] = videoUrl;
        commands[2] = "-acodec";
        commands[3] = audioType;
        commands[4] = "-vn";
        commands[5] = "-y";
        commands[6] = outUrl;
        return commands;
    }


    public String[] extractImage(String videoPath, String imagesPath, float startTimeMs, float durationMs,
                                  float numberPerSec,
                                  int width ,
                                  int height){
        String[] commands = new String[13];
        commands[0] = "-y";
        commands[1] = "-i";
        commands[2] = videoPath;
        commands[3] = "-an";
        commands[4] = "-r";
        commands[5] = "" + numberPerSec;
        commands[6] = "-ss";
        commands[7] = "" + startTimeMs;
        commands[8] = "-t";
        commands[9] = "" + durationMs;
        commands[10] = "-s";
        commands[11] = "" + width + "x" + height;
        commands[12] = imagesPath;
        return commands;
    }

    public String[] extractImage(String videoPath, String imagesPath, float numberPerSec, int width,
                                 int height){
        String[] commands = new String[9];
        commands[0] = "-i";
        commands[1] = videoPath;
        commands[2] = "-f";
        commands[3] = "image2";
        commands[4] = "-vf";
        commands[5] = "fps=fps="+numberPerSec;
        commands[6] = "-s";
        commands[7] = "" + width + "x" + height;
        commands[8] = imagesPath;
        return commands;
    }

    public String[] extractImage(String videoPath, float atMs, int width, int height,
                                 String imagesPath){
//        ffmpeg -ss 00:02:06 -i test1.flv -f image2 -y test1.jpg
//        ffmpeg -i input_file -y -f mjpeg -ss 8 -t 0.001 -s 320x240 output.jpg
        String[] commands = new String[8];
        commands[2] = "-i";
        commands[3] = videoPath;
        commands[0] = "-ss";
        commands[1] = ""+atMs;
        commands[4] = "-f";
        commands[5] = "image2";
        commands[7] = "" + width + "x" + height;
        commands[6] = "-y";
        commands[7] = imagesPath;

//        String[] commands = new String[12];
//        commands[0] = "-i";
//        commands[1] = videoPath;
//        commands[2] = "-y";
//        commands[3] = "-f";
//        commands[4] = "mjpeg";
//        commands[5] = "-ss";
//        commands[6] = ""+atMs;
//        commands[7] = "-t";
//        commands[8] = "0.001";
//        commands[9] = "-s";
//        commands[10] = ""+ width + "x" + height;
//        commands[11] = imagesPath;
        return commands;
    }

    public String[] cutYinPin(String inputUrl,int startTime, int duration, String outUrl) {
        String[] commands = new String[9];
        commands[0] = "-i";
        commands[1] = inputUrl;
        commands[2] = "-ss";
        commands[3] = getFFmpegTimeFormat(startTime);
//        commands[3] = "" + begainTime;
        commands[4] = "-t";
//        commands[5] = ""+second;
        commands[5] = getFFmpegTimeFormat(duration);
        commands[6] = "-acodec";
        commands[7] = "copy";
        commands[8] = outUrl;
        return commands;
    }

    public String[] cutYinPin(String inputUrl,int startTime, int duration, float vol, String outUrl) {
        String[] commands = new String[9];
        commands[0] = "-i";
        commands[1] = inputUrl;
        commands[2] = "-ss";
        commands[3] = getFFmpegTimeFormat(startTime);
        commands[4] = "-t";
        commands[5] = getFFmpegTimeFormat(duration);
        commands[6] = "-af";
        commands[7] = "volume="+vol;
        commands[8] = outUrl;
        return commands;
    }

    public String[] changeYinPinVolume(String inputUrl, float vol, String outUrl) {
//        ffmpeg -i input.wav -af volume=-3dB output.wav
//        ffmpeg -i input.wav -af 'volume=2' output.wav
//        Replace volume=X with a suitable number. For example 0.5 will half, 2 will double the volume.
//        String[] commands = new String[7];
//        commands[0] = "-i";
//        commands[1] = inputUrl;
//        commands[2] = "-vol";
//        commands[3] = String.valueOf(vol);
//        commands[4] = "-acodec";
//        commands[5] = "copy";
//        commands[6] = outUrl;
        String[] commands = new String[5];
        commands[0] = "-i";
        commands[1] = inputUrl;
        commands[2] = "-af";
        commands[3] = "volume="+vol;
        commands[4] = outUrl;
        return commands;
    }

    public String[] mixYinPin(String audio1, String audio2, String outputUrl) {
        String[] commands = new String[9];
        commands[0] = "-i";
        commands[1] = audio1;
        commands[2] = "-i";
        commands[3] = audio2;
        commands[4] = "-filter_complex";
        commands[5] = "amix=inputs=2:duration=first:dropout_transition=2";
        commands[6] = "-strict";
        commands[7] = "-2";
        commands[8] = outputUrl;
        return commands;
    }

    public String[] addVideoBGMusic(String videoUrl, String musicUrl, String outputUrl, int second) {
        String[] commands = new String[7];
        commands[0] = "-i";
        commands[1] = videoUrl;
        commands[2] = "-i";
        commands[3] = musicUrl;
//        commands[4] = "-ss";
//        commands[5] = "00:00:00.000";
//        commands[6] = "-t";
//        commands[7] = getFFmpegTimeFormat(second);
        commands[4] = "-vcodec";
        commands[5] = "copy";
//        commands[10] = "-acodec";
//        commands[11] = "copy";
        commands[6] = outputUrl;
        return commands;
    }

    public String[] appYinPin(String firstUrl,String secondUrl,String outputUrl){
        ///usr/local/ffmpeg/bin/ffmpeg -i d1.mp3 -i d2.mp3 -filter_complex '[0:0] [1:0] concat=n=2:v=0:a=1 [a]' -map [a] j5.mp3
//        /usr/local/ffmpeg/bin/ffmpeg -i 片头.wav -i 内容.WAV -i 片尾.wav -filter_complex '[0:0] [1:0] [2:0] concat=n=3:v=0:a=1 [a]' -map [a] 合成.wav
//        1
//        ffmpeg -i "concat:file1.mp3|file2.mp3" -acodec copy output.mp3
        
        String[] commands = new String[5];
        commands[0] = "-i";
        commands[1] = "concat:"+firstUrl+"|"+secondUrl;
        commands[2] = "-acodec";
        commands[3] = "copy";
        commands[4] = outputUrl;
        return commands;
    }

}
