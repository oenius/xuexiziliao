//
//  VideoPlayerView.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/16.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
protocol VideoPlayerViewDelegate {
    func shouQiPlayerView()->Void
}
class VideoPlayerView: UIView {

    var delegate:VideoPlayerViewDelegate!
    
    //MARK:-私有属性
    fileprivate var playerView:UIView!
    var shouQiBtn:UIButton!
    fileprivate var totleTimeLabel:UILabel!
    fileprivate var showTheTimeLable:UILabel!
    fileprivate var playerLayer:AVPlayerLayer?
    fileprivate var progressView:UIProgressView!
    fileprivate var movieProgressSlider:UISlider!
    fileprivate var player:AVPlayer?
    fileprivate var bofangImageView:UIImageView?
    //    fileprivate var playerItem:AVPlayerItem!
    fileprivate var originalTime:String!
    fileprivate var isPlaying:Bool = false
    fileprivate var recordCurrentTime:Int = 0
    fileprivate var totalMovieDuration:TimeInterval = 0
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setupSubView()
    }
    
    fileprivate func setupSubView(){
        backgroundColor = UIColor.black
        
        playerView = UIView()
        addSubview(playerView)
        
        showTheTimeLable = UILabel()
        showTheTimeLable.text = "00:00"
        showTheTimeLable.textColor = UIColor.lightGray
        showTheTimeLable.textAlignment = .right
        showTheTimeLable.font = UIFont.systemFont(ofSize: 14)
        addSubview(showTheTimeLable)
        
        totleTimeLabel = UILabel()
        totleTimeLabel.text = "22:22"
        totleTimeLabel.textColor = UIColor.lightGray
        totleTimeLabel.textAlignment = .left
        totleTimeLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(totleTimeLabel)
        
        progressView = UIProgressView()
        progressView.progressTintColor = UIColor(white: 1, alpha: 0.2)
        progressView.trackTintColor = UIColor.clear
        progressView.setProgress(0, animated: false)
        addSubview(progressView)
        
        shouQiBtn = UIButton()
        shouQiBtn.setImage(UIImage(named: "videoUp"), for: .normal)
        shouQiBtn.addTarget(self, action: #selector(shouQiBtnClick), for: .touchUpInside)
        addSubview(shouQiBtn)
        
        movieProgressSlider = UISlider()
        movieProgressSlider.value = 0
        //        let thumImage = UIImage(named: "")
        //        movieProgressSlider.setThumbImage(thumImage, for: .normal)
        movieProgressSlider.thumbTintColor = UIColor.clear
        movieProgressSlider.minimumTrackTintColor = UIColor.darkGray
        movieProgressSlider.addTarget(self, action: #selector(sliderWillChange), for: .touchDown)
        movieProgressSlider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        movieProgressSlider.addTarget(self, action: #selector(sliderDidChange), for: .touchCancel)
        movieProgressSlider.addTarget(self, action: #selector(sliderDidChange), for: .touchUpInside)
        addSubview(movieProgressSlider)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(oneTap(sender:)))
        tap.numberOfTapsRequired = 1
        playerView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        var h = bounds.size.height/8
        h = h > 40 ? 40 : h
        shouQiBtn.frame = CGRect(x: bounds.size.width-h-10, y: 10, width: h, height:h)
//        shouQiBtn.center = CGPoint(x: bounds.size.width/2, y: bounds.size.width/16)
        shouQiBtn.imageView?.contentMode = .scaleAspectFit
        bofangImageView?.removeFromSuperview()
        bofangImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        bofangImageView?.image = UIImage(named: "bofang")
        bofangImageView?.contentMode = .scaleAspectFit
        bofangImageView?.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        bofangImageView?.isHidden = true
        addSubview(bofangImageView!)
        playerView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height/4*3)
        playerView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        movieProgressSlider.frame = CGRect(x: 0, y: 0, width: bounds.size.width*0.9, height: 40)
        movieProgressSlider.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height - 20)
        progressView.frame = CGRect(x: 0, y: 0, width: bounds.size.width*0.9, height: 40)
        progressView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height - 20)
        
        totleTimeLabel.frame = CGRect(x: bounds.size.width*0.9 - 50, y: bounds.size.height - 20, width: 50, height: 20)
        showTheTimeLable.frame = CGRect(x: bounds.size.width*0.9 - 50*2, y: bounds.size.height - 20, width: 50, height: 20)
        
        if playerLayer != nil{
            playerLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height/4*3)
        }
        
        
    }
    //MARK:-播放
    func playWithUrl(url:URL) {
        let asset = AVAsset(url: url)
        preparePlay(avasset: asset)
    }
    
    func playWithAVAsset(avasset:AVAsset) {
        preparePlay(avasset: avasset)
    }
    func playWithPHAsset(phasset:PHAsset) {
        PHImageManager.default().requestAVAsset(forVideo: phasset, options: nil) { (avasset, audioMix, _) in
            DispatchQueue.main.async(execute: {
                self.preparePlay(avasset: avasset!)
            })
        }
    }
    
    func preparePlay(avasset:AVAsset) {
        
//        print(avasset.preferredRate)
        let playerItem = AVPlayerItem(asset: avasset)
//        print(playerItem.preferredPeakBitRate)
//        print(playerItem.presentationSize)
//        print(playerItem.duration)
        if player != nil{
            stopPlay()
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height/4*3)
        playerView.layer.addSublayer(playerLayer!)
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(notification:)), name:.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    func stopPlay() {
        bofangImageView?.isHidden = false
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self)
        if player != nil{
//            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//            NotificationCenter.default.removeObserver(self)
            player?.pause()
            player?.rate = 0
            player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
            player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
            player?.replaceCurrentItem(with: nil)
            totalMovieDuration = 0
            player?.currentItem?.cancelPendingSeeks()
            player?.currentItem?.asset.cancelLoading()

            player = nil
        }
        if playerLayer != nil{
//            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//            NotificationCenter.default.removeObserver(self)
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
        }
        
    }
    func monitorPlayProgress() {
        
    }
    //MARK:-actions
    //收起
    func shouQiBtnClick(){
        if self.delegate != nil {
            self.stopPlay()
            self.delegate.shouQiPlayerView()
        }
    }
    //播放结束
    func moviePlayDidEnd(notification:Notification) {
        let currentTime = floor(Double(totalMovieDuration*0))
        let dragedCMTime = CMTimeMake(Int64(currentTime), 1)
        weak var weakSelf = self
        player?.seek(to: dragedCMTime) { (finish) in
            if finish {
                self.isPlaying = false
                weakSelf?.bofangImageView?.isHidden = false
                weakSelf?.player?.pause()
            }
        }
    }
    //单击暂停
    func oneTap(sender:UITapGestureRecognizer) {
        if isPlaying == true {
            isPlaying = false
            bofangImageView?.isHidden = false
            player?.pause()
        }else{
            isPlaying = true
            bofangImageView?.isHidden = true
            player?.play()
        }
    }
    
    func playerPause(){
        isPlaying = false
        bofangImageView?.isHidden = false
        player?.pause()
    }
    
    //快进
    func sliderValueChange() {
        let currentTime = floor(Double(totalMovieDuration) * Double(movieProgressSlider.value))
        let dragedCMTime = CMTimeMake(Int64(currentTime), 1)
        player?.seek(to: dragedCMTime) { (finish) in
//            if self.isPlaying == true {
//                self.player.play()
//            }
        }
    }
    func sliderWillChange() {
        player?.pause()
    }
    func sliderDidChange() {
        if bofangImageView != nil{
            bofangImageView?.isHidden = true
        }
        player?.play()
    }
    //MARK:监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let playerItme = object as! AVPlayerItem
            if playerItme.status == .readyToPlay {
                let totalTime = playerItme.duration
                totalMovieDuration = TimeInterval(totalTime.value)/TimeInterval(totalTime.timescale)
                let timeString = secondToTimeSting(time: totalMovieDuration)
                
                totleTimeLabel.text = "/\(timeString)"
                weak var weakSelf = self
                let weakTotalMovieDuration = CGFloat(totalMovieDuration);
                player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue:nil, using: { (cmtime) in
                    if weakSelf?.player == nil{
                        return
                    }
                    var currentTime = weakSelf?.player?.currentItem?.currentTime()
                    //转成秒数
                    if currentTime == nil {
                        currentTime = CMTimeMake(0, 0)
                    }
                    let currentPlayTime = CGFloat((currentTime?.value)!)/CGFloat((currentTime?.timescale)!);
                    let value = currentPlayTime/weakTotalMovieDuration
                    weakSelf?.movieProgressSlider.value = Float(value)
                    let showtime = weakSelf?.secondToTimeSting(time: TimeInterval(currentPlayTime))
                    weakSelf?.showTheTimeLable.text = showtime;
                })
//                playerLayer.frame = playerView.layer.bounds
                bofangImageView?.isHidden = true
                player?.play()
                isPlaying = true
            }else{
                stopPlay()
//                print("播放失败")
            }
        }
        if keyPath == "loadedTimeRanges" {
            let bufferTime = availableDuration()
            let durationTime = Float(CMTimeGetSeconds((player?.currentItem?.duration)!))
            progressView.setProgress(bufferTime/durationTime, animated: true)
        }
    }
    func availableDuration() -> Float {
        let loadedTimeRanges = player?.currentItem?.loadedTimeRanges
        if (loadedTimeRanges?.count)! > 0 {
            let timevalue = loadedTimeRanges?[0]
            let timeRange = timevalue?.timeRangeValue
            let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
            let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
            return Float(startSeconds+durationSeconds)
        }else{
            return 0
        }
    }
    func secondToTimeSting(time:TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970:time)
        let formatter = DateFormatter()
        if time/3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        }else{
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date as Date)
    }

    deinit {
    
        stopPlay()
         NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self)
        
    }
}
