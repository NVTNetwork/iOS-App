//
//  ViewController.swift
//  NVT
//
//  Created by Emilio Marin on 15/4/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit
import BigInt
import web3swift
import Foundation
import SwiftyJSON
import ContextMenu_iOS
//import UICircularProgressRing
import SDWebImage

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}




class MainViewController: UITableViewController,YALContextMenuTableViewDelegate {

    var contractArray:[String]! = []
    var balanceArray:[Double]! = []
    var decimalArray:[Int]! = []
    var symbolArray:[String]! = []
    var imageArray: [UIImage]! = []
    
    var ETHBalance:Double!
    
    var web3Main:Web3!
    var jsonString: String!
    
    var menuTitles : [String]! = []
    var menuIcons : [UIImage]! = []
    var contextMenuTableView: YALContextMenuTableView?
    
    var collapsed:Bool = true
    
    var userWallet:Address!
    var logoURL = "https://raw.githubusercontent.com/TrustWallet/tokens/master/images/"
    
    var menuOpened: Bool = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tableView.backgroundView = GradientView.initialize()
        let gradientView = GradientView()
        gradientView.gradientLayer.colors = [mainTheme[0], mainTheme[1]]
        gradientView.gradientLayer.gradient = gradientDirection
        
        let bg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        bg.image = UIImage.init(named: "bg3.png")
        
        self.tableView.backgroundView = bg
        //self.tableView.backgroundView = gradientView
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        UITableView.appearance().tintColor = .white

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        
        web3Main = Web3(infura: .mainnet, accessToken: "plSGuekhC2kdQZi4guVe")
        
        let wallet = UserDefaults.standard.string(forKey: "Wallet")!
        userWallet = Address.init(wallet)
        
        if(UserDefaults.standard.object(forKey: "Symbol") == nil){
            symbolArray = ["NVT"]
            balanceArray = [0]
            decimalArray = [18]
            contractArray = ["0xb0dd7c86b9fb49a5a2377111d9b5eedef2f99880"]
            imageArray = [UIImage.init(named: "nvt.png")] as? [UIImage]
            ETHBalance = 0.0
            
            UserDefaults.standard.set(symbolArray, forKey: "Symbol")
            UserDefaults.standard.set(balanceArray, forKey: "Balance")
            UserDefaults.standard.set(decimalArray, forKey: "Decimal")
            UserDefaults.standard.set(contractArray, forKey: "Contract")
            UserDefaults.standard.set(ETHBalance, forKey: "ETH")
            
        }else{
            symbolArray = UserDefaults.standard.array(forKey: "Symbol") as? [String]
            balanceArray = UserDefaults.standard.array(forKey: "Balance") as? [Double]
            decimalArray = UserDefaults.standard.array(forKey: "Decimal") as? [Int]
            contractArray = UserDefaults.standard.array(forKey: "Contract") as? [String]
            
            ETHBalance = UserDefaults.standard.double(forKey: "ETH")
        }

        self.initiateMenuOptions()

        checkTokens(wallet: wallet)
        
        
        let refreshControl: UIRefreshControl! = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(MainViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = UIColor.red
            
            return refreshControl
        }()
        self.tableView.addSubview(refreshControl!)
        
        contextMenuTableView?.delegate = self
        contextMenuTableView?.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let wallet = UserDefaults.standard.string(forKey: "Wallet")!
        userWallet = Address.init(wallet)
        
