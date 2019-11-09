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
    var addStationA : [StationData] = []
    var addStationB : [StationData] = []

    
    var limitedStationInfoA : [StationData] = [] //To simulate refresh data, only some of stationInfoA will be used
    var limitedStationInfoB : [StationData] = []//To simulate refresh data , only some of limitedStationInfoB will be used
    
    //These are calculated from java files
    private var calculatedWaitingA = 96 //In min, calcualted wait time that is considered "congested"
    private var calculatedWaitingB = 96 //In min, calcualted wait time that is considered "congested"

    
    static var clickedStation : [StationData] = []
    var displayDict : [String : [StationData]] = [:]
    var searchingDict : [String : [StationData]] = [:]
    static var stationStates = [1,1] // 0 - down, 1 - up, 2 - congested
    var settingsLabels = ["Change Congestion","Contact Us", "About Us"]
    var settingsImages = [UIImage(named: "congestionIcon"),UIImage(named: "contactIcon"),UIImage(named: "aboutIcon")]
    var menuShowing = false
    var isSheetCreated = false
    var addStationAIndex = 0
    var addStationBIndex = 0
    var showIndicator = false
    var numBadData = 0 //number of times bad data was seen
    var searching = false
    var selectedAverage = "session"
    private let blackView = UIView()
    private let clearView = UIView()
    let stationAFileName = "stationA"
    let stationBFileName = "stationB"
    let addStationAFile = "addStationA"
    let addStationBFile = "addStationB"

    let actionSheet = UIAlertController(title: "Averaging Options",
                                        message: "Please select an averaging option to show",
                                        preferredStyle: .actionSheet)
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
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
        indicator.isHidden = true
        //Hide sliding menu
        tableLeadingConstraint.constant = -238.0
    
        //Load JSON Data Files into arrays
        stationInfoA = loadStationData(name: stationAFileName)
        stationInfoB = loadStationData(name: stationBFileName)
        addStationA = loadStationData(name: addStationAFile)
        addStationB = loadStationData(name: addStationBFile)

        
        //This dict is used in feed, this is setting items in dict
        displayDict["A"] = stationInfoA
        displayDict["B"] = stationInfoB
