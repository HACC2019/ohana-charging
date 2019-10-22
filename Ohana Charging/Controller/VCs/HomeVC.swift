//
//  ViewController.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/19/19.
//

import UIKit
class HomeVC: UIViewController {
    
    let stations : [Station] = []
    let stationAFileName = "stationA.json"
    let stationBFileName = "stationB.json"
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

    }
    
    
    @IBAction func optionsPressed(_ sender: Any) {
        print("Options Pressed")
        
    }
    
    func navGoTo(_ view: String, animate: Bool){
            OperationQueue.main.addOperation {
                func topMostController() -> UIViewController {
                    var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                    while (topController.presentedViewController != nil) {
                        topController = topController.presentedViewController!
                    }
                    return topController
                }
                if let second = topMostController().storyboard?.instantiateViewController(withIdentifier: view) {
                    self.navigationController?.pushViewController(second, animated: animate)
    
                }
            }
        }
    

    
//    static func loadJSON(_ name: String) -> Any{
//          if let data = loadJSONData(name){
//              do {
//                  return try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//              } catch {
//                  print("Cannot read JSON:",name)
//              }
//          }
//          return [:]
//      }
//
//      private func loadHealthDict() -> Dictionary<String, String>{
//          return DictionaryVC.loadJSON(jsonFileName) as! Dictionary<String, String>
//      }
    

}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    //Cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: 411, height: 268)
    }
    
    //Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    //Cell properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StationCollectionViewCell
        cell.stationId.text = "Station ID: 1"
        cell.stationImage.image = UIImage(named: "goodBatteryIcon.png")
        cell.averageTitle.text = "Average"
        cell.averageCars.text = "100 cars"
        cell.averageEnergy.text = "50 kWh"
        cell.averageDuration.text = "100 Seconds"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navGoTo("DetailVC", animate: true)
    }
    
    
    
    
    
}

