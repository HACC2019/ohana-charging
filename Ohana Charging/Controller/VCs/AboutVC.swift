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
        loadWebsite(url: "http://hacc.hawaii.gov")
    }
    
    
}
