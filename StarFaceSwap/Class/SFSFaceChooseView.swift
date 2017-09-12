//
//  SFSFaceChooseView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

let kFlowLayoutSpacing:CGFloat = 5.0
let kFaceChooseViewCellID = "kFaceChooseViewCellID"

protocol SFSFaceChooseViewDelegate {
    func faceDidChoosed(faceName:String?,facePoints:[SFSFacePoint]?)->()
    func photoDidChoosed(photoname:String)->()
}

class SFSFaceChooseView: UIView {
//    fileprivate var imagePicker:UIImagePickerController?
    fileprivate var collectoionView:UICollectionView!
//    fileprivate var selectedIndexPath:IndexPath = IndexPath(row: 0, section: 1)
    fileprivate var collectoionViewIsEditState:Bool = false
    var viewModel:SFSFaceChooseViewModel = SFSFaceChooseViewModel()
    var isWorkIng:Bool = false
    var delegate:SFSFaceChooseViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        setupSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(addFaceSuccess), name: NSNotification.Name(rawValue: kAddFaceSuccessNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFaceSuccess), name: NSNotification.Name(rawValue: kDeletedSuccessNotice), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 添加子控件
    func setupSubViews() -> () {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 20, height: 20)
        flowLayout.minimumInteritemSpacing = kFlowLayoutSpacing
        flowLayout.minimumLineSpacing = kFlowLayoutSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: kFlowLayoutSpacing, bottom: 0, right: kFlowLayoutSpacing)
        flowLayout.scrollDirection = .horizontal
        collectoionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectoionView.delegate = self
        collectoionView.dataSource = self
        collectoionView.showsVerticalScrollIndicator = false
        collectoionView.showsHorizontalScrollIndicator = false
        collectoionView.register(SFSFaceChooseCell.classForCoder(), forCellWithReuseIdentifier: kFaceChooseViewCellID)
        collectoionView.backgroundColor = UIColor.white
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(collectionLongPress(sender:)))
        longPress.minimumPressDuration = 1.0
        collectoionView.addGestureRecognizer(longPress)
        
        addSubview(collectoionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectoionView.frame = self.bounds
        let width = self.bounds.height - kFlowLayoutSpacing * 2 - 2
        let flowLayout = collectoionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: width)
    }
    
    func addFacePhtot() -> () {
        
        weak var weakSelf = self
        
        let alertC = UIAlertController(title: SFS_addStar, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: SFS_fromAlbum, style: .default) { (_) in
            weakSelf?.albumChoosePhoto()
        }
        let cameraAction = UIAlertAction(title: SFS_takePhoto, style: .default) { (_) in
            weakSelf?.cameraChoosePhoto()
        }
        let cancel = UIAlertAction(title: SFS_cancel, style: .cancel) { (_) in
            
        }
        
        alertC.addAction(photoAction)
        alertC.addAction(cameraAction)
        alertC.addAction(cancel)
        let presentVC = topViewController()
        
        let popoverVC = alertC.popoverPresentationController
        if popoverVC != nil {
            popoverVC?.sourceView = collectoionView
            popoverVC?.sourceRect = CGRect(x: collectoionView.frame.midX, y: 0, width: 20, height: 20)
            popoverVC?.permittedArrowDirections = .any
        }
        
        presentVC?.present(alertC, animated: true, completion: nil)
    }
    
    func collectionLongPress(sender:UILongPressGestureRecognizer) -> () {
        if sender.state == .began {
            collectoionViewIsEditState = true
            viewModel.setToEidtState(isEdit: true)
            collectoionView.reloadData()
        }
    }
    
    func addFaceSuccess() -> () {
        collectoionView.reloadData()
//        seleceFirstCell()
    }
    
    func deleteFaceSuccess() -> () {
        
    }
    func seleceFirstCell() -> () {
        collectionView(collectoionView, didSelectItemAt: IndexPath(row: 0, section: 1))
    }
    
    func topViewController() -> UIViewController? {
        return self.supviewController()
//        let window = (UIApplication.shared.delegate?.window)!
//        var topC = (window?.rootViewController)! as UIViewController
//        while topC.presentedViewController  != nil {
//            topC = topC.presentedViewController!
//        }
//        return topC
//        for (UIView* next = [self superview]; next; next = next.superview) {
//            UIResponder* nextResponder = [next nextResponder];
//            if ([nextResponder isKindOfClass:[UIViewController class]]) {
//                return (UIViewController*)nextResponder;
//            }
        }

    func albumChoosePhoto() -> () {
        
        let status = PHPhotoLibrary.authorizationStatus()
        weak var weakSelf = self;
        switch status {
        case .notDetermined:                PHPhotoLibrary.requestAuthorization({ (statusN) in
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
            //        default:
            //            prinyLog(message: "意外出现")
            //            break
        }
    }
    func cameraChoosePhoto() -> () {
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
            //        default: break;
            
        }
    }
    
    //MARK: 获取图片
    func pickerPhotoFormType(type:SFSPhotoPickerType) -> Bool {
        
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
        //        let att = [NSForegroundColorAttributeName:UIColor.white]
        let presentVC = topViewController()
        presentVC?.present(imagePicker, animated: true, completion: nil)
        
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
        let presentVC = topViewController()
        presentVC?.present(alertC, animated: true, completion: nil)
    }
}

    


