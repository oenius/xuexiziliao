//
//  AppDelegate.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/1.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    override class func initialize(){

        // 广告关键字定义
        //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
        // 免费版 appId
        NPCommonConfig.shareInstance().liteAppId = "1214753751"
        // 付费版 appId
        NPCommonConfig.shareInstance().proAppId = "1214753760"
        // 移除广告内购id
        NPCommonConfig.shareInstance().removeAdPurchaseProductId = "Remove_Ads_for_FaceSwap_Lite"
        // 用户反馈邮箱地址 // 无需修改
        NPCommonConfig.shareInstance().fadebackEmail = "np2016.ant@gmail.com"
        // 应用推广作者 id。 xinggui.zhang: '1124342842' ;  jingbing.yuan '743484976' ;  meiyan.chen '1209894980'
        
        NPCommonConfig.shareInstance().artistId = "1209894980"
        
        // 禁用自动显示全屏广告.设为： NSIntegerMax
        // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
        // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
        // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
        NPCommonConfig.shareInstance().viewAppearUntilShowInterstitialAd = 999999   // 全屏广告
        NPCommonConfig.shareInstance().viewAppearUntilPromptRate = 23          // 提示评论
        NPCommonConfig.shareInstance().shouldPreloadRewardVideoAd = true
        //    [NPCommonConfig shareInstance].viewAppearUntilPromptPayment = 11;        // 提示购买
        //    [NPCommonConfig shareInstance].nativeAdViewCloseType = NPNativeAdViewCloseTypeNotCoverAd;
        
       //MARK:由于Dlib静态库使用了NDEBUG，所以通用模块里的 #ifdef DEBUG 失效，测试阶段在这里使用测试广告ID 发布阶段使用真实ID
//        NPCommonConfig.shareInstance().admobBannerAdID =              "ca-app-pub-3940256099942544/2934735716"
//        NPCommonConfig.shareInstance().admobInterstitialAdID =        "ca-app-pub-3940256099942544/4411468910"
//        NPCommonConfig.shareInstance().admobNativeExpressAdID =       "ca-app-pub-6332273367158890/5389650966"
//        NPCommonConfig.shareInstance().admobNativeExpress132HAdID =   "ca-app-pub-6332273367158890/6752072161"
//        NPCommonConfig.shareInstance().admobNativeExpress250HAdID =   "ca-app-pub-6332273367158890/8228805363"
//        NPCommonConfig.shareInstance().admobRewardVideoAdID =         "ca-app-pub-1479030481724034/5885483906"
//        // 发布阶段使用真实广告ID
//        #if !DEBUG
        NPCommonConfig.shareInstance().admobBannerAdID              = "ca-app-pub-7028363992110677/1636555748"
        NPCommonConfig.shareInstance().admobInterstitialAdID        = "ca-app-pub-7028363992110677/3113288949"
        NPCommonConfig.shareInstance().admobNativeExpressAdID       = "ca-app-pub-7028363992110677/4590022141"
        NPCommonConfig.shareInstance().admobNativeExpress250HAdID   = "ca-app-pub-7028363992110677/6066755346"
        NPCommonConfig.shareInstance().admobRewardVideoAdID         = "ca-app-pub-7028363992110677/8254838948"
        
//        #endif
        // 配置提示评论相关信息
        NPCommonConfig.shareInstance().initRateAppConfig()
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isStatusBarHidden = true
        
//        let launchVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
//        let launchView = launchVC.view
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            launchView?.layer.contents = UIImage(named: "ipad-bg")?.cgImage
//        }else{
//            launchView?.layer.contents = UIImage(named: "iphone-bg.png")?.cgImage
//        }
        
        
        
        let photoPicker = SFSPhotoPickerViewController()
        let navi = UINavigationController(rootViewController: photoPicker)
        if let win = self.window {
            win.rootViewController = navi
        }else{
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navi
        }
        firstLaunchingSet()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func writeImage(image:UIImage,to path:String) -> () {
//        let iamgeData = UIImageJPEGRepresentation(UIImage(named:imageName)!, 1)
        let iamgeData = UIImagePNGRepresentation(image)
        
        printLog("addImagePath:\(path)")
        printLog("iamgeData:\(iamgeData)")
        do {
            let url = URL(fileURLWithPath: path)
            try iamgeData?.write(to: url)
        } catch  {
            printLog("====")
        }
    }

    func firstLaunchingSet() -> () {
        let isFisrt = SFSDataManager.shareInstance().isFirstLaunch()
        if isFisrt {
            let addImage = UIImage(named: "add")
            let addPath = SFSDataManager.shareInstance().getFaceFolder().appending("/add.png")
            writeImage(image: addImage!, to: addPath)
            
            let wanchengImage = UIImage(named: "wancheng")
            let wanchengPath = SFSDataManager.shareInstance().getFaceFolder().appending("/wancheng.png")
            writeImage(image: wanchengImage!, to: wanchengPath)
            
            let imagesPath = Bundle.main.path(forResource: "Images.plist", ofType: nil)
//            let imagesPath = Bundle.main.path(forResource: "test.plist", ofType: nil)
            guard let path = imagesPath else {
                return
            }
            let imagesArray = NSArray(contentsOfFile: path) as! [String]
            var totaldic = [String:[SFSFacePoint]]()
            
            for name in imagesArray {
                //添加默认点
                var pointArray = getPoints(plistName: name)
                for i in 1...68 {
                    let point = SFSFacePoint()
                    point.x = Float(i)
                    point.y = Float(i) + 1
                    pointArray.append(point)
                }
                let keyName = Bundle.main.path(forResource: name, ofType: "jpg")
                let image = UIImage(contentsOfFile: keyName!)
                let imageDate = UIImageJPEGRepresentation(image!, 1)
                let currentDate = Date()
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "yyMMddHHmmssSSS"
                let imageName = timeFormatter.string(from: currentDate).appending(".jpg")
                let imagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(imageName)")
                do {
                    let url = URL(fileURLWithPath: imagePath)
                    try imageDate?.write(to: url)
                } catch  {
                    printLog("保存失败")
                }
                totaldic[imageName] = pointArray
            }
            SFSDataManager.shareInstance().setFacePointDic(dic: totaldic)
        }
    }
    
    func getPoints(plistName:String) -> [SFSFacePoint] {
        let path = Bundle.main.path(forResource: plistName, ofType: "plist")
        let pointsT:NSArray = NSArray(contentsOfFile: path!)!
        let count = pointsT.count
        var points = [SFSFacePoint]()
        for i in 0..<count {
            let dic = pointsT.object(at: i) as! NSDictionary
            let point = SFSFacePoint()
            let xStr = dic.object(forKey: "x") as! NSString
            let yStr = dic.object(forKey: "y") as! NSString
            point.x = xStr.floatValue
            point.y = yStr.floatValue
            points.append(point)
        }
        return points
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

