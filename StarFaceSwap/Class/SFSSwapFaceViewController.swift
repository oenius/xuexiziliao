//
//  SFSSwapFaceViewController.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
import SVProgressHUD

class SFSSwapFaceViewController: BaseViewController {

    fileprivate var faceChooseView:SFSFaceChooseView!
    fileprivate var orimage:UIImage!
    fileprivate var orimageName:String!
    fileprivate var orimagePoints:[SFSFacePoint]!
    fileprivate var imageView:UIImageView!
    fileprivate var canDectectorAtDidAppear:Bool = true
    //MARK: 视图生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        setupSubView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(back))
        let insertBtn = NPInterstitialButton(image: UIImage(named:"ads-"), viewController: self)
        let adItem = UIBarButtonItem(customView: insertBtn!)
        let editItem = UIBarButtonItem(image: UIImage(named:"edit"), style: .plain, target: self, action: #selector(editImage))
        var items = [editItem]
        let shouldAd = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if shouldAd {
            items.append(adItem)
        }
        navigationItem.rightBarButtonItems = items
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "202020", alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor(hexString: "e7e9e9")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if canDectectorAtDidAppear {
            let imageName = orimageName!
            let imagePath = SFSDataManager.shareInstance().getTmpFolder().appending("\(imageName)")
            faceDetector(imagePath: imagePath, isAddFace: false)
        }
        
    }
    
    //MARK: 初始化方法
    
