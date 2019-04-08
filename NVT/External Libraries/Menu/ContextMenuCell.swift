//
//  ContextMenuCell.swift
//  NVT
//
//  Created by Emilio Marin on 16/4/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit
import ContextMenu_iOS

class ContextMenuCell : UITableViewCell, YALContextMenuCell {
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func animatedIcon() ->  UIView{
        return self.menuImageView!;
    }
    
    func animatedContent() ->  UIView{
        return self.menuTitleLabel;
    }
    
}

