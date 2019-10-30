//
//  AboutUsVC.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/29/19.
//

import UIKit

class AboutVC: UIViewController{
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func websitePressed(_ sender: Any) {
        openHACC()
    }
    
    func openHACC(){
        if Reachability.isConnectedToNetwork(){
            UIApplication.shared.open(URL(string: "http://hacc.hawaii.gov")!, options: [:], completionHandler: nil)
        }else{
            HomeVC.alert(message: "There is no internet connection. Please check your internet connection and try again.",
                         title: "Connection Error", actionType: .default)
        }
    }
}
