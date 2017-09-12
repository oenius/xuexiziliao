//
//  SingleCompressViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 17/4/12.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SingleCompressViewController: BaseViewController {

    
    
    
    @IBOutlet fileprivate weak var playContentView: VideoPlayerView!
    @IBOutlet fileprivate weak var orignSizeTitleLabel: UILabel!
    @IBOutlet fileprivate weak var orignSizeLabel: UILabel!
    @IBOutlet fileprivate weak var complessSizeTitleLabel: UILabel!
    @IBOutlet fileprivate weak var compressSizeLabel: UILabel!
    @IBOutlet fileprivate weak var bitRateSlider: UISlider!
    
    @IBOutlet weak var sliderBottom: NSLayoutConstraint!
    var assetModel: TZAssetModel!
//    var playerView:VideoPlayerView?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playContentView.shouQiBtn.isHidden = true
        orignSizeTitleLabel.text = "\(COMPRESS_before):"
        complessSizeTitleLabel.text = "\(COMPRESS_after):"
        playContentView.playWithAVAsset(avasset: (assetModel?.avAsset)!)
        bitRateSlider.minimumValue = 500
        bitRateSlider.maximumValue = Float(assetModel.bitrate);
        bitRateSlider.value = (500 + Float(assetModel.bitrate))/2
        assetModel.compressDetail.width = assetModel.pixelWidth
        assetModel.compressDetail.height = assetModel.pixelHeight
        assetModel.compressDetail.bitRate = Int(((500 + Float(assetModel.bitrate))/2))
        orignSizeLabel.text = StringWithFileSize(size_t: assetModel.fileSize)
        compressSizeLabel.text = StringWithCompressDetail(detail: assetModel.compressDetail,
                                                        duration: assetModel.duration)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: COMPRESS_Compress, style: .plain, target: self, action: #selector(startCompress))
        let backImage = UIImage(named: "back")
        let backItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backItem;
        //设置屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.view.layer.contents = stratchedNavibarImage?.cgImage
        bitRateSlider.thumbTintColor = UIColor.white
        bitRateSlider.setThumbImage(UIImage(named:"huadong"), for: .normal)
        bitRateSlider.setThumbImage(UIImage(named:"huadong"), for: .highlighted)
        bitRateSlider.minimumTrackTintColor = UIColor.white
        bitRateSlider.maximumTrackTintColor = UIColor.white
        playContentView.backgroundColor = back_Color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func goBack(){
        _ = navigationController?.popViewController(animated: true)
        UIApplication.shared.isIdleTimerDisabled = true
    }
   
    
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        sliderBottom.constant = contentInsets.bottom + 10
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func compressSliderValueChanged(_ sender: UISlider) {
        assetModel.compressDetail.bitRate = Int(sender.value)
        compressSizeLabel.text = StringWithCompressDetail(detail: assetModel.compressDetail,
                                                        duration: assetModel.duration)
    }

    
    
    func startCompress() {
        
        var videoPath = tmpDir
        videoPath += "compressVideo.mov"
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)

        hud.minSize = CGSize(width: self.view.frame.size.width/2, height: self.view.frame.size.height/4)
        // Configure the button.
        hud.button.setTitle(COMPRESS_cancel, for: .normal)
        hud.button.addTarget(self, action: #selector(cancelCompress), for: .touchUpInside)
        hud.backgroundView.style = .solidColor;
        hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
        hud.label.text = COMPRESS_compressing
        hud.detailsLabel.text = COMPRESS_notics
        let outPutUrl = URL(fileURLWithPath: videoPath)
        let tool = VideoCompress()
        tool.outputURL = outPutUrl
        tool.settings = assetModel.compressDetail
        weak var weakSelf = self
        tool.start(with: assetModel.avAsset) { (finish) in
            if finish {
                DispatchQueue.main.async(execute: { 
                    hud.hide(animated: true)
                    let cutVC = CutVideoViewController(nibName: "CutVideoViewController", bundle: Bundle.main)
                    let navi = UINavigationController(rootViewController: cutVC)
                    cutVC.asset = AVAsset(url: outPutUrl)
                    cutVC.asssetUrl = outPutUrl
                    self.present(navi, animated: true, completion: nil)
                    
                })
                
            }else{
                DispatchQueue.main.async(execute: {
                    hud.hide(animated: false)
                    let hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                    let  image = UIImage(named: "wrong.png")
                    let imageView = UIImageView(image: image)
                    hud.customView = imageView;
                    hud.mode = .customView;
                    hud.label.text = COMPRESS_unfinished
                    hud.backgroundView.style = .solidColor;
                    hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
                    hud.minSize = CGSize(width: (weakSelf?.view.frame.size.width)!/2, height: (weakSelf?.view.frame.size.height)!/4)
                    hud.hide(animated: true, afterDelay: 1.0)
                    
                    let exsit = FileManager.default.fileExists(atPath: outPutUrl.path)
                    if exsit == true{
                        do{
                            try FileManager.default.removeItem(at: outPutUrl)
                        }
                        catch {
                        }
                    }
                })
            }
        }
    }
    
    func cancelCompress()  {
        var videoPath = tmpDir
        videoPath += "compressVideo.mov"
        let exsit = FileManager.default.fileExists(atPath: videoPath)
        if exsit == true{
            do{
                try FileManager.default.removeItem(atPath: videoPath)
            }
            catch {
            }
        }
        goBack()
    }

    func StringWithCompressDetail(detail:CompressDetail, duration:CGFloat) -> String {
        let size = Int((Float(detail.bitRate+128000))/1024.0/8.0*Float(duration)*1024)
        return StringWithFileSize(size_t: size)
    }
    
    //MARK: - 字符转换
    func StringWithFileSize(size_t:Int?) -> String{
        var stringSize = ""
        guard let size = size_t else {
            return stringSize
        }
        if size < 1000 {
            stringSize = String(format: "%1luB", size)
        }
        else if size < 1000 * 1024{
            stringSize = String(format: "%.1fKB", Double(size)/1024.0)
        }
        else if size < 1000 * 1024 * 1024{
            stringSize = String(format: "%.1fMB", Double(size)/(1024.0*1024))
        }
        else {
            stringSize = String(format: "%.1fGB", Double(size)/(1024.0 * 1024 * 1024))
        }
        return stringSize
    }
    

}
