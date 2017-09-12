//
//  CustomHDView.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

let widthTag:Int = 111
let heightTag:Int = 222
let bitRateTag:Int = 333


class CustomHDView: UIView {

    typealias setCompressDetailDone = (_ detail:CompressDetail,_ isCancel:Bool) -> Void
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var widthSlider: HSSlider!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heightSlider: HSSlider!
    
    @IBOutlet weak var bitrateLabel: UILabel!
    @IBOutlet weak var bitrateSlider: HSSlider!
    
    fileprivate var doneSet:setCompressDetailDone!
    
    fileprivate var customCompressDetail:CompressDetail = CompressDetail()
    
    class func loadViewWithNib(viewFrame:CGRect) -> CustomHDView {
        let array = Bundle.main.loadNibNamed("CustomHDView", owner: self, options: nil)
        let  view = array?.first as! CustomHDView
        view.frame = viewFrame
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        
        doneBtn.layer.borderColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 1).cgColor
        doneBtn.layer.borderWidth = 2
        doneBtn.setTitle(COMPRESS_ok, for: .normal)
        
        cancelBtn.layer.borderColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 1).cgColor
        cancelBtn.layer.borderWidth = 2
        cancelBtn.setTitle(COMPRESS_cancel, for: .normal)
        
        setSubView()
    }
    
    func setSubView(){
        widthLabel.text = "\(COMPRESS_width):"
        widthSlider.minValue = 50
        widthSlider.maxValue = 2048
        widthSlider.setValue(value: 640)
        widthSlider.backLabel.text = "640"
        customCompressDetail.width = 640
        
        heightLabel.text = "\(COMPRESS_height):"
        heightSlider.minValue = 50
        heightSlider.maxValue = 2048
        heightSlider.setValue(value: 480)
        heightSlider.backLabel.text = "480"
        customCompressDetail.height = 480
        
        bitrateLabel.text = "\(COMPRESS_bitrate):"
//        bitrateLabel.adjustsFontSizeToFitWidth = true
        bitrateSlider.minValue = 50*1024
        bitrateSlider.maxValue = 10000*1024
        bitrateSlider.setValue(value: 2000*1024)
        bitrateSlider.backLabel.text = StringWithFileBitRateSize(size: 2000*1024)
        customCompressDetail.bitRate = 2000*1024
    }
    //MARK: - actions
    open func compressSetDetailDone(block:@escaping setCompressDetailDone) {
        doneSet = block
    }
    
    @IBAction func doneBtnClick(_ sender: UIButton) {
        doneSet(customCompressDetail,false)
        removeFromSuperview()
    }
    
    @IBAction func cancleBtnClick(_ sender: UIButton) {
        doneSet(CompressDetail(),true)
        removeFromSuperview()
    }
    
    @IBAction func sliderValueChanged(_ sender: HSSlider) {
        
        let value = Int(sender.getValue())
        switch sender.tag {
            case widthTag:
                customCompressDetail.width = value
                sender.backLabel.text = "\(value)"
            case heightTag:
                customCompressDetail.height = value
                sender.backLabel.text = "\(value)"
            case bitRateTag:
                customCompressDetail.bitRate = value
                let  str = StringWithFileBitRateSize(size: Float(value))
                sender.backLabel.text = "\(str)"
            default: break
        }
        
    }
    func StringWithFileBitRateSize(size:Float) -> String{
        var stringSize = ""
        if size < 1000 {
            stringSize = String(format: "%1lubps", size)
        }
        else {
            stringSize = String(format: "%.1fkbps", Double(size)/1024.0)
        }
//        else if size < 1000 * 1024 * 1024{
//            stringSize = String(format: "%.1fMbps", Double(size)/(1024.0*1024.0))
//        }
//        else {
//            stringSize = String(format: "%.1fGbps", Double(size)/(1024.0 * 1024.0 * 1024.0))
//        }
        return stringSize
    }
    deinit {
//        print("CustomHDView--\(#function)")
    }
    
}
