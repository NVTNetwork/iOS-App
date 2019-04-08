//
//  YALNavigationBar.swift
//  SwiftContextMenu
//
//  Created by tarek on 8/1/15.
//  Copyright (c) 2015 tarek. All rights reserved.
//

import UIKit

let defaultHeight : CGFloat = 45.0

class YALNavigationBar: UINavigationBar {


    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var amendedSize = super.sizeThatFits(size)
        amendedSize.height = defaultHeight
        return amendedSize;
    }




}

