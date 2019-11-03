//
//  InitialVC.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/19/19.
//

import UIKit
class InitialVC: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If this is not the first time opening app
        if InitialVC.isKeyPresentInUserDefaults(key: "firstOpen"){
            InitialVC.goTo("MainNavVC", animate: true)
        }else{
             InitialVC.goTo("CongestionVC", animate: true)
        }
       
    }
    
  

    
    //Help Direct Initial VC to Navigation Controller
    static func goTo(_ view: String, animate: Bool){
        OperationQueue.main.addOperation {
            func topMostController() -> UIViewController {
                var topController: UIViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController!
                while (topController.presentedViewController != nil) {
                    topController = topController.presentedViewController!
                }
                return topController
            }
            if let second = topMostController().storyboard?.instantiateViewController(withIdentifier: view) {
                topMostController().present(second, animated: animate, completion: nil)
                // topMostController().navigationController?.pushViewController(second, animated: animate)
                
            }
        }
    }
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
