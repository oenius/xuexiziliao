//
//  VideoDatas.swift
//  PhotoPicker
//
//  Created by 何少博 on 16/11/10.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
//PHPhotoLibrary.shared().register(self)
//
//}
//
//deinit {
//    PHPhotoLibrary.shared().unregisterChangeObserver(self)
//}
import UIKit

import Photos

class VideoDatas: NSObject {
    
    fileprivate var isSmartRoll:Bool = false
    /**
     获取全部相册
     */
    fileprivate let imageManager = PHCachingImageManager()
    
    func getAllVideoListModel() -> [VideoListModel] {
        var listModelArray:[VideoListModel] = []
        //智能
        let videosAlbumModelArray = getVideosAlbumListModel()
        listModelArray += videosAlbumModelArray
        //智能
        let smartAlbumModelArray = getSmartRollListModel()
        listModelArray += smartAlbumModelArray
//      //自定义相册
        let userModelArray = getUserCollectionListModelArray()
        listModelArray += userModelArray
        return listModelArray
    }
    //所有
    func getAllVideosModel() -> VideoListModel {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allVideo = PHAsset.fetchAssets(with: allPhotosOptions)
        let model = VideoListModel()
        model.count = allVideo.count
        model.title = NSLocalizedString("AllVideo", comment: "所有视频")
        model.lastObject = allVideo.lastObject
        return model
        
    }

