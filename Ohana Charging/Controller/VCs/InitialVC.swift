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
        
        goTo("MainNavVC", animate: true)
    }
    

    
    //Help Direct Initial VC to Navigation Controller
    func goTo(_ view: String, animate: Bool){
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
}