//        selectedAverage = "daily"
        
        print("Congested Num Selected: \(UserDefaults.standard.integer(forKey: "congestNum"))")
        loadStationStates()
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
        loadIndicator()

        loadMoreData()//load more data into station A and B
        
        //Turn indicator off after n seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.loadIndicator()
        }
      
    }
    
    @IBAction func avgPressed(_ sender: Any) {
        print("Average Button Pressed")
        presentSheet()
    }
    
    func chartPressed(_ indexPath: IndexPath) {
        print("HELLLO")
        searchBar.endEditing(true) //when a chart button is clicked hide keyboard
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
    
    
    private func loadStationStates(){
        if isStationCongested(station: "a") {HomeVC.stationStates[0] = 2}
        else{
            if HomeVC.stationStates[0] != 0 {HomeVC.stationStates[0] = 1}
        }
        if isStationCongested(station: "b") {HomeVC.stationStates[1] = 2}
        else{
              if HomeVC.stationStates[1] != 0 {HomeVC.stationStates[1] = 1}
        }
    }
    //Loads one piece of data when refresh pressed to simulate the resfresh feature
    private func loadMoreData(){
        print(addStationA.count)
        print(addStationB.count)

        print(addStationAIndex)
        if((addStationAIndex >= addStationA.count) || (addStationBIndex >= addStationB.count)) { //show alert
            alert(message: "Data is current", title: "No Data Available for Station A", actionType: .default)
        }else{ //there is more data to add
            stationInfoA.append(addStationA[addStationAIndex])
            addStationAIndex += 1
            
            stationInfoB.append(addStationB[addStationBIndex])
            testStationDown(data: stationInfoB[stationInfoB.count - 1], stationID: "B")
            addStationBIndex += 1
        }
        //Update dictionary
        displayDict["A"] = stationInfoA
        displayDict["B"] = stationInfoB
        
        //Reload Feed
        collectionView.reloadData()
    }
    
    private func loadIndicator(){
        if !showIndicator{//show indicator
            indicator.isHidden = false
            indicator.startAnimating()
            showIndicator = true
        }else{//stop and hide indicator
            indicator.isHidden = true
            indicator.stopAnimating()
            showIndicator = false
        }
    }
    
    private func testStationDown(data: StationData,stationID: String){
        if((data.duration > 0) && (data.energy == 0.0) && (data.dollarAmount == 0.0)){
            numBadData += 1
        }
        if numBadData >= 3 { //if n pieces of bad data are seen then station is down
            if stationID.lowercased() == "a" {HomeVC.stationStates[0] = 0}
            else {HomeVC.stationStates[1] = 0}
        }else{
            if stationID.lowercased() == "a" {HomeVC.stationStates[0] = 1}
            else {HomeVC.stationStates[1] = 1}
        }
        
        print("B STATE: \(HomeVC.stationStates[1])")
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
    private func calculateAverage(array: [StationData], typeAverage: String,stationID: String) -> [String]{
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
            print("DAYS: \(numDays)")
            carAverage /= numDays
            print("SPENT SUM \(spentAverage)")
            spentAverage /= Double(numDays)
            print("Energy SUM \(energyAverage)")

            energyAverage /= Double(numDays)
            print("Duration SUM \(durationAverage)")

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
    
    private func isStationCongested(station: String) -> Bool{
        if station.lowercased() == "a"{
            if HomeVC.stationStates[0] != 0{ //make sure station is not down
                if(calculatedWaitingA >= UserDefaults.standard.integer(forKey: "congestNum")){return true}
            }else {return false}
            
            
        }else if station.lowercased() == "b"{
            if HomeVC.stationStates[1] != 0{ //make sure station is not down
                if(calculatedWaitingB >= UserDefaults.standard.integer(forKey: "congestNum")){return true}
            }else {return false}
        }
        return false //station not found
    }
}

//Collection View -> Showing the preview of the station data
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, OverViewDelegate{
    
    
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
        var stationID = ""
      
        //if searching use searchingStations array
        if searching{
            stationID = "\(Array(searchingDict.keys)[indexPath.row])"
            cell.stationId.text = "Station ID: \(stationID)"
            if selectedAverage == "session"{
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "session", stationID: stationID)
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "daily", stationID: stationID)
            }else{ //monthly
                averageData = calculateAverage(array: Array(searchingDict.values)[indexPath.row], typeAverage: "monthly", stationID: stationID)
            }
            
        //else use stations array
        }else{
            stationID = "\(Array(displayDict.keys)[indexPath.row])"
            cell.stationId.text = "Station ID: \(stationID)"
            if selectedAverage == "session"{
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row] , typeAverage: "session", stationID: stationID)
            }else if selectedAverage == "daily"{
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row], typeAverage: "daily", stationID: stationID)
            }else{ //monthly
                averageData = calculateAverage(array: Array(displayDict.values)[indexPath.row], typeAverage: "monthly", stationID: stationID)
            }
        }
        //time.0 = hours, time.1 = min
        let time = secondsToHoursMinutes(seconds: Int(averageData[4]) ?? -1)
        let cellStatus = getStationStatus(stationID: "\(stationID)")
        print("CELL STATUS \(cell)")
        
        cell.overViewDelegate = self
        cell.indexPath = indexPath
        cell.stationImage.image = UIImage(named: "evStation.png")
        cell.averageTitle.text = averageData[0]
        if averageData[1] == "0" {cell.averageCars.text = ""} //print nothing if empty
        else{cell.averageCars.text = "\(averageData[1]) cars"}
        cell.averageSpent.text = "$\(averageData[2])"
        cell.averageEnergy.text = "\(averageData[3]) kWh"
        cell.averageDuration.text = "\(time.0):\(time.1)"
        
        //Station not working
        if cellStatus == 0{
            cell.stationStatus.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            cell.stationStatus.text = "Status: Down"
        }else if cellStatus == 1{ //station is up
            cell.stationStatus.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            cell.stationStatus.text = "Status: Working"
        }
        else{//station is congested
            cell.stationStatus.textColor = #colorLiteral(red: 0.8661828041, green: 0.8576400876, blue: 0.05201935023, alpha: 1)
            cell.stationStatus.text = "Status: Congested"
        }
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        searchBar.endEditing(true) //when a cell is clicked hide keyboard
//        if searching{
//
//            //Display station name
//            HomeVC.stationClicked = "Station: \(Array(searchingDict.keys)[indexPath.row])"
//
//            //Store clicked station to use on DeatailVC
//            HomeVC.clickedStation = Array(searchingDict.values)[indexPath.row]
//
//        }else{
//            HomeVC.stationClicked = "Station: \(Array(displayDict.keys)[indexPath.row])"
//            HomeVC.clickedStation = Array(displayDict.values)[indexPath.row]
//
//        }
//
//        navGoTo("DetailVC", animate: true)
//    }
    
    func getStationStatus(stationID: String) -> Int{
        switch stationID.lowercased() {
        case "a":
            return HomeVC.stationStates[0]
        case "b":
            return HomeVC.stationStates[1]
        default:
            print("Station not found")
            return 1
        }
        
        
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
            loadWebsite(url: "https://www.zachsapps.com/contact")
            print("Pressed Contact Us")
        case "About Us":
            navGoTo("AboutVC", animate: true)
            print("Pressed About Us")
        default:
            print("Button Not Found (-1)")
            
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

