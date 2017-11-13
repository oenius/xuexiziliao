package com.liubowang.dubbing.Base;

import android.app.Application;

import com.lafonapps.common.Common;
import com.lafonapps.common.preferences.CommonConfig;
import com.liubowang.dubbing.BuildConfig;
import com.liubowang.dubbing.Util.FFmpegUtil;

/**
 * Created by heshaobo on 2017/10/17.
 */

public class DBApplication extends Application {
    private static final String TAG = DBApplication.class.getCanonicalName();
    private static DBApplication sharedApplication;
    @Override
    public void onCreate() {
        super.onCreate();
        sharedApplication = this;
        FFmpegUtil.getInstance().initFFmpeg(this);
        configAD();
    }

    public static DBApplication getSharedApplication() {
        return sharedApplication;
    }

    private void configAD(){
        /* Admob广告配置 */
        CommonConfig.sharedCommonConfig.appID4Admob = "ca-app-pub-7028363992110677~8272457174"; //广告应用ID
        CommonConfig.sharedCommonConfig.bannerAdUnitID4Admob = "ca-app-pub-7028363992110677/5508415239"; //横幅广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID4Admob = ""; //小型原生广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID132H4Admob = ""; //中型原生广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID250H4Admob = ""; //大型原生广告ID
        CommonConfig.sharedCommonConfig.splashAdUnitID4Admob = ""; //用作开屏广告的原生广告ID
        CommonConfig.sharedCommonConfig.interstitialAdUnitID4Admob = "";//"ca-app-pub-7028363992110677/5945676733"; //全屏广告ID

        /* 小米广告配置 */
        CommonConfig.sharedCommonConfig.appID4XiaoMi = "2882303761517629757"; //广告应用ID
        CommonConfig.sharedCommonConfig.bannerAdUnitID4XiaoMi = "a53a8aa4216c18d39da3830fdfb0ac21"; //横幅广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID4XiaoMi = "4c76f80fcf6f2ffb6783fe00a71c0dbc"; //小型信息流广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID132H4XiaoMi = ""; //信息流组图广告ID
        CommonConfig.sharedCommonConfig.nativeAdUnitID250H4XiaoMi = "cea6cea402e1801f6715daa828401b34"; //大型信息流广告ID
        CommonConfig.sharedCommonConfig.splashAdUnitID4XiaoMi = "c206ab0daf472ae5556cff6d5cef00b9"; //开屏广告ID
        CommonConfig.sharedCommonConfig.interstitialAdUnitID4XiaoMi = "87239f0fd5c5a3086d0c905eff32d010";//""87239f0fd5c5a3086d0c905eff32d010"; //全屏广告ID

        /* OPPO广告配置 */
        CommonConfig.sharedCommonConfig.appID4OPPO = "";
        CommonConfig.sharedCommonConfig.bannerAdUnitID4OPPO = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID4OPPO = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID132H4OPPO = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID250H4OPPO = "";
        CommonConfig.sharedCommonConfig.splashAdUnitID4OPPO = "";
        CommonConfig.sharedCommonConfig.interstitialAdUnitID4OPPO = "";

        /* 腾讯广告配置 */
        CommonConfig.sharedCommonConfig.appID4Tencent = "";
        CommonConfig.sharedCommonConfig.bannerAdUnitID4Tencent = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID4Tencent = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID132H4Tencent = "";
        CommonConfig.sharedCommonConfig.nativeAdUnitID250H4Tencent = "";
        CommonConfig.sharedCommonConfig.splashAdUnitID4Tencent = "";
        CommonConfig.sharedCommonConfig.interstitialAdUnitID4Tencent = "";


        /* 界面切换多少次后弹出全屏广告 */
        CommonConfig.sharedCommonConfig.numberOfTimesToPresentInterstitial = 99999999;

        /* 测试设备ID */
        CommonConfig.sharedCommonConfig.testDevices = new String[]{
                "2C7051C179D611A65CB34AED3255F136",
                "9E8A18C2A04EA50F41F258354D86601F",
                "7D08A034F6946BED1E0EF80F61A71124",
                "1FB61E9F3F955A3DEF1F1DCA2CD2C510",
                "226FF93D678B6499DF2DAA0AE56802F1",
                "181F363C876857CE4F79750F6A10D3AA"
        };


        /** 是否展示广告按钮 */
        CommonConfig.sharedCommonConfig.shouldShowAdButton = BuildConfig.showAdButton; //在app的build.gradle中进行差异化配置
        /** 是否显示横幅广告 */
        CommonConfig.sharedCommonConfig.shouldShowBannerView = BuildConfig.showBannerView; //在app的build.gradle中进行差异化配置
        /** 是否展示开屏广告 */
        CommonConfig.sharedCommonConfig.shouldShowSplashAd = BuildConfig.showSplashAd; //在app的build.gradle中进行差异化配置

        /* 友盟统计key */
        CommonConfig.sharedCommonConfig.UmengAppKey = "";

        Common.initialize(this);
    }
}
