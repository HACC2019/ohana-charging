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
        AboutVC.loadWebsite(url: "http://hacc.hawaii.gov")
    }
    
    static func loadWebsite(url: String){
        if Reachability.isConnectedToNetwork(){
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }else{
            HomeVC.alert(message: "There is no internet connection. Please check your internet connection and try again.",
                         title: "Connection Error", actionType: .default)
        }
    }
}
