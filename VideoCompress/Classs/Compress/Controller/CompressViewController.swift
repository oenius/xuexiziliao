//
//  CompressViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/17.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
let compressCellID = "compressCell"


class CompressViewController: BaseViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var HDBtn: UIButton!
//    @IBOutlet weak var bitRateView: HBLockSliderView!
    @IBOutlet weak var compressBtn: UIButton!
    
    @IBOutlet weak var settingContentView: UIView!
    @IBOutlet weak var bitSlider: HSSlider!

    var videoArray:[TZAssetModel] = []
    fileprivate var compresssCanShu:CompressDetail = CompressDetail()
    fileprivate lazy var defaultCompressCanShu:CompressDetail = {
       var detail = CompressDetail()
        detail.width = 640
        detail.height = 480
        detail.bitRate = 1000*1024
        return detail
    }()
    fileprivate var index:Int = 0
    fileprivate var videoCount:Int = 0
    fileprivate var hud:MBProgressHUD!
    fileprivate var isCancelCompress:Bool = false
    fileprivate var compressTool:VideoCompress!
    fileprivate lazy var videoUrlArray:[URL] = []
  
    fileprivate var isFirst:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: UInt(0))
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backBarItemClick))
        let needShowAD = needsShowAdView()
        if needShowAD == true {
            
            let proBtn = NPGoProButton(image: UIImage(named: "title_gopro_icon"),frame: CGRect(x: 0, y: 0, width: 52, height: 40 ))
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proBtn!)
        }
    
        chuShiHuaTableView()
        chuShiHUaBitRateView()
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
        compressBtn.setTitle(COMPRESS_compressFile, for: .normal)
        //设置屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
    }
    //MARK: 初始化
    func chuShiHuaTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CompressCell", bundle: nil), forCellReuseIdentifier: compressCellID)
        tableView.tableHeaderView?.backgroundColor = back_Color
        tableView.tableFooterView?.backgroundColor = back_Color
        tableView.backgroundColor = back_Color
    }
    
    func chuShiHUaBitRateView(){

        bitSlider.maxValue = 20000*1024
        bitSlider.minValue = 50*1024
        bitSlider.setValue(value: Float(defaultCompressCanShu.bitRate))
        bitSlider.backLabel.text = "\(COMPRESS_bitrate):\(StringWithFilebitRate(size: Float(defaultCompressCanShu.bitRate)))"
        
        compressBtn.layer.borderColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 1).cgColor
        compressBtn.layer.borderWidth = 2