extension SFSFaceChooseView:
            UICollectionViewDelegate,
            UICollectionViewDataSource,
            UIImagePickerControllerDelegate,
            UINavigationControllerDelegate,
            SFSPhotoCropViewControllerDelegate
{
    //MARK:UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isWorkIng {  return }
        
        if indexPath.section == 0 {
            if collectoionViewIsEditState {
                viewModel.setToEidtState(isEdit: false)
                collectoionViewIsEditState = false
                collectoionView.reloadData()
            }else{
                addFacePhtot()
            }
        }else{
            if collectoionViewIsEditState { return  }
            weak var weakSelf = self
            collectionView.performBatchUpdates({
                weakSelf?.viewModel.setSelectedState(selectedState: true, at: indexPath)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }, completion: { (com) in
                    weakSelf?.modelDidChoosed(at: indexPath)
                    collectionView.reloadData()
            })
            
            
            
        }
        

    }
    
    func modelDidChoosed(at indexPath:IndexPath) -> () {
        let model = viewModel.getModelAtIndexPath(indexPath_: indexPath)
        if delegate != nil {
            delegate?.faceDidChoosed(faceName: model?.imageName, facePoints: model?.points)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFaceChooseViewCellID, for: indexPath) as! SFSFaceChooseCell
        cell.backgroundColor = UIColor.green
        cell.model = viewModel.getModelAtIndexPath(indexPath_: indexPath)
        weak var weakSelf = self
        cell.deleteAction { (cellModel) in
            weakSelf?.collectoionView.performBatchUpdates({ 
                weakSelf?.viewModel.deletedFaceDate(imageName: (cellModel.imageName)!, at: indexPath)
                weakSelf?.collectoionView.deleteItems(at: [indexPath])
                }, completion: { (com) in
                    weakSelf?.collectoionView.reloadData()
            })
        }
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func fixCellState(indexPath_:IndexPath?,heightState:Bool) -> () {
        if indexPath_ == nil {
            return
        }
        viewModel.setSelectedState(selectedState: heightState, at: indexPath_!)
        collectoionView.reloadData()
        
    }
    
    //MARK:UIImagePickerControllerDelegate,UINavigationControllerDelegate,
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
        picker.dismiss(animated: true) {
            
        }
        let cropController = SFSPhotoCropViewController(image: resultImage!)
        cropController.delegate = self
        cropController.maxRotationAngle = CGFloat(M_PI)
        cropController.modalPresentationStyle = .custom
        cropController.transitioningDelegate = SFSTransitioningDelegate.shareInstance()
        let presentVC = self.topViewController()
        presentVC?.present(cropController, animated: true, completion: nil)
        
    }
    
    //MARK:SFSPhotoCropViewControllerDelegate
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
        
        if delegate != nil {
            delegate?.photoDidChoosed(photoname: imageName)
        }
        
    }

}
