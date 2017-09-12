//
//  ViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class ViewController:  BaseViewController{


    @IBOutlet weak var startBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad{
            let image = UIImage(named: "press_me_foriPad")
            startBtn.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "press_me")
            startBtn.setImage(image, for: .normal)
        }
        let shouldAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if true == shouldAD {
            NPCommonConfig.shareInstance().initAdvertise()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:Actions
    @IBAction func jumpSettings() {
        let settings = CustomSettingsViewController()
        let navi = UINavigationController(rootViewController: settings)
        present(navi, animated: true, completion: nil)
    }
    
    @IBAction func goChooseVideos(_ sender: UIButton) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized: jumpToChooseVC()
            case .restricted:fallthrough
            case .denied: showSettingsAutor()
            case .notDetermined:
                weak var weakSelf = self
                PHPhotoLibrary.requestAuthorization({ (allow:PHAuthorizationStatus) in
                    if allow == PHAuthorizationStatus.authorized{
                        DispatchQueue.main.async(execute: { 
                            weakSelf?.jumpToChooseVC()
                        })
                    }else{
                        return;
                    }
                })
        }
    }
    func jumpToChooseVC() {
//        let videolistView = VideoListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
//        view.addSubview(videolistView)
//        
        let videoChoose = VideoChooseVC(nibName: "VideoChooseVC", bundle: Bundle.main)
        videoChoose.view.backgroundColor = UIColor.white
        let navi = UINavigationController(rootViewController: videoChoose)
        //        navi.modalPresentationStyle = UIModalPresentationStyle.custom
        //        navi.transitioningDelegate = CustomAnimatedDelegate.sharedInstance()
        present(navi, animated: true, completion: nil)
    }
    func showSettingsAutor()  {
        let alertAction = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_setPhotosPrivacy, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (_) in
            
        }
        alertAction.addAction(okAction)
        present(alertAction, animated: true, completion: nil)
    }
}
