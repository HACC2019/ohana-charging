//
//  DetailVC.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//
import UIKit

class DetailVC: UIViewController {
    
    let sheet = UIAlertController(title: "Please select an option to see location of station",
                                  message: "Map Options",
                                  preferredStyle: .actionSheet)
    private var stationLatitude = 21.300676
    private var stationLongitude = -157.851767
    private var didOpenSheet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = HomeVC.stationClicked
        
    }
    
    @IBAction func mapPressed(_ sender: Any) {
        actionSheetMaps()
    }
    
    
    private func actionSheetMaps(){
        if !didOpenSheet{
            sheet.addAction(UIAlertAction(title: "Open Maps", style: .default, handler: { (_) in
                
                //Open Apple Maps
                self.openMaps(mapType: "Maps",
                              canOpenURL: "http://maps.apple.com/",
                              openURL: "http://maps.apple.com/maps?daddr=\(self.stationLatitude),\(self.stationLongitude)")
                
            }))
            sheet.addAction(UIAlertAction(title: "Open Google Maps", style: .default, handler: { (_) in
                //Open Google Maps
                self.openMaps(mapType: "Google Maps",
                              canOpenURL: "comgooglemaps://",
                              openURL: "comgooglemaps://?saddr=&daddr=\(self.stationLatitude),\(                self.stationLongitude)&directionsmode=driving")
                
            }))
            sheet.addAction(UIAlertAction(title: "Open Waze", style: .default, handler: { (_) in
                //Waze
                self.openMaps(mapType: "Waze",
                              canOpenURL: "waze://",
                              openURL: "https://www.waze.com/ul?ll=\(self.stationLatitude),\(self.stationLongitude)&navigate=yes")
                
            }))
            
            //close alert
            sheet.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                self.sheet.dismiss(animated: true, completion: nil)
                
            }))
            
            didOpenSheet = true
            
        }
        
        
        
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    private func openMaps(mapType: String,canOpenURL: String, openURL: String){
        //If can open url then open url else show alert saying user does not have app
        (UIApplication.shared.canOpenURL(URL(string:canOpenURL)!)) ? (UIApplication.shared.open(NSURL(string:
            openURL)! as URL)) : (HomeVC.alert(message: "\(mapType) is not installed on this phone.", title: "\(mapType) Unavailable", actionType: .default))
    }
    
    
    
    
    
}