    init(imageName:String) {
        super.init(nibName: nil, bundle: nil)
        orimageName = imageName
        let imagePath = SFSDataManager.shareInstance().getTmpFolder().appending("\(imageName)")
        let image = UIImage(contentsOfFile: imagePath)
        orimage = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupSubView() -> () {
        faceChooseView = SFSFaceChooseView(frame: CGRect.zero)
        self.view.addSubview(faceChooseView)
        faceChooseView.delegate = self
        faceChooseView.mas_makeConstraints { (make) in
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(-5)
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(0)
            _ = make?.right.equalTo()(self.view.mas_right)?.offset()(0)
            _ = make?.height.equalTo()(self.view.mas_height)?.multipliedBy()(1.0/6)
        }
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = orimage
        self.view.addSubview(imageView)
        imageView.mas_makeConstraints { (make) in
            _ = make?.top.equalTo()(self.view.mas_top)?.offset()(5)
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(5)
            _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-5)
            _ = make?.bottom.equalTo()(self.faceChooseView.mas_top)?.offset()(-10)
        }
        
    }
    //MARK:脸部识别
    func faceDetector(imagePath:String,isAddFace:Bool) -> () {
        
        SVProgressHUD.show(withStatus: SFS_isTesyingWait)
        weak var weakSelf = self
        DispatchQueue.global().async {
            weakSelf?.faceChooseView.isWorkIng = true
            printLog(Thread.current)
            SFSFaceSwapManager.shared().faceDetector(imagePath) { (faceCount, resultArray) in
                printLog(Thread.current)
               SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                   weakSelf?.canDectectorAtDidAppear  = false
                    if faceCount <= 0{
                       let message = SFS_notFace
                        weakSelf?.detectionFallAlertView(message: message, isAddFace: isAddFace)
                    }
                    else if faceCount > 1{
                        let message =  SFS_moreFace
                        weakSelf?.detectionFallAlertView(message: message, isAddFace: isAddFace)
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
                            weakSelf?.faceChooseView.isWorkIng = false
                            //封装不好，可重构
                            let viewModel = weakSelf?.faceChooseView.viewModel
                            viewModel?.saveFaceData(imageName: imageName, points: points)
                            //延时0.5s防止图片未写成功
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: { 
                                weakSelf?.faceChooseView.seleceFirstCell()
                            })
                        }else{
                            
                            let count = (resultArray?.count)!
                            var points = [SFSFacePoint]()
                            for i in 0..<count {
                                points.append(resultArray?.object(at: i) as! SFSFacePoint)
                            }
                            weakSelf?.orimagePoints = points
                            //封装不好，可重构
                            weakSelf?.faceChooseView.isWorkIng = false
                            weakSelf?.faceChooseView.seleceFirstCell()
                        }
                        
                    }
                }
            }
        }
        
    }
    
    
    func detectionFallAlertView(message:String,isAddFace:Bool) -> () {
        if isAddFace {
            SVProgressHUD.showInfo(withStatus: message)
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.faceChooseView.isWorkIng = false
        }else{
            let alertC = UIAlertController(title: SFS_prompt, message: message, preferredStyle: .alert)
            let sureAC = UIAlertAction(title: SFS_ok, style: .default, handler: { (sure) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            alertC.addAction(sureAC)
            present(alertC, animated: true, completion: nil)
        }
    }
    
    //MARK:人脸合成
    func swapFace(firstName:String,firstFacePoints:[SFSFacePoint],secondName:String,secondFacePoints:[SFSFacePoint]) -> () {
//        let string = "faceName:\(firstName)\n secondName:\(secondName)"
//        SVProgressHUD.showInfo(withStatus: string)
//        SVProgressHUD.dismiss(withDelay: 1.5)
        
        SVProgressHUD.show(withStatus: SFS_mixing)
        self.faceChooseView.isWorkIng = true
        weak var weakSelf = self
        //延时0.8s防止图片加载不成功
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8) {
            DispatchQueue.global().async {
                
                let fisrtImagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(firstName)")
                let secondImagePath = SFSDataManager.shareInstance().getTmpFolder().appending("\(secondName)")
                SFSFaceSwapManager.shared().swapFaceFirstImage(fisrtImagePath, firstPointArray: firstFacePoints, secondImage: secondImagePath, secondPointArray: secondFacePoints, completed: { (imagePath, swapImage, completed) in
                    DispatchQueue.main.async {
                        if completed {
                            weakSelf?.faceChooseView.isWorkIng = false
                            weakSelf?.imageView.image = swapImage
                            SVProgressHUD.dismiss()
                            weakSelf?.shouldAD()
                        }else{
                            SVProgressHUD.dismiss()
                            weakSelf?.faceChooseView.isWorkIng = false
                            let message = SFS_notFace
                            weakSelf?.detectionFallAlertView(message: message, isAddFace: false)
                        }
                    }
                })
            }
        }
    }
    func shouldAD() -> () {
        let should1 = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if !should1 { return }
        let should2 = SFSDataManager.shareInstance().isShouldShowAD()
        if !should2 { return }
        NPCommonConfig.shareInstance().showNavitveAdAlertViewWithFullScreenAd(for: self)
    }
    func back() -> () {
        if faceChooseView.isWorkIng {
            return
        }
        
        _ = navigationController?.popViewController(animated: true)
        SFSDataManager.shareInstance().setIsBack()
        SFSDataManager.shareInstance().clearTmpFolder()
    }
    
    func editImage() -> () {
        if faceChooseView.isWorkIng {
            return
        }
        let filterController = SFSPhotoFilterViewController(image: self.imageView.image!)
        navigationController?.pushViewController(filterController, animated: true)
    }
    
    //MARK:广告相关
    override func removeAdNotification(_ notification: Notification!) {
        super.removeAdNotification(notification)
       
    }
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
       _ = faceChooseView.mas_updateConstraints { (make) in
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(-contentInsets.bottom)
        }
    }
}

extension SFSSwapFaceViewController:SFSFaceChooseViewDelegate{
    func faceDidChoosed(faceName: String?, facePoints: [SFSFacePoint]?) {
        if faceName == nil {
            SVProgressHUD.showInfo(withStatus: SFS_synthesisFailed)
            SVProgressHUD.dismiss(withDelay: 1.5)
        }else{
            if let name = faceName {
                let imageName = orimageName!
                swapFace(firstName: name, firstFacePoints: facePoints!, secondName: imageName, secondFacePoints: orimagePoints)
            }else{
                SVProgressHUD.showInfo(withStatus: SFS_synthesisFailed)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
           
        }
        
    }
    
    func photoDidChoosed(photoname: String) {
        let imagePath = SFSDataManager.shareInstance().getTmpFolder().appending("\(photoname)")
        faceDetector(imagePath: imagePath, isAddFace: true)
    }
    
}

