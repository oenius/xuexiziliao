//
//  VideoHDChooseViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

let cellID = "HDChooseCell"

protocol VideoChooseHDDelegate {
    func videoHDChoosed(compressDetail:CompressDetail)
}



class VideoHDChooseViewController: BaseViewController {

    var delegate:VideoChooseHDDelegate?
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate var dataArray:[HDChooseModel]!
    fileprivate var dicArray:NSMutableArray!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var costomBtn: UIButton!
    
    var compress_detail:CompressDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: UInt(0))
        costomBtn.layer.borderColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 1).cgColor
        costomBtn.layer.borderWidth = 2
        costomBtn.setTitle(COMPRESS_add, for: .normal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: COMPRESS_cancel, style: .plain, target: self, action: #selector(dismissSelf))
        
        let needShowAD = needsShowAdView()
        if needShowAD == true{
           interstitialButton = NPInterstitialButton(type: .icon, viewController: self)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: interstitialButton)
        }
        
        loadData()
        initTableView()
    }
    func dismissSelf()  {
        dismiss(animated: true, completion: nil)
    }
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        bottomConstraint.constant = contentInsets.bottom + 10
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    //MARK: - 初始化
    
    func initTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "VideoHDChooseCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    func loadData(){
        let user = UserDefaults.standard
        let tempdicarray = user.object(forKey: compress_detail_key) as! NSArray
        dicArray = NSMutableArray(array: tempdicarray)
//        let dicArray = NSArray(contentsOfFile: path!)
//        print(dicArray)
        var tempArray:[HDChooseModel] = []
        for dic  in dicArray {
            let model = HDChooseModel(dic: dic as! Dictionary<String, NSString>)
           tempArray.append(model)
        }
        dataArray = tempArray
    }
    //MARK: - actions
    @IBAction func costomBtnClick(_ sender: UIButton) {
        
        let contentView = UIView(frame: view.bounds)
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let frame = CGRect(x: 0, y: 0, width: view.bounds.size.width/4*3, height: view.bounds.size.height/4*3)
        let sucView = CustomHDView.loadViewWithNib(viewFrame: frame)
        sucView.layer.cornerRadius = 8
        sucView.layer.masksToBounds = true
        sucView.center = contentView.center
        contentView.addSubview(sucView)
        weak var weakSelf = self
        sucView.compressSetDetailDone { (detail,isCancel) in
            if isCancel == false{
                weakSelf?.compress_detail = detail
                contentView.removeFromSuperview()
//                print(detail)
                let user = UserDefaults.standard
                let arr = NSMutableArray(array: (weakSelf?.dicArray)!)
                let width = "\(detail.width)" as NSString
                let height = "\(detail.height)" as NSString
                let bitRate = "\(detail.bitRate)" as NSString
                let dic = NSDictionary(dictionary: ["width":width,"height":height,"bitRate":bitRate])
                arr.add(dic)
                user.set(arr, forKey: compress_detail_key)
                weakSelf?.dicArray = arr
                user.synchronize()
                //            weakSelf?.loadData()
                let model = HDChooseModel(dic: dic as! Dictionary<String, NSString>)
                weakSelf?.dataArray.append(model)
                weakSelf?.tableView.reloadData()
            }
            else{
                contentView.removeFromSuperview()
            }
        }
        view.addSubview(contentView)
    }
}
extension VideoHDChooseViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? VideoHDChooseCell
        if cell == nil {
            let array = Bundle.main.loadNibNamed("VideoHDChooseCell", owner: nil, options: nil)
            cell = array?.first as? VideoHDChooseCell
        }
        let model = dataArray[indexPath.row]
        cell?.model = model
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            var detail = CompressDetail()
            let model = dataArray[indexPath.row]
            detail.bitRate = (model.bitRate?.integerValue)!
            detail.width = (model.width?.integerValue)!
            detail.height = (model.height?.integerValue)!
            delegate?.videoHDChoosed(compressDetail: detail)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        dataArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        
        let user = UserDefaults.standard
        let arr = NSMutableArray(array: (dicArray)!)
        arr.removeObject(at: indexPath.row)
        user.set(arr, forKey: compress_detail_key)
        dicArray = arr
        user.synchronize()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
