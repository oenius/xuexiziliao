//
//  CustomSettingsViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 16/12/4.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

class CustomSettingsViewController: SettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(dismisSelf))
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismisSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableViewCellTextColor() -> UIColor! {
        return UIColor.white
    }
    override func tableViewBackgroundColor() -> UIColor! {
        return back_Color
    }
    override func tableViewCellBackgroundColor() -> UIColor! {
        return back_Color
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