//        settingContentView.layer.shadowColor = UIColor.white.cgColor// 阴影的颜色
//        settingContentView.layer.shadowRadius = 3// 阴影扩散的范围控制
//        settingContentView.layer.shadowOpacity = 0.8// 阴影透明度
//        settingContentView.layer.shadowOffset = CGSize(width: 1, height: 1)// 阴影的范围
        
        HDBtn.isHidden = true

    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst ==  true {
            videoHDChoosed(compressDetail: defaultCompressCanShu)
            isFirst = false
            
            let maskPath = UIBezierPath(roundedRect: HDBtn.bounds, byRoundingCorners: [.topRight ,.topLeft, .bottomRight], cornerRadii: CGSize(width: HDBtn.bounds.size.height/2, height: 0))
            let maskLayer = CAShapeLayer()
            
            maskLayer.frame = HDBtn.bounds
            maskLayer.path = maskPath.cgPath
            
            HDBtn.layer.mask = maskLayer
            HDBtn.isHidden = false
        }


    }
    //MARK - 广告
    
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        bottomConstraint.constant = contentInsets.bottom + 10
    }
    
    //MARK: - actions

    @IBAction func sliderValueChanged(_ sender: HSSlider) {
//        print(sender.getValue())
        compresssCanShu.bitRate = Int(sender.getValue())
        //TODO:比特率改变
        let string = StringWithFilebitRate(size: Float(compresssCanShu.bitRate))
        sender.backLabel.text = "\(COMPRESS_bitrate):\(string)"
        whenCompressDetailChanged(isSlider: true)
    }
    
    func backBarItemClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AssetChangedSuccssed_key), object: nil)
        UIApplication.shared.isIdleTimerDisabled = false
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func HDChooseBtnClick(_ sender: UIButton) {
        let hdChooseVC = VideoHDChooseViewController(nibName: "VideoHDChooseViewController", bundle: Bundle.main)
        let navi = UINavigationController(rootViewController: hdChooseVC)
        hdChooseVC.delegate = self
        present(navi, animated: true, completion: nil)
    }
    
    @IBAction func compressBtnClick(_ sender: UIButton) {
        videoCount = videoArray.count
        if hud != nil{
            hud.removeFromSuperview()
        }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        
        // Set the determinate mode to show task progress.
        //    hud.mode = MBProgressHUDModeDeterminate;
        
        hud.minSize = CGSize(width: self.view.frame.size.width/2, height: self.view.frame.size.height/4)
        // Configure the button.
        hud.button.setTitle(COMPRESS_cancel, for: .normal)
        hud.button.addTarget(self, action: #selector(cancelCompress), for: .touchUpInside)
        hud.backgroundView.style = .solidColor;
        hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
        
        videoCompress(selectArray: videoArray)
    }
    func cancelCompress() {
        isCancelCompress = true
//        compressTool.cancel()
        let fm = FileManager.default
        for url in videoUrlArray{
            let exsit = fm.fileExists(atPath: url.path)
            if exsit == true{
                do{
                    try fm.removeItem(at: url)
                }
                catch {
//                    print(error)
                }
            }
        }
       backBarItemClick()
    }
    func videoCompress(selectArray:[TZAssetModel]) {
        var videoPath = tmpDir
        videoPath += "\(index).mov"
//        print("\(videoPath)")
        hud.label.text = "\(COMPRESS_compressing)(\(index)/\(videoCount))"
        hud.detailsLabel.text = "\(COMPRESS_notics)"
        let outPutUrl = URL(fileURLWithPath: videoPath)
        videoUrlArray.append(outPutUrl)
        let model = selectArray[index]
        compressTool = VideoCompress();
        compressTool.outputURL = outPutUrl
        compressTool.settings = model.compressDetail
        
        weak var weakSelf = self
        guard let avasset = model.avAsset  else {
            print("压缩出错")
            return
        }
        compressTool.start(with: avasset) { (finish) in
            if finish == true{
                if weakSelf?.isCancelCompress == false {
                    if (weakSelf?.index)! == ((weakSelf?.videoCount)!-1) {
                        weakSelf?.index = 0
                        weakSelf?.hud.hide(animated: true)
                        weakSelf?.addAsset(videoUrlArray: (weakSelf?.videoUrlArray)!)
                        return
                    }
                    weakSelf?.index += 1
                    weakSelf?.videoCompress(selectArray: (weakSelf?.videoArray)!)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AssetChangedSuccssed_key), object: nil)
                    UIApplication.shared.isIdleTimerDisabled = false
                   _ = weakSelf?.navigationController?.popViewController(animated: true)
                }
                
            }else{
                DispatchQueue.main.async(execute: {
                    if weakSelf?.hud != nil{
                        weakSelf?.hud.removeFromSuperview()
                    }
                    weakSelf?.hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                    let  image = UIImage(named: "wrong.png")
                    let imageView = UIImageView(image: image)
                    weakSelf?.hud.customView = imageView;
                    weakSelf?.hud.mode = .customView;
                    weakSelf?.hud.label.text = COMPRESS_unfinished
                    weakSelf?.hud.backgroundView.style = .solidColor;
                    weakSelf?.hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
                    weakSelf?.hud.minSize = CGSize(width: (weakSelf?.view.frame.size.width)!/2, height: (weakSelf?.view.frame.size.height)!/4)
                    weakSelf?.hud.hide(animated: true, afterDelay: 1.0)
                    
                    let fm = FileManager.default
                    for url in (weakSelf?.videoUrlArray)!{
                        let exsit = fm.fileExists(atPath: url.path)
                        if exsit == true{
                            do{
                                try fm.removeItem(at: url)
                            }
                            catch {
//                                print(error)
                            }
                        }
                    }
                })
            }
    }
}
    
    func addAsset(videoUrlArray:[URL]) {
        // Add it to the photo library.
        weak var weakSelf = self
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrlArray[(weakSelf?.index)!])
            }, completionHandler: {success, error in
                if success == true{
                    
                    if (weakSelf?.index)! == ((weakSelf?.videoUrlArray.count)!-1) {
                        weakSelf?.index = 0
                        let fm = FileManager.default
                        for url in (weakSelf?.videoUrlArray)!{
                            let exsit = fm.fileExists(atPath: url.path)
                            if exsit == true{
                                do{
                                    try fm.removeItem(at: url)
                                }
                                catch {
//                                    print(error)
                                }
                            }
                        }
                        weakSelf?.videoUrlArray.removeAll(keepingCapacity: true)
                        
                        DispatchQueue.main.async(execute: {
                            if weakSelf?.hud != nil{
                                weakSelf?.hud.removeFromSuperview()
                            }
                            weakSelf?.hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                            let  image = UIImage(named: "Checkmark")
                            let imageView = UIImageView(image: image)
                            weakSelf?.hud.customView = imageView;
                            weakSelf?.hud.mode = .customView;
                            weakSelf?.hud.label.text = COMPRESS_saveSuccess
                            weakSelf?.hud.backgroundView.style = .solidColor;
                            weakSelf?.hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
                            weakSelf?.hud.minSize = CGSize(width: (weakSelf?.view.frame.size.width)!/2, height: (weakSelf?.view.frame.size.height)!/4)
                            weakSelf?.hud.hide(animated: true, afterDelay: 1.0)
                            weakSelf?.perform(#selector(weakSelf?.remindRemoveAsset), with: nil, afterDelay: 1.2)
                            return
                        })
                        return
                    }
                    weakSelf?.index += 1
                    if (weakSelf?.index)! < videoUrlArray.count {
                        weakSelf?.addAsset(videoUrlArray:(weakSelf?.videoUrlArray)!)
                    }
                }else{
                    UIApplication.shared.isIdleTimerDisabled = false
                    _ = weakSelf?.navigationController?.popViewController(animated: true)
                }
        })
    }

    func remindRemoveAsset()  {
        weak var weakSelf = self
        let alertContr = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_deleteOriginalVideo, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (action) in
            weakSelf?.removeAsset()
        }
        let cancel = UIAlertAction(title: COMPRESS_cancel, style: UIAlertActionStyle.default) { (action) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AssetChangedSuccssed_key), object: nil)
            UIApplication.shared.isIdleTimerDisabled = false
            _ = weakSelf?.navigationController?.popViewController(animated: true)
        }
        alertContr.addAction(ok)
        alertContr.addAction(cancel)
        present(alertContr, animated: true, completion: nil)
    }
    func removeAsset(){
        weak var weakSelf = self
        let completion = { (success: Bool, error: Error?) -> () in
            if success {
//                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                DispatchQueue.main.async {
//                    print("删除成功")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AssetChangedSuccssed_key), object: nil)
                    let alertContr = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_deletedPrompt, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (action) in
                        UIApplication.shared.isIdleTimerDisabled = false
                        _ = weakSelf?.navigationController?.popViewController(animated: true)
                    }
                    alertContr.addAction(action)
                    weakSelf?.present(alertContr, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                    //                    hud.minSize = CGSize(width: self.view.frame.size.width/2, height: self.view.frame.size.height/4)
                    hud.mode = .text
                    hud.label.text = COMPRESS_deletedFaild
                    hud.label.numberOfLines = 10
                    hud.detailsLabel.text = COMPRESS_deleteFiledDetail
                    hud.detailsLabel.numberOfLines = 10
                    hud.hide(animated: true, afterDelay: 3.0)
                    weakSelf?.perform(#selector(weakSelf?.backBarItemClick), with: nil, afterDelay: 3.2)
                }
            }
        }
        
        var assetArray:[PHAsset] = []
        for model in videoArray {
            if let phasset = model.asset as? PHAsset {
                assetArray.append(phasset)
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetArray as NSArray)
            }, completionHandler: completion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func StringWithFilebitRate(size:Float) -> String{
        var stringSize = ""
        if size < 1000 {
            stringSize = String(format: "%.0fbps", size)
        }
        else {
            stringSize = String(format: "%.0fkbps", Double(size)/1024.0)
        }
        //        else if size < 1000 * 1000 * 1000{
        //            stringSize = String(format: "%.1fMkbps", Double(size)/(1000.0*1000))
        //        }
        //        else {
        //            stringSize = String(format: "%.1fGkbps", Double(size)/(1000.0 * 1000.0 * 1000.0))
        //        }
        return stringSize
    }

    deinit {
//        print("CompressViewController-\(#function)")
    }
}

