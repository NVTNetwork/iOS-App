//
//  WelcomeVC.swift
//  NVT
//
//  Created by Emilio Marin on 30/4/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit
import BigInt
import web3swift
import Foundation
import SwiftyJSON




class WelcomeVC: UIViewController {

    @IBOutlet weak var walletTF: UITextField!
    
    @IBAction func verifyBtn(_ sender: Any) {
        let wallet = walletTF.text!

        var ethAddress:Address?
        
        if !wallet.isEmpty {
            ethAddress = Address.init(wallet)
            
            if (ethAddress?.isValid)! {
                UserDefaults.standard.set(wallet, forKey: "Wallet")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NavigationVC")
                self.show(vc, sender: self)
                UserDefaults.standard.synchronize()
                //        Create Id for new user
                UserDefaults.standard.set(randomAlphaNumericString(length: 10), forKey: "UserId")

            }else{
                let alert = UIAlertController.init(title: "There was an error", message: "Make sure your eth address is valid!", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
                self.show(alert, sender: self)
            }
        }else{
            let alert = UIAlertController.init(title: "There was an error", message: "This field can't be empty, paste your eth address!", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok!", style: .cancel, handler: nil))
            self.show(alert, sender: self)
        }
        
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //view.gradientLayer.colors = [UIColor.init(0x5F627D).cgColor, UIColor.init(0x313347).cgColor]
        view.gradientLayer.colors = [mainTheme[0], mainTheme[1]]
        view.gradientLayer.gradient = gradientDirection
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
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