    //所有智能相册
    func getAllSmartListModel() -> [VideoListModel] {
        var listArray:[VideoListModel] = []
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let  count = smartAlbum.count
        for i in 0..<count {
            let collection = smartAlbum.object(at: i)
            let modelArray = getAllVideoListModelFromCollection(collection: collection)
            listArray += modelArray
        }
        return listArray
    }
    //视频
    func getVideosAlbumListModel() -> [VideoListModel] {
        var listArray:[VideoListModel] = []
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        let  count = smartAlbum.count
        for i in 0..<count {
            let collection = smartAlbum.object(at: i)
            let modelArray = getAllVideoListModelFromCollection(collection: collection)
            listArray += modelArray
        }
        return listArray
    }
    //相机胶卷
    func getSmartRollListModel() -> [VideoListModel] {
        var listArray:[VideoListModel] = []
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let  count = smartAlbum.count
        for i in 0..<count {
            let collection = smartAlbum.object(at: i) 
            let modelArray = getAllVideoListModelFromCollection(collection: collection)
            listArray += modelArray
        }
        return listArray
    }
    func getCameraRollCollection() -> PHAssetCollection? {
        let model = getSmartRollListModel().first
        return model?.assetCollection ;
    }
    //用户自定义的
    func getUserCollectionListModelArray() -> [VideoListModel] {
        var listArray:[VideoListModel] = []
        let user = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        let  count = user.count
        for i in 0..<count {
            let collection = user.object(at: i) as! PHAssetCollection
            let modelArray = getAllVideoListModelFromCollection(collection: collection)
            listArray += modelArray
        }
        return listArray
    }
    func getAllVideoListModelFromCollection(collection:PHAssetCollection) -> [VideoListModel] {
        var modelArray:[VideoListModel] = []
        let assets = getAssetsInAssetCollection(assetCollection: collection)
        let listModel = VideoListModel()
        listModel.count = (assets?.count)!
        listModel.title =  collection.localizedTitle
        listModel.lastObject = assets?.last 
        listModel.assetCollection = collection
    
        if listModel.count != 0{
            modelArray.append(listModel)
        }
        return modelArray
    }
    func getAssetsInAssetCollection(assetCollection:PHAssetCollection) -> [PHAsset]? {
        var array:[PHAsset] = []
        let result:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        result.enumerateObjects({ (obj, idx, stop) in
            if obj.mediaType == .video {
                array.append(obj)
            }
        })
        return array
    }
    //
    func getVideoModel(albumModel:VideoListModel) -> [VideoModel] {
        var videos:[VideoModel] = []
        var fetchResult:PHFetchResult<PHAsset>
        let asssetcollectoion = albumModel.assetCollection
        if asssetcollectoion == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }else{
            fetchResult = PHAsset.fetchAssets(in: albumModel.assetCollection!, options: nil)
        }
        let count = fetchResult.count
        for i in 0..<count{
            let model = VideoModel()
            let asset = fetchResult.object(at: i)
            model.representedAssetIdentifier = asset.localIdentifier
            if asset.mediaType == .video{
                model.phasset = asset
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                    // The cell may have been recycled by the time this handler gets called;
                    // set the cell's thumbnail image only if it's still showing the same asset.
                    if model.representedAssetIdentifier == asset.localIdentifier {
                        model.thumImage = image
                        model.duration = asset.duration
                        model.pixelWidth = asset.pixelWidth
                        model.pixelHeight = asset.pixelHeight
                        model.creationDate = asset.creationDate
                        videos.append(model)
                        
                    }
                })

            }
        }
        
        return videos
    }
    
    /**
     回调方法使用数组
     
     @param asset       照片实体
     @param complection 回调方法
     */
    func getImageObject(asset:AnyObject,complection:@escaping (_ :UIImage,_ :NSURL)->()) -> () {
        if asset is PHAsset {
            let phasset = asset as? PHAsset
            let photoWidth = UIScreen.main.bounds.size.width
            
            var screenScale:CGFloat = 2.0
            if photoWidth > 700 {
                screenScale = 1.5
            }
            let aspectRatio = CGFloat((phasset?.pixelWidth)!) / CGFloat((phasset?.pixelHeight)!)
            let pixelWidth = photoWidth * screenScale;
            let pixelHeight = pixelWidth / aspectRatio;
            let imageSize = CGSize(width: pixelWidth, height: pixelHeight);
            let option = PHImageRequestOptions()
            option.resizeMode = PHImageRequestOptionsResizeMode.fast
            
            
            PHImageManager.default().requestImage(for:phasset!, targetSize: imageSize, contentMode: PHImageContentMode.aspectFit, options: option, resultHandler: { (image, info) in
                let cancel:Bool? = info?[PHImageCancelledKey] as? Bool
                let error:NSError? = info?[PHImageErrorKey] as? NSError
                let result:Bool? = info?[PHImageResultIsDegradedKey] as? Bool
//                print(cancel)
//                print(error)
//                print(result)
                let downloadFinined:Bool = (cancel == nil && result == false && error==nil)
                let newimage = self.fixOrientation(image:image!)
                if(downloadFinined){
                    let imageUrl = info?["PHImageFileURLKey"] as! NSURL
                    complection(newimage!,imageUrl)
                }
            })
        }
    }
    /**
     检测是否为iCloud资源
     
     @param asset 照片实体
     
     @return 是否
     */
    func checkIsiCloudAsset(asset:PHAsset) -> Bool {
        let photoWidth = UIScreen.main.bounds.size.width
        let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let multiple = UIScreen.main.scale
        let pixelWith = photoWidth * multiple
        let pixeHeight = pixelWith / aspectRatio
        
        let options:PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.fast
        options.isSynchronous = true
        var isICloudAsset:Bool = false
        
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: pixelWith, height: pixeHeight), contentMode: PHImageContentMode.aspectFit, options: options) { (image, info) in
            
            let result:Bool = info![PHImageResultIsInCloudKey] as! Bool
            if(result == true){
                isICloudAsset = true
            }
        }
        return isICloudAsset
    }
    
    func fixOrientation(image:UIImage) -> UIImage? {
        if image.imageOrientation == UIImageOrientation.up{
            return image
        }
        let transform = CGAffineTransform.identity
        switch image.imageOrientation {
            
        case UIImageOrientation.down: fallthrough
        case UIImageOrientation.downMirrored:
            transform.translatedBy(x: image.size.width , y: image.size.height)
            transform.rotated(by: CGFloat(M_PI))
            
        case UIImageOrientation.left: fallthrough
        case UIImageOrientation.leftMirrored:
            transform.translatedBy(x: image.size.width,y: 0)
            transform.rotated(by: CGFloat(M_PI_2))
            
        case UIImageOrientation.right: fallthrough
        case UIImageOrientation.rightMirrored:
            transform.translatedBy(x: 0,y: image.size.height)
            transform.rotated(by: CGFloat(-M_PI_2))
            
        default: break
            
        }
        
        switch image.imageOrientation {
        case UIImageOrientation.upMirrored: fallthrough
        case UIImageOrientation.downMirrored:
            transform.translatedBy(x: image.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case UIImageOrientation.leftMirrored: fallthrough
        case UIImageOrientation.rightMirrored:
            transform.translatedBy(x: image.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        default: break
        }
        
        let ctx = CGContext.init(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent:(image.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space:(image.cgImage?.colorSpace)! , bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        switch image.imageOrientation {
        case UIImageOrientation.left:fallthrough
        case UIImageOrientation.leftMirrored: fallthrough
        case UIImageOrientation.right: fallthrough
        case UIImageOrientation.rightMirrored:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width:image.size.height, height: image.size.width))
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width:image.size.width, height: image.size.height))
        }
        let iamgeRef = ctx?.makeImage()
        let imagenew = UIImage(cgImage:iamgeRef!)
        return imagenew
    }
    

}