extension CompressViewController:UITableViewDataSource,UITableViewDelegate,VideoChooseHDDelegate{
    //MARK:UITableViewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: compressCellID) as? CompressCell
        if cell == nil {
            if cell == nil {
                let array:Array = Bundle.main.loadNibNamed("CompressCell", owner: nil, options: nil)!
                cell = array.first as? CompressCell
            }
        }
        let videoModel = videoArray[indexPath.row]
        weak var weakSelf = self
        cell?.loadVideoDataWithBlock(video: videoModel, preview: { (isAfter, model) in
//            print(isAfter)
//            print(model.fileSize)
            if isAfter == true {
                weakSelf?.previewAfter(model: model)
            }else{
                weakSelf?.previewBefore(model: model)
            }
        })
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func videoHDChoosed(compressDetail: CompressDetail) {
        compresssCanShu = compressDetail
        print(compressDetail)
        //TODO:HD改变]
        whenCompressDetailChanged(isSlider: false)
//        print(compressDetail)
    }

    
    func whenCompressDetailChanged(isSlider:Bool) {
        
        
        let count = videoArray.count
        
        
        for i in 0..<count {
            let model = videoArray[i]
            var modelCompressDetail = CompressDetail(width: model.compressDetail.width,
                                                     height: model.compressDetail.height,
                                                     bitRate: model.compressDetail.bitRate)
            if isSlider {
                compresssCanShu.height = (modelCompressDetail.height)
                compresssCanShu.width = (modelCompressDetail.width)
            }
            let cellVideoWidth = Float(model.pixelWidth)
            let cellVideoHeight = Float(model.pixelHeight)

            let scale = cellVideoWidth/cellVideoHeight
            let cellMin = cellVideoWidth<cellVideoHeight ? Int(cellVideoWidth) : Int(cellVideoHeight)
            let detailMin = compresssCanShu.width<compresssCanShu.height ? compresssCanShu.width : compresssCanShu.height

            if cellMin < detailMin{
                modelCompressDetail.width = model.pixelWidth
                modelCompressDetail.height = model.pixelHeight
                if Int(model.bitrate) >= compresssCanShu.bitRate {
                    modelCompressDetail.bitRate = compresssCanShu.bitRate
                }
            }else{
                if cellVideoWidth < cellVideoHeight{
                    if !isSlider {
                        modelCompressDetail.height = detailMin
                        modelCompressDetail.width = Int(Float(detailMin)*scale)
                    }
                    if Int(model.bitrate) >= compresssCanShu.bitRate {
                        modelCompressDetail.bitRate = compresssCanShu.bitRate
                    }
                }else{
                    if !isSlider {
                        modelCompressDetail.width = detailMin
                        modelCompressDetail.height = Int(Float(detailMin)/scale)
                    }
                    if Int(model.bitrate) >= compresssCanShu.bitRate {
                        modelCompressDetail.bitRate = compresssCanShu.bitRate
                    }
                }
            }
            print(modelCompressDetail)
            model.compressDetail = modelCompressDetail
            print(model.compressDetail)
        }
        tableView.reloadData()
    }
    
    
    //MARK:预览方法
    func previewBefore(model:TZAssetModel) {
        let previewVC = PreviewVideoViewController()
        previewVC.videoAsset = model.asset as? PHAsset
        let navi = UINavigationController(rootViewController: previewVC)
        present(navi, animated: true, completion: nil)
    }
    func previewAfter(model:TZAssetModel) {
        weak var weakSelf = self
        let hudd = MBProgressHUD.showAdded(to: view, animated: true)
        hudd.label.text = COMPRESS_previewing
        var videoPath = tmpDir
        videoPath += "preview.mov"
//        print("\(videoPath)")
        let outPutUrl = URL(fileURLWithPath: videoPath)
        let compress = VideoCompress()
        
        compress.outputURL = outPutUrl
        compress.isPreview = true
        compress.settings = model.compressDetail
        guard let avasset = model.avAsset else {
            print("压缩出错")
            return
        }
        compress.start(with: avasset) { (finish) in
            if finish == true{
                DispatchQueue.main.async(execute: {
                    hudd.hide(animated: true)
                    let previewVC = PreviewVideoViewController()
                    previewVC.videoUrl = outPutUrl
                    let navi = UINavigationController(rootViewController: previewVC)
                    weakSelf?.present(navi, animated: true, completion: nil)
                })
            }else{
                DispatchQueue.main.async(execute: {

                })
            }
        }
    }
}

