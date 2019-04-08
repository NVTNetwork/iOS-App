//
//  AppDelegate.swift
//  NVT
//
//  Created by Emilio Marin on 15/4/18.
//  Copyright © 2018 Emilio Marin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
      /*  let configuration = ParseClientConfiguration {
            $0.applicationId = "p8SE2MvubSdkiJ7XGfcC7CJf9nvtOwpfd9OyjOwn"
            $0.clientKey = "aihUYyIj1otvvxG7K4uowQpqrV0UDxVj7Nu4NVAy"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
*/
        
        firstTime()

        UINavigationBar.appearance().tintColor = UIColor.white

        return true
    }
    
    func firstTime(){
        
        let wallet = UserDefaults.standard.string(forKey: "Wallet")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (wallet != nil) {
            let vc = storyboard.instantiateViewController(withIdentifier: "NavigationVC")
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }else {
            
            let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeVC")
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }
    






}

