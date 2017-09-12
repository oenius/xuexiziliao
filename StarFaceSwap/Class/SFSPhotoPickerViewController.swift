//
//  SFSPhotoPickerViewController.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/1.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
import Masonry
import Photos
import MobileCoreServices
import SVProgressHUD

enum SFSPhotoPickerType {
    case album
    case camera
}

let kPhotoMaxLength:CGFloat = 400 //限制图片最长边长，图片越大处理速度越慢
let kBottomSpacing:CGFloat = 50


class SFSPhotoPickerViewController: BaseViewController {
    
    fileprivate var isAddStar:Bool = false
//    fileprivate var adButton:UIButton?
    fileprivate var goProBtn:UIButton?
    fileprivate var addStarBtn:UIButton?
    fileprivate var startBtn:UIButton?
    //MARK: 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        let isShowAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if isShowAD {
            NPCommonConfig.shareInstance().initAdvertise()
        }
        
        creatSubViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SFSDataManager.shareInstance().clearTmpFolder()
        let isBack = SFSDataManager.shareInstance().isBack()
        if isBack {
            let showAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
            if showAD {
                NPCommonConfig.shareInstance().showFullScreenAdWithNativeAdAlertView(for: self)
            }
        }
    }
    
    //添加子控件
    func creatSubViews()->(){
        //-------
//        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.red
//        imageView.image = UIImage(named: "bg.png")
//        self.view.insertSubview(imageView, at: 0)
//        
//        imageView.mas_makeConstraints { (make) in
//            _ = make?.top.equalTo()(self.view.mas_top)
//            _ = make?.bottom.equalTo()(self.view.mas_bottom)
//            _ = make?.left.equalTo()(self.view.mas_left)
//            _ = make?.right.equalTo()(self.view.mas_right)
        
//        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.layer.contents = UIImage(named: "ipad-bg")?.cgImage
        }else{
           self.view.layer.contents = UIImage(named: "iphone-bg.png")?.cgImage
        }

        //---
        let settingBtn = UIButton()
        settingBtn.setImage(UIImage(named:"set-"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingsBtnClick), for: .touchUpInside)
        self.view.addSubview(settingBtn)
        settingBtn.mas_makeConstraints { (make) in
            _ = make?.width.equalTo()(40)
            _ = make?.height.equalTo()(40)
            _ = make?.top.equalTo()(self.view.mas_top)?.offset()(10)
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(10)
        }
        
        let showAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if showAD {
//            adButton = UIButton()
//            adButton?.setImage(UIImage(named:"ads-"), for: .normal)
//            adButton?.addTarget(self, action: #selector(adButtonClick), for: .touchUpInside)
//            self.view.addSubview(adButton!)
//            _ = adButton?.mas_makeConstraints { (make) in
//                _ = make?.width.equalTo()(40)
//                _ = make?.height.equalTo()(40)
//                _ = make?.top.equalTo()(self.view.mas_top)?.offset()(10)
//                _ = make?.left.equalTo()(settingBtn.mas_right)?.offset()(20)
//            }
            goProBtn = UIButton()
            goProBtn?.setImage(UIImage(named:"Go-Pro"), for: .normal)
            goProBtn?.addTarget(self, action: #selector(goProBtnClick), for: .touchUpInside)
            self.view.addSubview(goProBtn!)
            _ = goProBtn?.mas_makeConstraints { (make) in
                _ = make?.width.equalTo()(70)
                _ = make?.height.equalTo()(40)
                _ = make?.top.equalTo()(self.view.mas_top)?.offset()(10)
                _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-10)
            }
        }

        var btnWidth = UIScreen.main.bounds.size.width/2
        btnWidth = btnWidth > 250 ? 250 :btnWidth
        
        addStarBtn = UIButton()
        self.view.addSubview(addStarBtn!)
        addStarBtn?.backgroundColor = UIColor(hexString: "8a81fd")
        addStarBtn?.layer.cornerRadius = 5
        addStarBtn?.layer.masksToBounds = true
        addStarBtn?.setTitle(SFS_addStar, for: .normal)
        addStarBtn?.addTarget(self, action: #selector(addStarClick(sender:)), for: .touchUpInside)
        _ = addStarBtn?.mas_makeConstraints { (make) in
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(10)
            _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-10)
            _ = make?.height.equalTo()(self.view.mas_height)?.multipliedBy()(1/13.0)
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(-kBottomSpacing)
        }
        
        startBtn = UIButton()
        self.view.addSubview(startBtn!)
        startBtn?.backgroundColor = UIColor(hexString: "ce48f0")
        startBtn?.layer.cornerRadius = 5
        startBtn?.layer.masksToBounds = true
        startBtn?.setTitle(SFS_startMake, for:.normal)
        startBtn?.addTarget(self, action: #selector(startMakeClick(sender:)), for: .touchUpInside)
        _ = startBtn?.mas_makeConstraints { (make) in
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(10)
            _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-10)
            _ = make?.height.equalTo()(self.view.mas_height)?.multipliedBy()(1/13.0)
            _ = make?.bottom.equalTo()(self.addStarBtn?.mas_top)?.offset()(-20)
        }
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addStarBtn?.titleLabel?.font = UIFont.systemFont(ofSize: (addStarBtn?.bounds.height)!/3)
        startBtn?.titleLabel?.font = UIFont.systemFont(ofSize: (startBtn?.bounds.height)!/3)
    }
    //MARK:actions
    
    func goProBtnClick() -> () {
//        getPoints()
        NPCommonConfig.shareInstance().gotoBuyProVersion()
    }
    
    func adButtonClick() -> () {
//        writImage()
        let showAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if showAD {
            NPCommonConfig.shareInstance().showNavitveAdAlertViewWithFullScreenAd(for: self)
        }
    }
    
    func settingsBtnClick(){
//        printLog("settingsBtnClick")
        let settings = SFSSettingsViewController()
        let navi = UINavigationController(rootViewController: settings)
        self.present(navi, animated: true, completion: nil)
    }
    
    func startMakeClick(sender:UIButton) -> () {
        isAddStar = false
        photoChooseAlertView(sourceView: sender)
    }
    
    func addStarClick(sender:UIButton) -> () {
        isAddStar = true
        photoChooseAlertView(sourceView: sender)
    }
    
    func photoChooseAlertView(sourceView:UIView) -> () {
        weak var weakSelf = self
        
        var title = SFS_choosePhoto
        if isAddStar {
            title = SFS_addStar
        }
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: SFS_fromAlbum, style: .default) { (_) in
            weakSelf?.albumPhotoChoose()
        }
        let cameraAction = UIAlertAction(title: SFS_takePhoto, style: .default) { (_) in
            weakSelf?.cameraPhotoChoose()
        }
        let cancel = UIAlertAction(title: SFS_cancel, style: .cancel) { (_) in
            
        }
        
        alertC.addAction(photoAction)
        alertC.addAction(cameraAction)
        alertC.addAction(cancel)
        
        let popoverVC = alertC.popoverPresentationController
        if popoverVC != nil {
            popoverVC?.sourceView = sourceView
            popoverVC?.sourceRect = CGRect(x: sourceView.frame.midX, y: 0, width: 20, height: 20)
            popoverVC?.permittedArrowDirections = .any
        }
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    
    func albumPhotoChoose() -> () {
        
        let status = PHPhotoLibrary.authorizationStatus()
        weak var weakSelf = self;
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (statusN) in
                    if(statusN == PHAuthorizationStatus.authorized){
                        DispatchQueue.main.async {
                           _ =  weakSelf?.pickerPhotoFormType(type: .album)
                        }
                    }
                });
            break
        case .restricted: fallthrough
        case .denied :
            authorizationStatusDeniedAlerViewType(type: .album)
            break
        case .authorized:
           _ =  pickerPhotoFormType(type: .album)
            break

        }
    }
    
    func cameraPhotoChoose() -> () {
        let dic = SFSDataManager.shareInstance().getFacePointArray()
        print(dic)
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        weak var weakSelf = self
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
               _ = weakSelf?.pickerPhotoFormType(type: .camera)
            })
            break;
        case .restricted :fallthrough
        case .denied:
            authorizationStatusDeniedAlerViewType(type: .camera)
            break;
        case .authorized:
            _ =  pickerPhotoFormType(type: .camera)
            break;

            
        }
    }
    
    //MARK: 获取图片
    func pickerPhotoFormType(type:SFSPhotoPickerType) -> Bool {
        
        DispatchQueue.global().async {
            SFSFaceSwapManager.shared().prepareDetectioin()
            
        }
        
        
        let sourceType = (type == .album) ? UIImagePickerControllerSourceType.photoLibrary : UIImagePickerControllerSourceType.camera
        let success = UIImagePickerController.isSourceTypeAvailable(sourceType)
        if success == false {
            return false
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        
        let att = [NSForegroundColorAttributeName:UIColor.white]
        imagePicker.navigationBar.barTintColor = UIColor(hexString: "202020", alpha: 1)
        imagePicker.navigationBar.tintColor = UIColor.white
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.titleTextAttributes = att
        imagePicker.view.backgroundColor = UIColor(hexString: "e7e9e9")
        present(imagePicker, animated: true, completion: nil)
        
        return true
    }
    
    func authorizationStatusDeniedAlerViewType(type:SFSPhotoPickerType) -> () {
        let alertC = UIAlertController(title: SFS_prompt, message: SFS_settingPermissions, preferredStyle: .alert)
        let cancel = UIAlertAction(title: SFS_cancel, style: .default) { (_) in
            
        }
        let setting = UIAlertAction(title: SFS_settings, style: .default) { (_) in
            
            let setUrl = URL(string: UIApplicationOpenSettingsURLString)
            if(UIApplication.shared.canOpenURL(setUrl!)){
                UIApplication.shared.openURL(setUrl!)
            }
            
        }
        
        alertC.addAction(cancel)
        alertC.addAction(setting)
        
        present(alertC, animated: true, completion: nil)
    }
    
    //MARK:广告相关
    override func removeAdNotification(_ notification: Notification!) {
        super.removeAdNotification(notification)
//        adButton?.removeFromSuperview()
//        adButton = nil
        goProBtn?.removeFromSuperview()
        goProBtn = nil
    }
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        var bottomSpacing = kBottomSpacing
        if contentInsets.bottom >= 30 {
            bottomSpacing = contentInsets.bottom + 10
        }
        _ = addStarBtn?.mas_updateConstraints({ (make) in
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(-bottomSpacing)
        })
    }
   
}
//MARK: 代理

