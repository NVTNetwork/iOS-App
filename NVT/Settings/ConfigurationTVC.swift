//
//  ConfigurationTVC.swift
//  NVT
//
//  Created by Emilio Marin on 6/5/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit
import web3swift

class ConfigurationTVC: UITableViewController {

    var changeAddressView:ChangeAddress! = nil
    var popup: KLCPopup!
    var tokenView:AddTokenView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradientView = GradientView()
        gradientView.gradientLayer.colors = [mainTheme[0], mainTheme[1]]
        gradientView.gradientLayer.gradient = gradientDirection
        let bg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        bg.image = UIImage.init(named: "bg3.png")
        
        self.tableView.backgroundView = bg
        //self.tableView.backgroundView = gradientView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            if indexPath.row == 0{
//                Change User's ETH Address
                changeAddressView = UIView.fromNib(named: "ChangeAddress") as! ChangeAddress
                
                changeAddressView.center = self.view.center
                changeAddressView.layer.cornerRadius = 12.0
                changeAddressView.layer.masksToBounds = true
                changeAddressView.changeBtn.addTarget(self, action:#selector(changeAddressBtn(_:)), for: .touchUpInside)
                
                popup = KLCPopup.init(contentView: changeAddressView, showType: .bounceInFromLeft, dismissType: .bounceOutToRight, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
                popup.show()
                
            }else{
    //            Add Custom Token
                tokenView = UIView.fromNib(named: "AddTokenView") as! AddTokenView
                tokenView.center = CGPoint(x: self.view.center.x, y: self.view.center.y-80)
                tokenView.layer.cornerRadius = 12.0
                tokenView.layer.masksToBounds = true
                tokenView.addTokenBtn.addTarget(self, action:#selector(addCustomToken(_:)), for: .touchUpInside)
                
                popup = KLCPopup.init(contentView: tokenView, showType: .bounceInFromLeft, dismissType: .bounceOutToRight, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
                popup.show()
            
        }
    }

}
    
    func dismiss() {
        popup.dismiss(true)
    }
    
    @objc func changeAddressBtn(_ button: UIButton) {
        
        var ethAddress = changeAddressView.ethTF.text!
        ethAddress = ethAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        if(EthereumAddress.init(ethAddress).isValid && ethAddress != ""){
            print("Eth address changed")
            UserDefaults.standard.set(ethAddress, forKey: "Wallet")

            let symbolArray = ["NVT"]
            let balanceArray = [0]
            let decimalArray = [18]
            let contractArray = ["0xfe7B915A0bAA0E79f85c5553266513F7C1c03Ed0"]
            let imageArray = [UIImage.init(named: "nvt.png")] as! [UIImage]
            let ETHBalance = 0.0
            
            //            let imageData = NSKeyedArchiver.archivedData(withRootObject: imageArray)
            
            UserDefaults.standard.set(symbolArray, forKey: "Symbol")
            UserDefaults.standard.set(balanceArray, forKey: "Balance")
            UserDefaults.standard.set(decimalArray, forKey: "Decimal")
            UserDefaults.standard.set(contractArray, forKey: "Contract")
            //            UserDefaults.standard.set(imageData, forKey: "Image")
            UserDefaults.standard.set(ETHBalance, forKey: "ETH")
            
            popup.dismiss(true)
            
            let alert = UIAlertController.init(title: "Your ETH Address has been changes", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(!EthereumAddress.init(ethAddress).isValid){

            let alert = UIAlertController.init(title: "Error", message: "The eth address is not valid, please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else{
            popup.dismiss(true)
            let alert = UIAlertController.init(title: "There was an error", message: "Make sure you input the address correctly and that the field is not empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @objc func addCustomToken(_ button: UIButton) {
        
        let contractAd = tokenView.contractTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let decimals = Int(tokenView.decimalTF.text!)!
        let symbol = tokenView.symbolTF.text!
        
        var symbolArray = UserDefaults.standard.array(forKey: "Symbol") as! [String]
        var decimalArray = UserDefaults.standard.array(forKey: "Decimal") as! [Int]
        var contractArray = UserDefaults.standard.array(forKey: "Contract") as! [String]
        var balanceArray = UserDefaults.standard.array(forKey: "Balance") as! [Double]

        if(EthereumAddress.init(contractAd).isValid && tokenView.contractTF.hasText && tokenView.decimalTF.hasText && tokenView.symbolTF.hasText ){
            
            symbolArray.append(symbol)
            decimalArray.append(decimals)
            contractArray.append(contractAd)
            balanceArray.append(0.0)
            
            UserDefaults.standard.set(symbolArray, forKey: "Symbol")
            UserDefaults.standard.set(decimalArray, forKey: "Decimal")
            UserDefaults.standard.set(contractArray, forKey: "Contract")
            UserDefaults.standard.set(balanceArray, forKey: "Balance")

            popup.dismiss(true)
            
            let alert = UIAlertController.init(title: "New token added", message: "Refresh the table to see your balance", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(!EthereumAddress.init(contractAd).isValid){
            
            let alert = UIAlertController.init(title: "Error", message: "The contract address is not valid, please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            
            let alert = UIAlertController.init(title: "Error", message: "You need to fill all fields to add a new token.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        
    }

}
