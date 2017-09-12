//
//  VideoChooseVC.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos

let SCREENWIDTH:CGFloat = UIScreen.main.bounds.size.width
let SCREENHEIGHT:CGFloat = UIScreen.main.bounds.size.height
let SPACING:CGFloat = 2.0
let VideoChooseCellID = "VideoChooseCell"
let popoverWidth = SCREENWIDTH - 12

class VideoChooseVC: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource ,VideoPlayerViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionBottom: NSLayoutConstraint!
    @IBOutlet weak var collectionTop: NSLayoutConstraint!
    fileprivate var isEdit = false
    fileprivate var editItem:UIBarButtonItem!
    fileprivate var compressItem:UIBarButtonItem!
    
    fileprivate var lastIndexPath:IndexPath? = nil
    fileprivate var viewModel:VideoChooseViewModel = VideoChooseViewModel()
    var playerView:VideoPlayerView?
    private lazy var selectArray:[TZAssetModel] = {
        return []
    }()
    fileprivate lazy var selectIndexPathArray:[IndexPath] = {
        return []
    }()
    
    private lazy var videoListView:VideoListView = {
        let listView = VideoListView(frame: CGRect(x: 0, y: 0, width: popoverWidth, height: SCREENHEIGHT/3))
        
        listView.backgroundColor = UIColor.orange
        return listView
    }()
    private lazy var popover:DXPopover = {
        let pop = DXPopover()
        pop.arrowSize = CGSize.zero;
        pop.maskType = .none;
        pop.applyShadow = false;
        
       return pop
    }()

    fileprivate var albumModel:TZAlbumModel?
    
    override func viewDidLoad() {
        
//        print(NSTemporaryDirectory())
        
        super.viewDidLoad()
    
        edgesForExtendedLayout = UIRectEdge(rawValue: UInt(0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(collectionViewReloadData), name: NSNotification.Name(rawValue: AssetChangedSuccssed_key), object: nil)
        chuShiHuaCollectionView()
        chuShuHuaNavi()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if playerView != nil{
            playerView?.playerPause()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
        
//        collectionView.layer.contents = stratchedNavibarImage?.cgImage
        DispatchQueue.global().async {
            self.clearTmpFolder()
        }
    }

    func collectionViewReloadData(){
        shouQiPlayerView()
        selectArray.removeAll()
        selectIndexPathArray.removeAll()
        viewModel.loadListModel(listModel: albumModel)
        collectionView.reloadData()
        videoListView.tableViewReloadData()
    }
    func chuShuHuaNavi(){
        let backImage = UIImage(named: "back")
        let backItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backBarItemClick))
        navigationItem.leftBarButtonItem = backItem
//        let deleteImage = UIImage(named: "delete")
        editItem = UIBarButtonItem(title: COMPRESS_Edit, style: .plain, target: self, action: #selector(editBarItemClick))
        
        //压缩
//        let nextImage = UIImage(named: "next")
        compressItem = UIBarButtonItem(title: COMPRESS_Compress, style: .plain, target: self, action: #selector(compressItemBtnClick))
        navigationItem.rightBarButtonItems = [compressItem,editItem]
        
        
    }
    func chuShiHuaCollectionView() -> () {
        weak var weakSelf = self
       
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = SPACING
        flowLayout.minimumInteritemSpacing = SPACING
        var lineItems:CGFloat = 4
        if UIDevice.current.userInterfaceIdiom == .pad {
            lineItems = 6
        }
        let itemsize:CGFloat = (SCREENWIDTH - (lineItems + 1)*SPACING) / lineItems
        flowLayout.itemSize = CGSize(width: itemsize, height: itemsize)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        //注册Cell
        collectionView.register(UINib(nibName: "VideoChooseCell", bundle: nil), forCellWithReuseIdentifier: VideoChooseCellID)
        collectionView.backgroundColor = back_Color
        self.view.backgroundColor = back_Color
        TZImageManager.shareInstance().getAllAlbums(true, allowPickingImage: false) { (result:[TZAlbumModel]?) in
            if result != nil {
                weakSelf?.albumModel = result?.first
                DispatchQueue.main.async {
                    let titleBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
                    titleBtn.setTitle(weakSelf?.albumModel?.name, for: .normal)
                    titleBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                    let downImage = UIImage(named: "down")
                    titleBtn.setImage(downImage, for: .normal)
                    titleBtn.setButtonTitlePosition(position: .left)
                    titleBtn.addTarget(self, action: #selector(weakSelf?.videoListPopover(sender:)), for: .touchUpInside)
                    weakSelf?.navigationItem.titleView = titleBtn
                    weakSelf?.collectionViewReloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - guanggao
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        collectionBottom.constant = contentInsets.bottom
    }
    //MARK: - actions

    func backBarItemClick(){
        
        shouQiPlayerView()
        dismiss(animated: true, completion: nil)
    }
    
    func compressItemBtnClick() {
        if selectArray.count == 0{
            let alertContr = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_selectItems, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (action) in
                return;
            }
            alertContr.addAction(action)
            present(alertContr, animated: true, completion: nil)
        }
        if isEdit {
            isEdit = false
            viewModel.changeModelToEdit(isEdit: isEdit)
            collectionView.reloadData()
            editItem.title = COMPRESS_Edit
            compressItem.title = COMPRESS_Compress
            selectArray.removeAll()
            selectIndexPathArray.removeAll()
        }else{
            viewModel.getModelBirteAndSize(models: selectArray)
//        let compressVC = CompressViewController(nibName: "CompressViewController", bundle: Bundle.main)
//        compressVC.videoArray =  selectArray
            let compressVC = SingleCompressViewController(nibName: "SingleCompressViewController", bundle: Bundle.main)
            guard let model = selectArray.first else {
                return
            }
            compressVC.assetModel = model
            navigationController?.pushViewController(compressVC, animated: true)
        }

    }
    
    func editBarItemClick(){
        isEdit = !isEdit
        viewModel.changeModelToEdit(isEdit: isEdit)
        collectionView.reloadData()
        if isEdit == true {
            editItem.title = COMPRESS_Delete
            compressItem.title = COMPRESS_Done
        }else{
            editItem.title = COMPRESS_Edit
            compressItem.title = COMPRESS_Compress
            deleteVideos()
        }
//        if selectArray.count == 0{
//            let alertContr = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_selectItems, preferredStyle: UIAlertControllerStyle.alert)
//            let action = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (action) in
//                return;
//            }
//            alertContr.addAction(action)
//            present(alertContr, animated: true, completion: nil)
//        }
        
    }
    
    fileprivate func deleteVideos(){
        weak var weakSelf = self
        let completion = { (success: Bool, error: Error?) -> () in
            if success {
                DispatchQueue.main.async {
                    let alertContr = UIAlertController(title: COMPRESS_prompt, message: COMPRESS_deletedPrompt, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: COMPRESS_ok, style: UIAlertActionStyle.default) { (action) in
                        weakSelf?.viewModel.deleteModels(models: (weakSelf?.selectArray)!)
                        weakSelf?.selectArray.removeAll()
                        weakSelf?.selectIndexPathArray.removeAll()
                        weakSelf?.collectionView.reloadData()
                        weakSelf?.videoListView.tableViewReloadData()
                        weakSelf?.shouQiPlayerView()
                    }
                    alertContr.addAction(action)
                    weakSelf?.present(alertContr, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let hud = MBProgressHUD.showAdded(to: (weakSelf?.view)!, animated: true)
                    hud.mode = .text
                    hud.label.text = COMPRESS_deletedFaild
                    hud.label.numberOfLines = 10
                    hud.detailsLabel.text = COMPRESS_deleteFiledDetail
                    hud.detailsLabel.numberOfLines = 10
                    hud.hide(animated: true, afterDelay: 2.0)
                }
            }
        }
        
        var assetArray:[PHAsset] = []
        for model in selectArray {
            assetArray.append(model.asset as! PHAsset)
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetArray as NSArray)
            }, completionHandler: completion)

    }
    //MARK: - 相册选则
    func videoListPopover(sender:UIButton) -> () {
        
        if sender.isSelected == false{
            sender.isSelected = true
            let upImage = UIImage(named: "up")
            sender.setImage(upImage, for: .normal)
            weak var wealSelf = self
            videoListView.didselecList { (index, modelll) -> Void in
                guard let model = modelll else {
                    return
                }
                DispatchQueue.main.async {
                    let  titleBtn = wealSelf?.navigationItem.titleView as! UIButton
                    titleBtn.setTitle(model.name, for: .normal)
                    let downImage = UIImage(named: "down")
                    titleBtn.setImage(downImage, for: .normal)
                    sender.isSelected = false
                    titleBtn.setButtonTitlePosition(position: .left)
                    wealSelf?.collectionView.isUserInteractionEnabled = true
                    wealSelf?.popover.dismiss()
                    wealSelf?.albumModel = model
                    wealSelf?.collectionViewReloadData()
                }
                
            }
            updateListViewFrame()
            let startPoint = CGPoint(x: SCREENWIDTH/2, y:0)
            collectionView.isUserInteractionEnabled = false
            popover.show(at: startPoint, popoverPostion: DXPopoverPosition.down, withContentView: videoListView, in: view)
        }else{
            sender.isSelected = false
            let downImage = UIImage(named: "down")
            sender.setImage(downImage, for: .normal)
            collectionView.isUserInteractionEnabled = true
            popover.dismiss()
        }

    }
    
    func updateListViewFrame(){
        var listViewFrame = videoListView.frame
        listViewFrame.size.width = popoverWidth
        videoListView.frame = listViewFrame
        popover.backgroundColor = UIColor.darkGray
        popover.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    // MARK: - UICollectionViewDelegate,UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoChooseCellID, for: indexPath) as? VideoChooseCell
        if cell == nil {
            let array:Array = Bundle.main.loadNibNamed("VideoChooseCell", owner: nil, options: nil)!
            cell = array.first as? VideoChooseCell
        }
        weak var weakSelf = self
        cell?.selectBlock = {
            () -> Void in
            weakSelf?.selectPhotoAtIndex(at: indexPath)
        }
        let model = viewModel.getAssetModel(at: indexPath)
        
        cell?.loadVideoData(videoAsset: model!)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = viewModel.getAssetModel(at: indexPath) else {
            return
        }
        if playerView == nil {
            playerView = VideoPlayerView(frame: CGRect(x: 0,
                                                       y: -SCREENHEIGHT/5*2,
                                                       width: self.view.bounds.size.width,
                                                       height: SCREENHEIGHT/5*2))
            view.addSubview(playerView!)
            self.collectionTop.constant = SCREENHEIGHT/5*2
            UIView.animate(withDuration: 0.3) {
                self.playerView?.frame = CGRect(x: 0,
                                                y: 0,
                                                width: self.view.bounds.size.width,
                                                height: SCREENHEIGHT/5*2)
                self.view.layoutIfNeeded()
            }
            playerView?.delegate = self
        }
        
        let avasset = model.avAsset
        playerView?.playWithAVAsset(avasset: avasset!)
        if isEdit == false{
            if self.lastIndexPath == indexPath {
                return
            }
            for model in selectArray {
                model.isEdit = false
                model.isSelected = false
            }
            for index in selectIndexPathArray {
                let cell = collectionView.cellForItem(at: index) as! VideoChooseCell
                cell.isSelect = false
            }
            selectArray.removeAll()
            selectIndexPathArray.removeAll()
            selectPhotoAtIndex(at: indexPath)
            self.lastIndexPath = indexPath;
            
            selectIndexPathArray.append(indexPath)
        }
        
    }
    
    func shouQiPlayerView() {
        
        guard let playerViewC = playerView else {
            return;
        }
        collectionTop.constant = 0
        UIView.animate(withDuration: 0.3, animations: { 
            playerViewC.frame = CGRect(x: 0,
                                       y: -SCREENHEIGHT/5*2,
                                       width: self.view.bounds.size.width,
                                       height: SCREENHEIGHT/5*2)
            self.view.layoutIfNeeded()
            }) { (_) in
                playerViewC.removeFromSuperview()
                self.playerView = nil
        }
        
    }
    //MARK:关键位置，选中的在数组中添加，取消的从数组中减少
    func selectPhotoAtIndex(at indexPath:IndexPath) -> () {
        
        guard let model = viewModel.getAssetModel(at: indexPath) else {
            return
        }
        model.compressDetail.width = model.pixelWidth
        model.compressDetail.height = model.pixelHeight
        model.compressDetail.bitRate = Int(model.bitrate)
        
        if model.isSelected == false {
            model.isSelected = true
            selectArray.append(model)
            selectIndexPathArray.append(indexPath)
        }else{
            model.isSelected = false
            if let index = selectArray.index(of: model){
                selectArray.remove(at: index)
            }
            if let i = selectIndexPathArray.index(of: indexPath) {
                selectIndexPathArray.remove(at: i)
            }
        }
        changeSelectButtonStateAtIndex(at: indexPath, assetModel: model)
        
    }
    
    func changeSelectButtonStateAtIndex(at indexPath:IndexPath,assetModel:TZAssetModel) -> () {
        if indexPath.row >= viewModel.numberOfItemsInSection(section: 0) {
            return
        }
        let cell:VideoChooseCell = collectionView.cellForItem(at: indexPath) as! VideoChooseCell
        cell.isSelect = assetModel.isSelected
    }
    deinit {
//        print("______")
        NotificationCenter.default.removeObserver(self)
    }
    fileprivate func clearTmpFolder() -> () {
        
        let tmpPath = getTmpFolder()
        var contents:[String] = []
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: tmpPath)
            
        } catch {
            
        }
        
        if contents.count > 0 {
            for fileName in contents {
                let filePath = tmpPath.appending(fileName)
                let isExist = FileManager.default.fileExists(atPath: filePath)
                if isExist {
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                    } catch  {
                        
                    }
                    
                }
            }
        }
        
    }
    
    fileprivate func getTmpFolder() -> String {
        let tmp = NSTemporaryDirectory()
        return tmp
    }
}

