//
//  DetailVC.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//
import UIKit
import Charts
class DetailVC: UIViewController {
    
    let sheet = UIAlertController(title: "Please select an option to see location of station",
                                  message: "Map Options",
                                  preferredStyle: .actionSheet)
    private var stationLatitude = 21.300676
    private var stationLongitude = -157.851767
    private var didOpenSheet = false
    
    //Pie Chart Data
    private var creditPieData = PieChartDataEntry(value: 0.0)
    private var rfidPieData = PieChartDataEntry(value: 0.0)
    private var numberPaymentEntries = [PieChartDataEntry]()
    
    //Energy Bar Chart Data
  
    private var energyEntryArray = [ChartDataEntry]()
    private var energyMonthAvg = [Double]()//y-axis data points
    private var orderedMonths = [Double]() //x-axis data points
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var energyLineChart: LineChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = HomeVC.stationClicked
        let energyDataArrays = getEnergyData(stationData: HomeVC.clickedStation)
        //Get date in format -> mm.yy for line graph with NO duplicates
        orderedMonths = energyDataArrays.0
        print(orderedMonths.count)
        //Monthly energy avg in kWh in same order as orderedMonths
        energyMonthAvg = energyDataArrays.1
        print(energyMonthAvg.count)

        
        //Generate all data for graphs
        generatePieData()
        assignPieData()
        
        generateEnergyData()
        assignEnergyData()
        
    }
    
    @IBAction func mapPressed(_ sender: Any) {
        actionSheetMaps()
    }
    
    //-----------------------Pie Chart---------------------------------
    
    private func generatePieData(){
        var numCredit = 0
        var numRfid = 0
        
        //Count different types
        for data in HomeVC.clickedStation{
            if data.paymentMethod.lowercased() == "creditcard"{numCredit += 1}
            else{numRfid += 1}
        }
        
        //Give values
        creditPieData.value = Double(numCredit)
        rfidPieData.value = Double(numRfid)

        //Give label
        creditPieData.label = "Credit Card"
        rfidPieData.label = "RFID"
        
        //Set data set
        numberPaymentEntries = [creditPieData,rfidPieData]
        
    }
    private func assignPieData(){
        let colors = [UIColor.blue,UIColor.red] //colors for pie chart
        let pieDataSet = PieChartDataSet(entries: numberPaymentEntries, label: nil) //give data set
        let pieData = PieChartData(dataSet: pieDataSet)
        
        //Give properties
        pieDataSet.colors = colors //assign colors
        pieChart.data = pieData //assign data
        pieChart.chartDescription?.text = "Payment Methods"
    }
    
    //--------------------------------------------------------

    
    //-----------------------Energy Line Chart---------------------------------
    private func generateEnergyData(){
        for i in 0..<orderedMonths.count{
            energyEntryArray.append(ChartDataEntry(x: orderedMonths[i], y: energyMonthAvg[i]))
        }
         
    }
    
    private func assignEnergyData(){
        let dataSet = LineChartDataSet(entries: energyEntryArray, label: "beep")
        let data = LineChartData(dataSet: dataSet)
        
        energyLineChart.data = data
        

        
        
        
        
    }
    
    
    
    //--------------------------------------------------------

    
    
    //getEnergyData.1 = array of mm.yy for each month
    //getEnergyData.1 = array of monthly averages

    private func getEnergyData(stationData: [StationData]) -> ([Double], [Double]){
        var monthYearArray = [Double]()
        var monthEnergyArray = [Double]()
        var sum = 0.0

        let splitPreviousDate = (stationData[0].endDate.split(separator: "/"))
//        let previousMonthYear = "\(splitPreviousDate[0]).\(splitPreviousDate[2])"
//        monthYearArray.append(Double(previousMonthYear)!)
        
        //Get all mm/yy
        for data in stationData{
            //get all months
            let month = (data.endDate.split(separator: "/"))[0]
            let year = (data.endDate.split(separator: "/"))[2]
            let monthYear = "\(month).\(year)"
            let energy = data.energy

            if(!monthYearArray.contains(Double(monthYear)!)) {
                monthYearArray.append(Double(monthYear)!)
                monthEnergyArray.append(sum.rounded(toPlaces: 2))
                sum = 0.0
                
            }else{ //same month
                sum += energy
            }
        }
        return (monthYearArray,monthEnergyArray)
    }
    
//    private func getMontlyEnergyAverages(stationData: [StationData]) -> [Double]{
//        var output = [Double]()
//        var firstMonth = (stationData[0].endDate.split(separator: "/"))[0]
//        var sum = 0.0
//
//        for data in stationData{
//            let energy = data.energy
//            let month = (data.endDate.split(separator: "/"))[0]
//            if(firstMonth != month){//diff month
//                output.append(sum.rounded(toPlaces: 2))
//                sum = 0.0
//                firstMonth = month
//            }else{ //same month
//                sum += data.energy
//            }
//        }
//
//        return output
//    }
    
    
    
    
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
