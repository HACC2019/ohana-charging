//
//  Extensions.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/23/19.
//

import Foundation
import UIKit
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
}

extension UIViewController {
    func alert(message: String, title: String, actionType: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadWebsite(url: String){
        if Reachability.isConnectedToNetwork(){
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }else{
            alert(message: "There is no internet connection. Please check your internet connection and try again.", title:  "Connection Error", actionType: .default)
          
        }
    }
}

