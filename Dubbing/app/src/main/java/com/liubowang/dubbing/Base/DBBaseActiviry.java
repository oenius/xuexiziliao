package com.liubowang.dubbing.Base;

import android.Manifest;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import com.jaeger.library.StatusBarUtil;
import com.liubowang.dubbing.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by heshaobo on 2017/10/17.
 */

public class DBBaseActiviry extends AppCompatActivity {
    private static final String TAG = DBBaseActiviry.class.getSimpleName();
    private static final int REQUEST_PERMISSION_SETTING  = 888;
    private static final int REQUEST_MULTIPLE_PERMISSION = 999;
    @Override
    public void setContentView(int layoutResID) {
        super.setContentView(layoutResID);
        setStatusBar();
    }
    public void permissionSDCardAllow(){

    }

    @Override
    public void setContentView(View view) {
        super.setContentView(view);
        setStatusBar();
    }

    @Override
    public void setContentView(View view, ViewGroup.LayoutParams params) {
        super.setContentView(view, params);
        setStatusBar();
    }

    protected void setStatusBar() {
        StatusBarUtil.setColor(this, getResources().getColor(R.color.colorPrimary));
        StatusBarUtil.setTranslucent(this,0);
    }
    public void requestSDCardPermission(){

        int hasWritePermission = ContextCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int hasReadPermission = ContextCompat.checkSelfPermission(this,
                Manifest.permission.READ_EXTERNAL_STORAGE);
//        int hasCamerPermission = ContextCompat.checkSelfPermission(this,
//                Manifest.permission.CAMERA);
        List<String> permissionList = new ArrayList<String>();
        if(hasWritePermission != PackageManager.PERMISSION_GRANTED) {
            permissionList.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
        }
        if (hasReadPermission != PackageManager.PERMISSION_GRANTED){
            permissionList.add(Manifest.permission.READ_EXTERNAL_STORAGE);
        }
//        if (hasCamerPermission != PackageManager.PERMISSION_GRANTED){
//            permissionList.add(Manifest.permission.CAMERA);
//        }
        if (permissionList.size() > 0){
            ActivityCompat.requestPermissions(this,
                    permissionList.toArray(new String[permissionList.size()]),
                    REQUEST_MULTIPLE_PERMISSION);
        }else {
            permissionSDCardAllow();
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        if (requestCode == REQUEST_MULTIPLE_PERMISSION) {

            boolean allowSelectPhoto = true;
            for (int i = 0, len = permissions.length; i < len; i++) {
                String permission = permissions[i];
                if (grantResults[i] == PackageManager.PERMISSION_DENIED) {
                    allowSelectPhoto = false;
                    boolean showRationale = ActivityCompat.shouldShowRequestPermissionRationale(this,permission);
                    if (!showRationale) {
                        AlertDialog dialog = new AlertDialog.Builder(this)
                                .setMessage(getString(R.string.rm_openPermission))
                                .setPositiveButton(getString(R.string.sure),
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                                Uri uri = Uri.fromParts("package", getPackageName(), null);
                                                intent.setData(uri);
                                                startActivityForResult(intent, REQUEST_PERMISSION_SETTING);
                                            }
                                        })
                                .setNegativeButton(getString(R.string.cancel),
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {

                                            }
                                        }).create();
                        Log.d(TAG,"ActivityCompat.shouldShowRequestPermissionRationale(this,permission)");
                        dialog.show();
                        return;
                    } else if (Manifest.permission.WRITE_EXTERNAL_STORAGE.equals(permission)) {

                        Log.d(TAG,"Manifest.permission.WRITE_EXTERNAL_STORAGE.equals(permission)");
                    } else if ( Manifest.permission.CAMERA.equals(permission)) {
                        Log.d(TAG,"Manifest.permission.CAMERA.equals(permission)");
                    }else if ( Manifest.permission.READ_EXTERNAL_STORAGE.equals(permission)) {
                        Log.d(TAG,"Manifest.permission.READ_EXTERNAL_STORAGE.equals(permission)");
                    }
                }
            }
            if (allowSelectPhoto){
                permissionSDCardAllow();
            }
        }
    }
}
