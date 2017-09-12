//
//  CutVideoViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class CutVideoViewController: BaseViewController {

    fileprivate  var backItem: UIBarButtonItem!
    
    fileprivate  var cutItem: UIBarButtonItem!
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    fileprivate var isCutState = false
    var asset: AVAsset!
    var asssetUrl:URL!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var cutView: CutPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.playWithAVAsset(avasset: asset)
        playerView.shouQiBtn.isHidden = true
//        playerView.backgroundColor = back_Color
        self.view.backgroundColor = back_Color
        self.view.addSubview(cutView)
        backItem = UIBarButtonItem(title: COMPRESS_back, style: .plain, target: self, action: #selector(backItemClick(_:)))
        self.navigationItem.leftBarButtonItem = backItem
        cutItem = UIBarButtonItem(title: COMPRESS_Crop, style: .plain, target: self, action: #selector(cutItemClick(_:)))
        self.navigationItem.rightBarButtonItem = cutItem
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
        edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        shareButton.backgroundColor = UIColor(red:0.94, green:0.45, blue:0.49, alpha:1.00)
        shareButton.setTitle(COMPRESS_Share, for: .normal)
        shareButton.layer.cornerRadius = 5
        shareButton.layer.masksToBounds = true
        saveButton.backgroundColor = UIColor(red:0.77, green:0.48, blue:0.89, alpha:1.00)
        saveButton.setTitle(COMPRESS_Save, for: .normal)
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        cutView.isHidden = true
        buttonHeight.constant = 30
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playerView.playerPause()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
 
    override func needLoadBannerAdView() -> Bool {
        return true
    }
    
    @IBAction func cutItemClick(_ sender: UIBarButtonItem) {
       isCutState = !isCutState
        if !isCutState {
            cutItem.title = COMPRESS_Crop
            let range = cutView.getCutCMTimeRange()
            print(range)
            let start = CMTimeMakeWithSeconds(Float64(range.startTime), self.asset.duration.timescale)
            let end = CMTimeMakeWithSeconds(Float64(range.endTime), self.asset.duration.timescale)
            var path = NSTemporaryDirectory()
            let uuid = UUID().uuidString
            path += "\(uuid).mov"
            let outputUrl = URL(fileURLWithPath: path)
            let tool = VideoCompress()
            weak var weakSelf = self
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            tool.cutVideo(with: self.asset, start: start, andEnd: end, outUrl: outputUrl) { (error) in
                if error == nil{
                    let avseet = AVAsset(url: outputUrl)
                    weakSelf?.asset = avseet
                    weakSelf?.asssetUrl = outputUrl
                    avseet.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
                        DispatchQueue.main.async {
                            hud.hide(animated: true)
                            weakSelf?.cutView.isHidden = true
                            weakSelf?.buttonHeight.constant = 30
                            UIView.animate(withDuration: 0.3, animations: {
                                weakSelf?.view.layoutIfNeeded()
                            })
                            weakSelf?.playerView.playWithAVAsset(avasset: avseet)
                        }
                    })
                }
            }
        }else{
            cutItem.title = COMPRESS_ok
            cutView.setAsset(asset: asset)
            cutView.isHidden = false
            buttonHeight.constant = cutView.bounds.height + 60
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
       
    }
    @IBAction func backItemClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func shareButtonClick(_ sender: UIButton) {
//        (UIActivityType?, Bool, [Any]?, Error?)
        weak var weakSelf = self
        let handet = { (_:UIActivityType?, _:Bool, _:[Any]?, error:Error?) -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                weakSelf?.showAD()
            })
        }
        
        let activity = UIActivityViewController(activityItems: [asssetUrl], applicationActivities: nil)
        activity.completionWithItemsHandler = handet
        let poper = activity.popoverPresentationController
        if poper != nil {
            poper?.sourceView = self.shareButton
            poper?.permittedArrowDirections = .any
        }
        self.present(activity, animated: true, completion: nil)
    }
    @IBAction func saveButtonClick(_ sender: UIButton) {
        weak var weakSelf = self
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (weakSelf?.asssetUrl)!)
        }) { (success, error) in
            DispatchQueue.main.async(execute: {
                
                let hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                hud.mode = .customView;
                if success{
                    let  image = UIImage(named: "Checkmark")
                    let imageView = UIImageView(image: image)
                    hud.customView = imageView;
                    hud.label.text = COMPRESS_saveSuccess
                }else{
                    let  image = UIImage(named: "wrong")
                    let imageView = UIImageView(image: image)
                    hud.customView = imageView;
                    hud.label.text = error.debugDescription
                }
                hud.backgroundView.style = .solidColor;
                hud.backgroundView.color = UIColor(white: 0.1, alpha: 0.25)
                hud.minSize = CGSize(width: (weakSelf?.view.frame.size.width)!/2, height: (weakSelf?.view.frame.size.height)!/4)
                hud.hide(animated: true, afterDelay: 1.0)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    weakSelf?.showAD()
                })
                
            })
        }

       
    }
    func showAD(){
        DispatchQueue.main.async {
            if NPCommonConfig.shareInstance().shouldShowAdvertise() {
                NPCommonConfig.shareInstance().showFullScreenAdWithNativeAdAlertView(for: self)
            }
        }
        
    }
    func cutVideo(asset:AVAsset, timeRange:CMTimeRange) {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        var path = NSTemporaryDirectory()
        path += "cutVideo.mov"
        let outoutUrl = URL(fileURLWithPath: path)
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
            exportSession?.outputURL = outoutUrl
            exportSession?.outputFileType = AVFileTypeQuickTimeMovie
            exportSession?.timeRange = timeRange
            exportSession?.exportAsynchronously(completionHandler: {
                
                if exportSession?.status == .failed {
                    print(exportSession?.error)
                }
                else if exportSession?.status == .cancelled{
                }
                else if exportSession?.status == .completed{
                }
                
            })
            
        }
    }
}
