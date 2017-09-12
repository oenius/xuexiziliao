//
//  VideoListView.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class VideoListView: UIView,UITableViewDelegate,UITableViewDataSource {
    typealias closure = ((_ index:Int,_ listModel:TZAlbumModel?)->Void)?
    private var didSelectClosure:closure?
    fileprivate var viewModel:ListViewModel = ListViewModel()

    private lazy var tableView:UITableView = {
        let tbv = UITableView()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.backgroundColor = back_Color
        return tbv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    func didselecList(select:closure) -> () {
        didSelectClosure = select
    }
    //Mark:-tableDelegate，Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "photoListCell") as? ListViewCell
        if cell == nil {
            cell = ListViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "photoListCell")
        }
        let  model = viewModel.getListModel(at: indexPath)
        cell?.loadPhotoListData(listModel: model)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let closure = didSelectClosure {
            let model = viewModel.getListModel(at: indexPath)
            closure!(indexPath.row,model)
        }
    }
    func tableViewReloadData() {
        viewModel.resetAlbums()
        weak var weakSelf = self;
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(1.0))) {
            weakSelf?.tableView.reloadData()
        }
    }
}
fileprivate class ListViewModel: NSObject {
    
    fileprivate var videoManager:TZImageManager = TZImageManager.shareInstance()
    fileprivate var albumArray:[TZAlbumModel] = []
    override init() {
        super.init()
        resetAlbums()
    }
    
    fileprivate func resetAlbums(){
        weak var weakSelf = self
        videoManager.getAllAlbums(true, allowPickingImage: false) { (result:[TZAlbumModel]?) in
            if result != nil{
                weakSelf?.albumArray = result!
            }
            
        }
    }
    
    
    fileprivate func numberOfSections() -> Int {
        return 1
    }
    fileprivate func numberOfRowsInSection(section:Int) -> Int{
        return albumArray.count
    }
    fileprivate func getListModel(at indexPath:IndexPath)-> TZAlbumModel?{
        if albumArray.count > indexPath.row {
            let model = albumArray[indexPath.row]
            return model
        }else{
            return nil
        }
    }
    
}
