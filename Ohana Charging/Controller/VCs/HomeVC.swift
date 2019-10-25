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
    var stations : [Any] = []
    var searchingStations : [Any] = []
    var settingsLabels = ["Contact Us", "About Us"]
    var menuShowing = false
    var isSheetCreated = false
    var searching = false
    var selectedAverage = "session"
    private let blackView = UIView()
    private let clearView = UIView()

    let stationAFileName = "stationA"
    let stationBFileName = "stationB"
    let actionSheet = UIAlertController(title: "Averaging Options",
    message: "Please select an averaging option to show",
    preferredStyle: .actionSheet)
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Hide sliding menu
        tableLeadingConstraint.constant = -238.0
        
        //Load JSON Data Files into arrays
        stationInfoA = loadStationData(name: stationAFileName)
        stationInfoB = loadStationData(name: stationBFileName)
        
        //This array is used in feed
        stations = [stationInfoA,stationInfoB]
//        print("HELLO: \(stationInfoA[0].dollarAmount)")
    
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
    
    @IBAction func avgPressed(_ sender: Any) {
        print("Average Button Pressed")
        presentSheet()
    }
    
    private func presentSheet(){
        if !isSheetCreated{
            actionSheet.addAction(UIAlertAction(title: "Session Average", style: .default, handler: { (_) in
                self.selectedAverage = "session"
                self.collectionView.reloadData()
            }))
            actionSheet.addAction(UIAlertAction(title: "Daily Average", style: .default, handler: { (_) in
                self.selectedAverage = "daily"
                self.collectionView.reloadData()
            }))
            actionSheet.addAction(UIAlertAction(title: "Monthly Average", style: .default, handler: { (_) in
                self.selectedAverage = "monthly"
                self.collectionView.reloadData()
            }))
            
            //close alert
            actionSheet.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                self.actionSheet.dismiss(animated: true, completion: nil)
            }))
            
            isSheetCreated = true //makes sure sheet is only created once
        }
        self.present(actionSheet, animated: true, completion: nil)
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
    
    //Loads json file into data array
    private func loadStationData(name: String) -> [StationData]{
        var dataArray : [StationData] = []
        let decoder = JSONDecoder()
        do {
            if let data = loadJSONData(name){
                let station = try decoder.decode([StationDataStruct].self, from: data)
                for data in station{
                dataArray.append(StationData(startDate: data.startDate,
                                                    startTime: data.startTime,
                                                    endDate: data.endDate,
                                                    endTime: data.endTime,
                                                    duration: Int(data.duration) ,
                                                    energy: Double(data.energy) ,
                                                    dollarAmount: Double(data.dollarAmount) ,
                                                    portType: data.portType,
                                                    paymentMethod: data.paymentMethod))
                }
            }
            return dataArray
        } catch {
            print("ERROR LOADING JSON: \(error)")
        }
        return dataArray
      }

    
    //Calculate type of average based on typeAverage
    //Return array = [averageType, carAverage,spentAvereage,energyAverage,durationAverage]
    private func calculateAverage(array: [StationData], typeAverage: String) -> [String]{
        var output : [String] = []
        var numDays = 0
        var numMonths = 0
        var carAverage = 0
        var spentAverage = 0.0
        var energyAverage = 0.0
        var durationAverage = 0
        var previousDay = (array[0].endDate.split(separator: "/"))[1]
        var previousMonth = (array[0].endDate.split(separator: "/"))[0]

           
        for data in array{
            
            //If daily average then calculate number of days
            if typeAverage == "daily"{
                let day = (data.endDate.split(separator: "/"))[1]
                if(previousDay != day) {
                    previousDay = day
                    numDays += 1
                }
            }else if typeAverage == "monthly"{
                let month = (data.endDate.split(separator: "/"))[0]
                if(previousMonth != month) {
                    previousMonth = month
                    numMonths += 1
                }
            }
            
            carAverage += 1
            spentAverage += data.dollarAmount
            energyAverage += data.energy
            durationAverage += data.duration
        }
        
        if typeAverage == "daily"{
            //Divide by total days to calc average
            carAverage /= numDays
            spentAverage /= Double(numDays)
            energyAverage /= Double(numDays)
            durationAverage /= numDays
        }else if typeAverage == "monthly"{
            //Divide by total months to calc average
            carAverage /= numMonths
            spentAverage /= Double(numMonths)
            energyAverage /= Double(numMonths)
            durationAverage /= numMonths
        }else{ //session average
            //Divide by total secessions to calc average
            spentAverage /= Double(array.count)
            energyAverage /= Double(array.count)
            durationAverage /= array.count
        }
       
        spentAverage = spentAverage.rounded(toPlaces: 2)
        energyAverage = energyAverage.rounded(toPlaces: 2)



        output = ["\(typeAverage.capitalizingFirstLetter()) Average",String(carAverage),String(spentAverage),String(energyAverage),String(durationAverage)]
        return output
    }
    func secondsToHoursMinutes (seconds : Int) -> (Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60)
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
        if searching{return searchingStations.count}
        else{return stations.count}
    }
    
    //Cell properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StationCollectionViewCell
        var averageData : [String] = []
    
        //if searching use searchingStations array
        if searching{
            if selectedAverage == "session"{
                averageData = calculateAverage(array: searchingStations[indexPath.row] as! [StationData], typeAverage: "session")
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: searchingStations[indexPath.row] as! [StationData], typeAverage: "daily")
            }else{ //monthly
                averageData = calculateAverage(array: searchingStations[indexPath.row] as! [StationData], typeAverage: "monthly")
            }
            
        //elseuse stations array
        }else{
            if selectedAverage == "session"{
                averageData = calculateAverage(array: stations[indexPath.row] as! [StationData], typeAverage: "session")
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: stations[indexPath.row] as! [StationData], typeAverage: "daily")
            }else{ //monthly
                averageData = calculateAverage(array: stations[indexPath.row] as! [StationData], typeAverage: "monthly")
            }
        }
        //time.0 = hours, time.1 = min
        let time = secondsToHoursMinutes(seconds: Int(averageData[4]) ?? -1)
                
        cell.stationId.text = "Station ID: \(indexPath.row + 1)"
        cell.stationImage.image = UIImage(named: "goodBatteryIcon.png")
        cell.averageTitle.text = averageData[0]
        if averageData[1].isEmpty {cell.averageCars.text = averageData[1]} //print nothing if empty
        else{cell.averageCars.text = "\(averageData[1]) cars"}
        cell.averageSpent.text = "$\(averageData[2])"
        cell.averageEnergy.text = "\(averageData[3]) kWh"
        cell.averageDuration.text = "\(time.0):\(time.1)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.endEditing(true) //when a cell is clicked hide keyboard
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
extension HomeVC: UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true) // gets rid of keyboard
        searchBar.text = ""
        collectionView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //no matter if user types in caps or not it will search thats why we force to lowercase
//        searchingStations = dictionary.filter({$0.key.lowercased().prefix(searchText.count) == searchText.lowercased()})
//        searchingStations = stations.filter({$0 == searchText})
        searching = true
        collectionView.reloadData()
    }
    
}

