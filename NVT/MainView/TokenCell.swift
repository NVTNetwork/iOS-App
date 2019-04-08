//
//  Tokenswift
//  NVT
//
//  Created by Emilio Marin on 15/4/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit

class TokenCell: UITableViewCell {

    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainBackground.layer.cornerRadius = 15
        mainBackground.layer.masksToBounds = true
        mainBackground.backgroundColor = .clear
        
        let gradient = GradientView()
        gradient.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        gradient.gradientLayer.colors = [cellTheme[0], cellTheme[1]]
        gradient.gradientLayer.gradient = gradientDirection

        mainBackground.addSubview(gradient)
        
        shadowLayer.layer.masksToBounds = false
        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.shadowOpacity = 0.23
        shadowLayer.layer.shadowRadius = 15
        
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        shadowLayer.layer.shouldRasterize = true
        shadowLayer.layer.rasterizationScale = UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
