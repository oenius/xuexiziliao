//
//  SFSSettingsViewController.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/1.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit



class SFSSettingsViewController: SettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(back))
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "202020", alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor(hexString: "e7e9e9")
    }

    func back() -> () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
