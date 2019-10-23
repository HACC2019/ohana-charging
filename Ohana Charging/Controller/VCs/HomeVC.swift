//
//  ViewController.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/19/19.
//

import UIKit
class HomeVC: UIViewController {
    
    var stationInfoA : [StationData] = []
    var stationInfoB : [StationData] = []
    var settingsLabels = ["Contact Us", "About Us"]
    var menuShowing = false
    private let blackView = UIView()
    private let clearView = UIView()

    let stationAFileName = "stationA.json"
    let stationBFileName = "stationB.json"
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableLeadingConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        tableLeadingConstraint.constant = -238.0
        
//        loadStationA()
//        print(stationInfoA[0].id)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View is gone")
        removeClearView()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("View is back")
        createClearView()
    }
    
    
    @IBAction func optionsPressed(_ sender: Any) {
        print("Options Pressed")
        isMenuShowing()
    }
    
    
    @IBAction func refreshPressed(_ sender: Any) {
        print("Refresh Pressed")
    }
    
    private func createClearView(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(isMenuShowing))

        //Create swipe left gesture
        swipeRight.direction = .right
        
        //Get current window
        if let window = UIApplication.shared.keyWindow{
            clearView.backgroundColor = UIColor.clear
            self.clearView.addGestureRecognizer(swipeRight)
            window.addSubview(clearView)
            clearView.frame = CGRect(x: (window.frame.origin.x), y: (window.frame.origin.y), width: 30.0, height: window.frame.height)
        }
        
    }
    
    private func createBlackView(){
           let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(isMenuShowing))
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(isMenuShowing))
           //Get nav bar height
           let navBarHeight = self.navigationController?.navigationBar.frame.maxY ?? 0.0
           
           swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
           
           //Get current window
           if let window = UIApplication.shared.keyWindow{
               
               blackView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
               
               //Tap view and then dismiss it
               blackView.addGestureRecognizer(tapGesture)
               
               //Swipe right and dimiss it
               blackView.addGestureRecognizer(swipeLeft)

               window.addSubview(blackView)
               
               blackView.frame = CGRect(x: tableView.frame.width,
                                        y: 0.0 + navBarHeight,
                                        width: window.frame.width,
               
                                        height: window.frame.height)
               //Zero out
               blackView.alpha = 0
               
               //Animate back to alpha 1
               UIView.animate(withDuration: 0.2, animations:  {
                   self.blackView.alpha = 1
               })
           }
           
           
       }
    
    
    private func removeClearView(){
        self.clearView.removeFromSuperview()
        self.blackView.removeFromSuperview()
    }
    
    
    //Detemine constraints based on if menu is showing or not
    @objc private func isMenuShowing(){
          if menuShowing{
              self.blackView.alpha = 0
              tableLeadingConstraint.constant = -238.0
              optionsButton.image = UIImage(named: "optionButton.png")
              
              
          }else{
              tableLeadingConstraint.constant = 0.0
              optionsButton.image = UIImage(named: "closeButton.png")
              createBlackView()
          }
          UIView.animate(withDuration: 0.3, animations:{
              self.view.layoutIfNeeded()
          })
          menuShowing = !menuShowing
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
    
    func loadJSONData(_ name: String) -> Data?{
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch {
                print("Cannot load JSON Data:",name)
            }
        }
        return nil
    }
    
    func loadJSON(_ name: String) -> Any{
          if let data = loadJSONData(name){
              do {
                  return try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
              } catch {
                  print("Cannot read JSON:",name)
              }
          }
          return [:]
      }
    
    private func loadStationA(){
          let decoder = JSONDecoder()
          do {
              if let data = loadJSONData(stationAFileName){
                  let stationA = try decoder.decode([StationDataStruct].self, from: data)
                  for data in stationA{
                    stationInfoA.append(StationData(id: Int(data.id) ?? -1,
                                                    startDate: data.startDate, endDate: data.endDate,
                                                    duration: Int(data.duration) ?? -1,
                                                    energy: Double(data.energy) ?? -1,
                                                    dollarAmount: Double(data.dollarAmount) ?? -1,
                                                    portType: data.portType,
                                                    paymentMethod: data.paymentMethod))
                  }
              }
          } catch {
              print("ERROR LOADING JSON")
              print(error.localizedDescription)
          }
      }
   
}

//Collection View -> Showing the preview of the station data
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

//Table view -> This is sliding menu
extension HomeVC: UITableViewDelegate,UITableViewDataSource{
    
    //number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsLabels.count
    }
    
    //Cell Properties
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.5921568627, blue: 0.3019607843, alpha: 1)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel?.text = settingsLabels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settingsLabels[indexPath.row] {
        case "Contact Us":
            print("Pressed Contact Us")
        case "About Us":
            print("Pressed About Us")
        default:
            print(-1)
                
        }
    }
    
}

