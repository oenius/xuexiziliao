//
//  VideoChooseViewModel.swift
//  VideoCompress
//
//  Created by 何少博 on 17/4/10.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class VideoChooseViewModel: NSObject {
    
    fileprivate var imageManager = TZImageManager.shareInstance()
    fileprivate var assetModels:[TZAssetModel] = []
    override init() {
        super.init()
    }

    func loadListModel(listModel:TZAlbumModel?){
        weak var weakSelf = self
        if listModel == nil {
            imageManager?.getCameraRollAlbum(true, allowPickingImage: false, completion: { (albumModel) in
                
                weakSelf?.imageManager?.getAssetsFromFetchResult(albumModel?.result, allowPickingVideo: true, allowPickingImage: false, completion: { (completeModel:[TZAssetModel]?) in
                    guard let models = completeModel else{
                        return
                    }
                    weakSelf?.assetModels.removeAll()
                    weakSelf?.assetModels += models
                    weakSelf?.getAVAsset()
                })
                
            })
            
            return
        }
        
        
        imageManager?.getAssetsFromFetchResult(listModel?.result, allowPickingVideo: true, allowPickingImage: false, completion: { (completeModel:[TZAssetModel]?) in
            guard let models = completeModel else{
                return
            }
            weakSelf?.assetModels.removeAll()
            weakSelf?.assetModels += models
            weakSelf?.getAVAsset()
        })
    }
    func numberOfSections() -> Int {
        return 1
    }
    func numberOfItemsInSection(section: Int) -> Int {
        return assetModels.count
    }
    func getAssetModel(at indexPath:IndexPath) -> TZAssetModel? {
        if assetModels.count > indexPath.row{
            return assetModels[indexPath.row]
        }else{
            return nil
        }
    }
    func deleteModels(models:[TZAssetModel]) {
        for model_D in models {
            let index = assetModels.index(of: model_D)
            if let i = index {
                assetModels.remove(at: i)
            }
        }
    }
    
    func changeModelToEdit(isEdit:Bool) {
        for model in assetModels {
            model.isEdit = isEdit
            model.isSelected = false
        }
    }
    
    func getModelBirteAndSize(models:[TZAssetModel]) {
        for model in models {
            let tracks = model.avAsset.tracks
            var estimatedSize:Int64 = 0
            var bitRate:Float = 0.0
            for track in tracks{
                
                if AVMediaTypeVideo == track.mediaType   {
                    bitRate = track.estimatedDataRate
                }
                estimatedSize += track.totalSampleDataLength
            }
            model.fileSize = Int(estimatedSize)
            model.bitrate = CGFloat(bitRate)
        }
    }
    
    fileprivate func getAVAsset(){
        
        DispatchQueue.global().async {
            for model in self.assetModels {
                self.imageManager?.getVideoAssetBirteAndSize(model, completion: { (info) in
                 
//                    let bitrateNum = info?[kAssetBitrateKey] as? NSNumber
//                    model.bitrate = CGFloat((bitrateNum?.floatValue)!)
//                    let sizeNum = info?[kAssetFilesizeKey] as? NSNumber
//                    model.fileSize = (sizeNum?.intValue)!
                    model.avAsset = info?[kAssetAVAssetKey] as? AVAsset
                    
                })
            }
        }
       
    }
}
