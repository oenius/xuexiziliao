//
//  SFSPhotoFilterViewController.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/8.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
import Masonry
import Photos
import SVProgressHUD

let kFilterCollectionViewCellID = "kFilterCollectionViewCellID"

class SFSPhotoFilterViewController: BaseViewController {

    
    fileprivate let filterNameList = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear",
        "CISepiaTone",
        "CIColorInvert",
        "SFSCustomFilterLomo",
        "SFSCustomFilterRetro",
        "SFSCustomFilterGothic",
        "SFSCustomFilterSharpening",
        "SFSCustomFilterElegant",
        "SFSCustomFilterRedwine",
        "SFSCustomFilterFresh",
        "SFSCustomFilterRomantic",
        "SFSCustomFilterHalo",
        "SFSCustomFilterBlues",
        "SFSCustomFilterDream"
    ]
    
    fileprivate let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Tone",
        "Linear",
        "Sepia",
        "Invert",
        "Lomo",
        "Retro",
        "Gothic",
        "Sharpening",
        "Elegant",
        "Redwine",
        "Fresh",
        "Romantic",
        "Halo",
        "Blues",
        "Dream"
    ]

    fileprivate var filterIndex = 0
    fileprivate let context = CIContext(options: nil)
    fileprivate var imageView: UIImageView?
    fileprivate var collectionView: UICollectionView?
    fileprivate var image: UIImage?
    fileprivate var smallImage: UIImage?
    fileprivate var suoImage:UIImage?
    public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        if let image = self.image {
            smallImage = resizeImage(image: image)
            suoImage = UIImage(named: "lock")
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        setupSubViews()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(backMove))
        let saveItem = UIBarButtonItem(image: UIImage(named:"save"), style: .plain, target: self, action:#selector(saveImage))
        let insertBtn = NPInterstitialButton(image: UIImage(named:"ads-"), viewController: self)
        let adItem = UIBarButtonItem(customView: insertBtn!)
        var items = [saveItem]
        let shouldAd = NPCommonConfig.shareInstance().shouldShowAdvertise()
        if shouldAd {
            items.append(adItem)
        }
        navigationItem.rightBarButtonItems = items
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "202020", alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor(hexString: "e7e9e9")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sss), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    func sss() -> () {
        printLog("s")
        collectionView?.reloadData()
    }
    func setupSubViews() -> () {
        self.view.backgroundColor = UIColor.darkGray
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 90, height: 118)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)
        collectionView?.register(SFSFilterCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: kFilterCollectionViewCellID)
        _ = collectionView?.mas_makeConstraints({ (make) in
            _ = make?.left.equalTo()(self.view.mas_left)
            _ = make?.right.equalTo()(self.view.mas_right)
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(0)
            _ = make?.height.equalTo()(138)
        })
        
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = self.image
        imageView?.isUserInteractionEnabled = true
       
        self.view.addSubview(imageView!)
        _ = imageView?.mas_makeConstraints({ (make) in
            _ = make?.top.equalTo()(self.view.mas_top)?.offset()(10)
            _ = make?.left.equalTo()(self.view.mas_left)?.offset()(10)
            _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-10)
            _ = make?.bottom.equalTo()(self.collectionView?.mas_top)?.offset()(-10)
        })
        
        let leftS = UISwipeGestureRecognizer(target: self, action: #selector(imageViewDidSwipeLeft))
        leftS.direction = .left
        leftS.numberOfTouchesRequired = 1
        imageView?.addGestureRecognizer(leftS)
        let rightS = UISwipeGestureRecognizer(target: self, action: #selector(imageViewDidSwipeRight))
        rightS.direction = .right
        rightS.numberOfTouchesRequired = 1
        imageView?.addGestureRecognizer(rightS)
    }
    
    
    func backMove() -> () {
        _ = navigationController?.popViewController(animated: true)
    }
    func saveImage() -> () {
        weak var weakSelf = self
        let alertC = UIAlertController(title: SFS_save, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: SFS_saveToAlbum, style: .default) { (_) in
            weakSelf?.saveToAlbumAuthorizationStatus()
        }
        let cameraAction = UIAlertAction(title: SFS_share, style: .default) { (_) in
            weakSelf?.shareImage()
        }
        let cancel = UIAlertAction(title: SFS_cancel, style: .cancel) { (_) in
            
        }
        
        alertC.addAction(photoAction)
        alertC.addAction(cameraAction)
        alertC.addAction(cancel)
        
        let popoverVC = alertC.popoverPresentationController
        if popoverVC != nil {
            popoverVC?.barButtonItem = navigationItem.rightBarButtonItem
            popoverVC?.permittedArrowDirections = .any
        }
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    func saveToAlbumAuthorizationStatus() -> () {
        let status = PHPhotoLibrary.authorizationStatus()
        weak var weakSelf = self;
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (statusN) in
            if(statusN == PHAuthorizationStatus.authorized){
                DispatchQueue.main.async {
                    weakSelf?.saveImageToAlbum()
                }
            }
        });
            break
        case .restricted: fallthrough
        case .denied :
            authorizationStatusDeniedAlerViewType(type: .album)
            break
        case .authorized:
            saveImageToAlbum()
            break
            
        }

    }
    
    func saveImageToAlbum() -> () {
        UIImageWriteToSavedPhotosAlbum((imageView?.image)!, nil, nil, nil)
        SVProgressHUD.showSuccess(withStatus: SFS_saveSuccess)
        SVProgressHUD.dismiss(withDelay: 1.5)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.7) { 
//            let shouldAD = NPCommonConfig.shareInstance().shouldShowAdvertise()
//            if shouldAD {
//                NPCommonConfig.shareInstance().showFullScreenAdWithNativeAdAlertView(for: self)
//            }
//        }
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

    func shareImage() -> () {
        let activityItem = [(imageView?.image)!]
        let activity = UIActivity()
        let activities = [activity]
        let activityController = UIActivityViewController(activityItems: activityItem, applicationActivities: activities)
//        activityController.completionWithItemsHandler = { (activityType:UIActivityType,completed:Bool,_)->Void in
//            
//        }
//        activity.completionWithItemsHandler = ^(UIActivityType  activityType, BOOL completed, NSArray *  returnedItems, NSError *  activityError){
//            if (completed) {
//                //            [self performSelector:@selector(xianShiGuangGao) withObject:nil afterDelay:1.2];
//                [weakSelf xianShiGuangGao];
//            }
//        };
        let popoverVC = activityController.popoverPresentationController
        if popoverVC != nil {
            popoverVC?.barButtonItem = navigationItem.rightBarButtonItem
            popoverVC?.permittedArrowDirections = .any
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    func imageViewDidSwipeLeft() {
        if filterIndex >= 2 {
            let jiaSuo = NPCommonConfig.shareInstance().shouldJiaShuoForPinlun()
            if jiaSuo {
                NPCommonConfig.shareInstance().showPinlunJiesuoView()
                return
            }
        }
        if filterIndex == filterNameList.count - 1 {
            filterIndex = 0
            imageView?.image = image
        } else {
            filterIndex += 1
        }
        if filterIndex != 0 {
            imageView?.image = applyFilter(at: filterIndex)
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    func imageViewDidSwipeRight() {
        if filterIndex == 0 {
            let jiaSuo = NPCommonConfig.shareInstance().shouldJiaShuoForPinlun()
            if jiaSuo {
                NPCommonConfig.shareInstance().showPinlunJiesuoView()
                return
            }
        }
        if filterIndex == 0 {
            filterIndex = filterNameList.count - 1
        } else {
            filterIndex -= 1
        }
        if filterIndex != 0 {
            imageView?.image = applyFilter(at: filterIndex)
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    func applyFilter(at index:Int) -> UIImage?{
        let filterName = filterNameList[index]
        if let image = self.image {
            if filterName.contains("SFSCustomFilter") {
                let filteredImage = SFSCustomFilter.image(with: image, withTypeString: filterName)
                 return filteredImage!
            }else{
                let filteredImage = createFilteredImage(filterName: filterName, image: image)
                return filteredImage
            }
        }
        return nil
    }
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        return filteredImage
    }
    
    func resizeImage(image: UIImage) -> UIImage {
//        let ratio: CGFloat = 0.5
//        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
//        UIGraphicsBeginImageContext(resizedSize)
//        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        let resizedImage = image.resizedImage(maxLength: 90)
        return resizedImage
    }
    override func removeAdNotification(_ notification: Notification!) {
        super.removeAdNotification(notification)
        
    }
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        _ = collectionView?.mas_updateConstraints { (make) in
            _ = make?.bottom.equalTo()(self.view.mas_bottom)?.offset()(-contentInsets.bottom)
        }
    }
}

extension  SFSPhotoFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFilterCollectionViewCellID, for: indexPath) as! SFSFilterCollectionViewCell
        var filteredImage = smallImage
        if indexPath.row != 0 {
            filteredImage = applyFilter(at: indexPath.row)
        }
        
        cell.imageView.image = filteredImage
        if indexPath.row > 2 {
            let jiaSuo = NPCommonConfig.shareInstance().shouldJiaShuoForPinlun()
            if jiaSuo {
                cell.suoImageView.image = suoImage
                cell.maskTmpView.backgroundColor = UIColor(white: 1, alpha: 0.6)
            }
        }else{
            cell.suoImageView.image = nil
            cell.maskTmpView.backgroundColor = UIColor.clear
        }
        cell.filterNameLabel.text = filterDisplayNameList[indexPath.row]
        updateCellFont()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNameList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 2 {
            let jiaSuo = NPCommonConfig.shareInstance().shouldJiaShuoForPinlun()
            if jiaSuo {
                NPCommonConfig.shareInstance().showPinlunJiesuoView()
                return
            }
        }
        filterIndex = indexPath.row
        if filterIndex != 0 {
            imageView?.image = applyFilter(at: filterIndex)
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }
    
    func updateCellFont() {
        
        // update font of selected cell
        if let selectedCell = collectionView?.cellForItem(at: IndexPath(row: filterIndex, section: 0)) {
            let cell = selectedCell as! SFSFilterCollectionViewCell
            cell.filterNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
            cell.layer.borderColor = UIColor(hexString: "57bfff").cgColor
        }
        
        for i in 0...filterNameList.count - 1 {
            if i != filterIndex {
                // update nonselected cell font
                if let unselectedCell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) {
                    let cell = unselectedCell as! SFSFilterCollectionViewCell
                    cell.layer.borderColor = UIColor.clear.cgColor
                    if #available(iOS 8.2, *) {
                        cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightThin)
                        
                    } else {
                        // Fallback on earlier versions
                        cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14.0)
                        
                    }
                }
            }
        }
    }
    
    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