        symbolArray = UserDefaults.standard.array(forKey: "Symbol") as? [String]
        balanceArray = UserDefaults.standard.array(forKey: "Balance") as? [Double]
        decimalArray = UserDefaults.standard.array(forKey: "Decimal") as? [Int]
        contractArray = UserDefaults.standard.array(forKey: "Contract") as? [String]
        
    }
    


  @objc  func handleRefresh(_ refreshControl: UIRefreshControl) {

    DispatchQueue.global(qos: .background).async {
        self.checkTokens(wallet: self.userWallet.address)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            refreshControl.endRefreshing()

        }

    }

    }
    
    func checkTokens(wallet:String){
        
        for i in 0...symbolArray.count-1 {
   
            var owned:Bool
            var balance: BigUInt
                
            (balance, owned) = checkBalance(contractAddress: contractArray[i], wallet: wallet)

            if(owned){
                balanceArray[i] = Double(balance /  BigUInt(10.0).power(decimalArray[i]))
            }else{
                balanceArray[i] = 0.0
            }
        }
        
//        Check ETH Balance
        do {
            let eth = try web3Main.eth.getBalance(address: Address.init(wallet))
            print("Balance of " + wallet + " = " + String(Double(eth) / Double(BigUInt(10).power(18))))
            ETHBalance = Double(eth) / Double(BigUInt(10).power(18))
            //        Save data and reload view
            UserDefaults.standard.set(ETHBalance!, forKey: "ETH")
            UserDefaults.standard.set(balanceArray, forKey: "Balance")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        } catch {
            //handle error
            print(error)
        }
        
    }


    
    func checkBalance(contractAddress:String, wallet:String) -> (BigUInt, Bool){
        
        var balance = BigUInt(0)
        var owned = false
        
        do{
            let gasPriceResult = try web3Main.eth.getGasPrice()
            var options = Web3Options()
            options.gasPrice = gasPriceResult
            options.from = Address(wallet)
            
            let contract = ERC20(Address(contractAddress))
            let balanceResult = try contract.balance(of: Address(wallet))
            print(balanceResult)
            
            balance = balanceResult
            
            if(balance != BigUInt(0)){
                owned = true
            }
            return (balance, owned)
        } catch{
            print(error)
            return (balance, owned)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    MARK: Table View Controller

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.contextMenuTableView != nil){
            return self.menuTitles.count
        }
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if(collapsed){
                return 0
            }else{
                return decimalArray.count - 1
            }
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.contextMenuTableView != nil){
            return 1
        }else{
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if (self.contextMenuTableView != nil){
        if (menuOpened){
            let t = tableView as! YALContextMenuTableView
            let cell = t.dequeueReusableCell(withIdentifier: "rotationCell", for:indexPath as IndexPath) as! ContextMenuCell
            
            cell.backgroundColor = UIColor.clear
            cell.menuTitleLabel.text = self.menuTitles![indexPath.row]
            cell.menuImageView.image = self.menuIcons![indexPath.row]
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as! TokenCell
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 9

        var numberString:String!
        
        switch indexPath.section {
        case 0:
            if(!symbolArray.isEmpty){
                cell.tokenImage.image = UIImage(named: "nvt.png")
                cell.tokenLabel.text! = symbolArray[0]
                
                numberString = String(balanceArray[0])
                cell.balanceLabel.text! = numberFormatter.string(from: NSNumber(value: Double(numberString)!))!
            }
        case 1:
                cell.tokenImage.image = UIImage(named: "eth.png")
                cell.tokenLabel.text! = "ETH"

//                numberString = String(ETHBalance)
                let eth = UserDefaults.standard.double(forKey: "ETH")
//                cell.balanceLabel.text! = numberFormatter.string(from: NSNumber(value: eth.rounded(toPlaces: 10)))!
                if(eth > 999){
                    cell.balanceLabel.text! = numberFormatter.string(from:NSNumber(value: eth.rounded(toPlaces: 9)))!

                }else{
                    cell.balanceLabel.text! = String(eth.rounded(toPlaces: 9))
                }
                cell.balanceLabel.textAlignment = .right

        case 2:
                if(!symbolArray.isEmpty){

                    let imageURL = URL(string: logoURL + contractArray[indexPath.row + 1] + ".png")
                    let placeholderImage = UIImage(named: "erc20.png")
                    cell.tokenImage.sd_setImage(with: imageURL, placeholderImage:placeholderImage)
                    cell.tokenLabel.text! = symbolArray[indexPath.row+1]
                
                    numberString = String(balanceArray[indexPath.row+1])
                    cell.balanceLabel.text! = numberFormatter.string(from: NSNumber(value: Double(numberString)!))!
            }
        default:
            cell.tokenImage.image = UIImage(named: "nvt.png")

        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.contextMenuTableView != nil){
            return 66
        }else{
            if indexPath.section == 0 {
                return 100
            }else{
                return 60
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        if (self.contextMenuTableView != nil){
            return nil
        }
        switch section
        {
        case 0:
            return "NVT"
        case 1:
            return "Ethereum"
        default:
            if(collapsed){
                return "Other ERC20 Tokens - Show more!"
            }else{
                return "Other ERC20 Tokens - Show less!"
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.contextMenuTableView != nil){
            let t = tableView as! YALContextMenuTableView
            t.dismis(with: indexPath as IndexPath?)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.frame = header.frame
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UITableViewHeaderFooterView()
        if(section == 2){
            ()
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            v.addGestureRecognizer(tapRecognizer)
        }else{
        }
        
        return v
    }
    
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        collapsed = !collapsed
        tableView.reloadData()
    }
    
    
    //    MARK: ContextMenu
    
    
    @IBAction func leftMenuButton(sender: UIBarButtonItem) {
        

            self.contextMenuTableView = YALContextMenuTableView(tableViewDelegateDataSource: self)
            self.contextMenuTableView!.animationDuration = 0.11;
            self.contextMenuTableView!.yalDelegate = self
            let cellNib = UINib(nibName: "ContextMenuCell", bundle: nil)
            self.contextMenuTableView?.register(cellNib, forCellReuseIdentifier: "rotationCell")

        menuOpened = true
        
        self.contextMenuTableView?.reloadData()
        self.contextMenuTableView?.show(in: self.navigationController!.view, with: .init(top: -40.0, left: 0.0, bottom: 0.0, right: 0.0), animated: true)
    }
    
    
    
    func contextMenuTableView(_ contextMenuTableView: YALContextMenuTableView!, didDismissWith indexPath: IndexPath!) {
        print("Menu dismissed with indexpath = \(String(describing: indexPath))")
        
        self.contextMenuTableView = nil
        menuOpened = false
        
    }
 
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.contextMenuTableView!.reloadData()
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration:duration)
        
        self.contextMenuTableView!.updateAlongsideRotation()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.contextMenuTableView!.reloadData()
        })
        
        self.contextMenuTableView!.updateAlongsideRotation()
    }

    func initiateMenuOptions() {
        self.menuTitles = ["",
                           "Telegram",
                           "Web",
                           "Twitter",
                           "BitcoinTalk",
                           "Github"]
        
        self.menuIcons = [UIImage(named: "Close")!,UIImage(named: "Telegram")!, UIImage(named: "Web")!, UIImage(named: "Twitter")!, UIImage(named: "BitcoinTalk")!, UIImage(named: "Github")!] 
        
    }
    
}

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


