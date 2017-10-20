package com.liubowang.dubbing.Util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BlurMaskFilter;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Region;
import android.net.Uri;
import android.os.Environment;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

/**
 * Created by heshaobo on 2017/9/18.
 */

public class SBUtil {
    public static class Screen {
        public int widthPixels;
        public int heightPixels;
        public int densityDpi;
        public float widthDp;
        public float heightDp;
        public float density;
        public Screen(){}

    }

    private static final String TAG = SBUtil.class.getSimpleName();
    private static Screen mScreen;
    private static int mLedBitmapCount = 0;
    public static Screen getScreenSize(Context ctx){
        if (mScreen != null) return mScreen;
        WindowManager wm = (WindowManager) ctx.getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics dm = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(dm);
        mScreen = new Screen();
        mScreen.widthPixels = dm.widthPixels;
        mScreen.heightPixels = dm.heightPixels;
        mScreen.densityDpi = dm.densityDpi;
        mScreen.widthDp = (dm.widthPixels / dm.density);
        mScreen.heightDp =(dm.heightPixels / dm.density);
        mScreen.density = dm.density;
        return mScreen;
    }

    public static String getTimeFormat(int second){
        int timeH = second / 3600;
        int timeS = second % 60;
        int timeM = second % 3600 / 60;
        return String.format("%02d:%02d:%02d",timeH,timeM,timeS);
    }

    public static Bitmap getWangGeImage(Activity activity){
        DisplayMetrics dm = new DisplayMetrics();
        WindowManager wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(dm);
        int width = dm.widthPixels;
        int height = dm.heightPixels;
        float density = dm.density;
        int screenWidth = (int) (width / density);
        int screenHeight = (int) (height / density);
        Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Log.d(TAG,"the screen size is "+ width + "x" + height);
        Log.d(TAG,"the screen density is " + density);
        Canvas canvas = new Canvas(bmp);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.parseColor("#000000"));
        paint.setAntiAlias(true);
        float circleW = 6 * density;
        float space = 1 * density;
        int rCount = (int)(width / (circleW + space)) + 1;
        int lCount = (int)(height / (circleW + space)) + 1;
        float radius = circleW / 2;
        for (int i = 0 ; i < lCount ;i ++){
            for (int j = 0 ; j < rCount ;j ++){
                float cx = space + radius + j * (circleW + space);
                float cy = space + radius + i * (circleW + space);
                Path path = new Path();
                path.addCircle(cx,cy,radius, Path.Direction.CCW);
                canvas.clipPath(path, Region.Op.DIFFERENCE);
            }
        }
        canvas.drawRect(0,0,width,height,paint);
        return bmp;
    }
    public static Bitmap readCacheBitmap(Context context,String name) {
        File f = new File(context.getCacheDir(), name);
        Bitmap bitmap = readBitmap(f);
        return bitmap;
    }
    public static Bitmap readBitmap(File file){
        Bitmap bitmap = null;
        try{
            if(file.exists()) {
                bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }
    public static void writeCacheBitmap(Context context, Bitmap bitmap,String name){
        // 步骤1：获取输入值
        if(bitmap == null) return;
        File f = new File(context.getCacheDir(), name);
        writeBitmap(f,bitmap);
    }

    private static void writeBitmap(File file,Bitmap bitmap){
        try {
            if (file.exists()){
                file.delete();
            }
            file.createNewFile();

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 0 /*ignored for PNG*/, bos);
            byte[] bitmapdata = bos.toByteArray();
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(bitmapdata);
            fos.flush();
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    public static Bitmap getViewBitmap(View v) {

        int width = v.getWidth();
        int height = v.getHeight();
        Bitmap bp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bp);
        v.draw(canvas);
        canvas.save();
        return bp;
    }

}

