//
//  ViewController.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/19/19.
//

import UIKit
class HomeVC: UIViewController {
    
    static var stationClicked = ""
    var stationInfoA : [StationData] = []
    var stationInfoB : [StationData] = []
    static var clickedStation : [StationData] = []
    var displayDict : [String : [StationData]] = [:]
    var searchingDict : [String : [StationData]] = [:]
    var settingsLabels = ["Change Congestion","Contact Us", "About Us"]
    var settingsImages = [UIImage(named: "congestionIcon"),UIImage(named: "contactIcon"),UIImage(named: "aboutIcon")]
    var menuShowing = false
    var isSheetCreated = false
    var searching = false
    var selectedAverage = "session"
    var stationWorking = true
    private let blackView = UIView()
    private let clearView = UIView()
    private var isStationCongested = false
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
        searchBar.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Hide sliding menu
        tableLeadingConstraint.constant = -238.0
        
        //Load JSON Data Files into arrays
        stationInfoA = loadStationData(name: stationAFileName)
        stationInfoB = loadStationData(name: stationBFileName)
        
        //This dict is used in feed, this is setting items in dict
        displayDict["A"] = stationInfoA
        displayDict["B"] = stationInfoB
//        selectedAverage = "daily"
        
        print("Congested Num Selected: \(UserDefaults.standard.integer(forKey: "congestNum"))")
        
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
            
            actionSheet.addAction(UIAlertAction(title: "Daily Average", style: .default, handler: { (_) in
                self.selectedAverage = "daily"
                self.collectionView.reloadData()
            }))
            actionSheet.addAction(UIAlertAction(title: "Monthly Average", style: .default, handler: { (_) in
                
                self.selectedAverage = "monthly"
                self.collectionView.reloadData()
            }))
                       
            actionSheet.addAction(UIAlertAction(title: "Session Average", style: .default, handler: { (_) in
                self.selectedAverage = "session"
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
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }){
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
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }){
            
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
                var topController: UIViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController!
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
        var monthYearArray = [String]() // mm/yy
        var monthDayYearArray = [String]() // mm/dd/yy
        var numDays = 0
        var numMonths = 0
        var carAverage = 0
        var spentAverage = 0.0
        var energyAverage = 0.0
        var durationAverage = 0

        
        for data in array{
            let monthDayYearItems = data.endDate.split(separator: "/")
            let monthYear = "\(monthDayYearItems[0])/\(monthDayYearItems[2])"
            let monthDayYear = "\(monthDayYearItems[0])/\(monthDayYearItems[1])/\(monthDayYearItems[2])"
            //If daily average then calculate number of days
            if typeAverage == "daily"{
                if(!monthDayYearArray.contains(monthDayYear)){
                    numDays += 1
                    monthDayYearArray.append(monthDayYear)
//                    print(monthDayYear)
                }

            }else if typeAverage == "monthly"{
                if(!monthYearArray.contains(monthYear)) {
                    numMonths += 1
                    monthYearArray.append(monthYear)
                }
            }
            
            carAverage += 1
            spentAverage += data.dollarAmount
            energyAverage += data.energy
            durationAverage += data.duration
        }
        

        //Used to check that there are no duplicates
//        print(monthYearArray)
//        print("MONTHS \(numMonths)")

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
            carAverage = 0
            
            //If daily duration is greater or equal to the selected congestedNum
            //Then station is congested
            if(secondsToMinutes(seconds: durationAverage) >= UserDefaults.standard.integer(forKey: "congestNum")){
                isStationCongested = true
            }
            
        }
        
