//
//  AddTokenView.swift
//  NVT
//
//  Created by Emilio Marin on 6/5/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit


extension UIView {
    class func fromNib<T: UIView>(named: String) -> T {
        return Bundle.main.loadNibNamed(named, owner: nil, options: nil)![0] as! T
    }
}

class AddTokenView: UIView {

    @IBOutlet weak var contractTF: UITextField!
    @IBOutlet weak var symbolTF: UITextField!
    @IBOutlet weak var decimalTF: UITextField!
    @IBOutlet weak var addTokenBtn: UIButton!


  
    
}