extension SFSPhotoPickerViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate,SFSPhotoCropViewControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        var originalImage:UIImage?
        var editedImage:UIImage?
        var resultImage:UIImage?
        
        let result = CFStringCompare(mediaType as CFString, kUTTypeImage, CFStringCompareFlags(rawValue: CFOptionFlags(0)))
        
        if result == .compareEqualTo {
            editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            if editedImage != nil  {
                resultImage = editedImage
            }else{
                resultImage = originalImage
            }
        }
       picker.dismiss(animated: true, completion: nil)

        let cropController = SFSPhotoCropViewController(image: resultImage!)
        cropController.delegate = self
        cropController.maxRotationAngle = CGFloat(M_PI)
        cropController.modalPresentationStyle = .custom
        cropController.transitioningDelegate = SFSTransitioningDelegate.shareInstance()
        present(cropController, animated: true, completion: nil)
        
    }
    
    func photoCropControllerDidCancel(cropController: SFSPhotoCropViewController) {
        cropController.dismiss(animated: true, completion: nil)
        
    }
    func photoCropController(cropController: SFSPhotoCropViewController, croppedImage: UIImage) {
        let resizeImage = croppedImage.resizedImage(maxLength: kPhotoMaxLength)
        cropController.dismiss(animated: true, completion: nil)
        let imageData = UIImageJPEGRepresentation(resizeImage, 1)
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyMMddHHmmssSSS"
        let imageName = timeFormatter.string(from: currentDate).appending(".jpg")
        
        let imagePath = SFSDataManager.shareInstance().getTmpFolder().appending("\(imageName)")
        do {
            let imageUrl = URL(fileURLWithPath: imagePath)
            try imageData?.write(to: imageUrl)
        } catch  {
            printLog("保存图片失败")
        }
        //代码复用性不好，有时间重构
        if isAddStar {
            faceDetector(imagePath: imagePath, isAddFace: true)
        }else{
           
            let swapFace = SFSSwapFaceViewController(imageName: imageName)
            navigationController?.pushViewController(swapFace, animated: true)
        }

        printLog("-----\(resizeImage)")
        
    }
    func faceDetector(imagePath:String,isAddFace:Bool) -> () {
        
        SVProgressHUD.show(withStatus: SFS_isTesyingWait)
        DispatchQueue.global().async {
            printLog(Thread.current)
            SFSFaceSwapManager.shared().faceDetector(imagePath) { (faceCount, resultArray) in
                printLog(Thread.current)
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    if faceCount <= 0{
                        SVProgressHUD.showInfo(withStatus: SFS_notFace)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }
                    else if faceCount > 1{
                        SVProgressHUD.showInfo(withStatus: SFS_moreFace)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        
                    }
                    else{
                        printLog(faceCount)
                        printLog(resultArray)
                        
                        if isAddFace {
                            let image = UIImage(contentsOfFile: imagePath)
                            let imageData = UIImageJPEGRepresentation(image!, 1)
                            let currentDate = Date()
                            let timeFormatter = DateFormatter()
                            timeFormatter.dateFormat = "yyMMddHHmmssSSS"
                            let imageName = timeFormatter.string(from: currentDate).appending(".jpg")
                            let imagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(imageName)")
                            
                            do {
                                let imageUrl = URL(fileURLWithPath: imagePath)
                                try imageData?.write(to: imageUrl)
                            } catch  {
                                printLog("保存图片失败")
                            }
                            
                            let count = (resultArray?.count)!
                            var points = [SFSFacePoint]()
                            for i in 0..<count {
                                points.append(resultArray?.object(at: i) as! SFSFacePoint)
                            }
                            SFSDataManager.shareInstance().saveFaceDataToDefault(imageName: imageName, points: points)
                            SVProgressHUD.showSuccess(withStatus: SFS_addSuccess)
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }else{
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    //-----------------------测试-----------------------------
    func writImage() -> () {
        let imagesPath = Bundle.main.path(forResource: "test.plist", ofType: nil)
        guard let path = imagesPath else {
            return
        }
        let imagesArray = NSArray(contentsOfFile: path) as! [String]
        
        for name in imagesArray {
            //添加默认点
            let keyName = Bundle.main.path(forResource: name, ofType: "jpg")
            let image = UIImage(contentsOfFile: keyName!)
            let imageDate = UIImageJPEGRepresentation(image!, 1)
            
            let imageName = name.appending(".jpg")
            let imagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(imageName)")
            do {
                let url = URL(fileURLWithPath: imagePath)
                try imageDate?.write(to: url)
                printLog("imageUrl:\(url)")
            } catch  {
                printLog("保存失败")
            }
        }
    }
    
    func getPoints() -> () {
        let imagesPath = Bundle.main.path(forResource: "test.plist", ofType: nil)
        guard let path = imagesPath else {
            return
        }
        let imagesArray = NSArray(contentsOfFile: path) as! [String]
        
        for name in imagesArray {
            //添加默认点
            let imageName = name.appending(".jpg")
            let imagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(imageName)")
            faceDetectorTest(imagePath: imagePath, imageName: name, isAddFace: false)
        }
    }
    
    
    //MARK:DEBUG获取默认图片信息
    func faceDetectorTest(imagePath:String,imageName:String,isAddFace:Bool) -> () {

        SVProgressHUD.show(withStatus: "正在检测,请稍等...")

            printLog(imagePath)
            SFSFaceSwapManager.shared().faceDetector(imagePath) { (faceCount, resultArray) in
                printLog(Thread.current)
                
//                DispatchQueue.main.async {
                    if faceCount <= 0{
                        SVProgressHUD.showInfo(withStatus: "未检测到人脸,请重新选择!")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        
                    }
                    else if faceCount > 1{
                        SVProgressHUD.showInfo(withStatus: "检测到多张人脸,请请重新选择!")
                        SVProgressHUD.dismiss(withDelay: 1.5)

                    }
                    else{
                        printLog(faceCount)
                        printLog(resultArray)
                         SVProgressHUD.dismiss()
                        let count = (resultArray?.count)!
                        let points = NSMutableArray()
                        for i in 0..<count {
                            let dic = NSMutableDictionary()
                            let point = resultArray?.object(at: i) as! SFSFacePoint
                            dic.setObject("\(point.x)", forKey: "x" as NSCopying)
                            dic.setObject("\(point.y)", forKey: "y" as NSCopying)
                            points.add(dic)
                        }
                       
                        let plistName = imageName.appending(".plist")
                        let plistPath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(plistName)")
                        let url = URL(fileURLWithPath: plistPath)
                        points.write(to: url, atomically: true)
                        printLog(plistPath)
                    }
//                }
            }
    }
    //-----------------------测试-----------------------------
}