        spentAverage = spentAverage.rounded(toPlaces: 2)
        energyAverage = energyAverage.rounded(toPlaces: 2)
        
        
        output = ["\(typeAverage.capitalizingFirstLetter()) Average",String(carAverage),String(spentAverage),String(energyAverage),String(durationAverage)]
        return output
    }
    func secondsToHoursMinutes (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }
    
    func secondsToMinutes(seconds: Int) ->(Int){
        return ((seconds % 3600) / 60)
    }
    
    //Push alert to user
    static func alert(message: String, title: String = "", actionType: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        HomeVC.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    //Find top view controller
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
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
        if searching{return searchingDict.count}
        else{return displayDict.count}
    }
    
    //Cell properties
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StationCollectionViewCell
        var averageData : [String] = []
        
        //if searching use searchingStations array
        if searching{
//            print("BEEP")
            cell.stationId.text = "Station ID: \(Array(searchingDict.keys)[indexPath.row])"
            if selectedAverage == "session"{
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "session")
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "daily")
            }else{ //monthly
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "monthly")
            }
            
            //elseuse stations array
        }else{
            cell.stationId.text = "Station ID: \(Array(displayDict.keys)[indexPath.row])"
            if selectedAverage == "session"{
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row] , typeAverage: "session")
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row], typeAverage: "daily")
            }else{ //monthly
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row], typeAverage: "monthly")
            }
        }
        //time.0 = hours, time.1 = min
        let time = secondsToHoursMinutes(seconds: Int(averageData[4]) ?? -1)
        
        
        
        cell.stationImage.image = UIImage(named: "evStation.png")
        cell.averageTitle.text = averageData[0]
        if averageData[1] == "0" {cell.averageCars.text = ""} //print nothing if empty
        else{cell.averageCars.text = "\(averageData[1]) cars"}
        cell.averageSpent.text = "$\(averageData[2])"
        cell.averageEnergy.text = "\(averageData[3]) kWh"
        cell.averageDuration.text = "\(time.0):\(time.1)"
        
        
        if stationWorking && isStationCongested{
            cell.stationStatus.textColor = UIColor.yellow
            cell.stationStatus.text = "Status: Congested"
        }else if stationWorking{
            cell.stationStatus.textColor = UIColor.green
            cell.stationStatus.text = "Status: Working"
        }
        else{//station not working
            cell.stationStatus.textColor = UIColor.red
            cell.stationStatus.text = "Status: Down"
        }
        isStationCongested = false //reset
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.endEditing(true) //when a cell is clicked hide keyboard
        if searching{
            
            //Display station name
            HomeVC.stationClicked = "Station: \(Array(searchingDict.keys)[indexPath.row])"
            
            //Store clicked station to use on DeatailVC
            HomeVC.clickedStation = Array(searchingDict.values)[indexPath.row]
            
        }else{
            HomeVC.stationClicked = "Station: \(Array(displayDict.keys)[indexPath.row])"
            HomeVC.clickedStation = Array(displayDict.values)[indexPath.row]
            
        }
        
        navGoTo("DetailVC", animate: true)
    }
    
    
}

//Table view -> This is sliding settings menu
extension HomeVC: UITableViewDelegate,UITableViewDataSource{
    
    //number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsLabels.count
    }
    
    //Cell Properties
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.image = settingsImages[indexPath.row]
        cell.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.5921568627, blue: 0.3019607843, alpha: 1)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel?.text = settingsLabels[indexPath.row]
        return cell
    }
    
    //Clicked on settings button
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settingsLabels[indexPath.row] {
        case "Change Congestion":
            navGoTo("CongestionVC", animate: true)
            print("Pressed Change Congestion")
        case "Contact Us":
            AboutVC.loadWebsite(url: "https://www.zachsapps.com/contact")
            print("Pressed Contact Us")
        case "About Us":
            navGoTo("AboutVC", animate: true)
            print("Pressed About Us")
        default:
            print(-1)
            
        }
        
        //Close menu
        isMenuShowing()

    }
    
}
extension HomeVC: UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("BEEP")
        searching = false
        searchBar.endEditing(true) // gets rid of keyboard
        searchBar.text = ""
        collectionView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {        
        //Filer based on search results
        searchingDict = displayDict.filter({$0.key.lowercased().prefix(searchText.count) == searchText.lowercased()})
//        print("SEARCH \(searchingDict.count)")
        searching = true
        collectionView.reloadData()
    }
    
}

