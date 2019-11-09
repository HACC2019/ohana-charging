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
    
    //Energy line Chart Data
    private var energyEntryArray = [ChartDataEntry]()
    private var energyMonthAvg = [Double]()//y-axis data points
    private var orderedMonths = [String]() //x-axis data points
    
    //Spend Bar Chart Data
    private var spentEntryArray = [BarChartDataEntry]()
    private var spentMonthAvg = [Double]()//y-axis data points


    
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var energyLineChart: LineChartView!
    
    @IBOutlet weak var spendBarChart: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = HomeVC.stationClicked //title on nav bar
        let energyDataArrays = getLineData(stationData: HomeVC.clickedStation, type: "energy")
        let spentDataArrays = getLineData(stationData: HomeVC.clickedStation, type: "spent")
        
        //Get date in format -> mm.yy for line graph with NO duplicates
        orderedMonths = energyDataArrays.0
        print(orderedMonths.count)
        //Monthly energy avg in kWh in same order as orderedMonths
        energyMonthAvg = energyDataArrays.1
        print(energyMonthAvg.count)
        
        spentMonthAvg = spentDataArrays.1

        
        //Generate all data for graphs
        pieChart.animate(xAxisDuration: 2.0)
        generatePieData()
        assignPieData()
        
        energyLineChart.xAxis.valueFormatter = self
        energyLineChart.animate(xAxisDuration: 2.0)
        generateEnergyData()
        assignEnergyData()
        
        spendBarChart.xAxis.valueFormatter = self
        spendBarChart.animate(xAxisDuration: 2.0)
        generateSpentData()
        assignSpentData()
        
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
        pieChart.chartDescription?.font = UIFont(name: "ArialMT", size: 13.0)!
        pieChart.chartDescription?.text = "Payment Methods"
        
    }
    
    //--------------------------------------------------------

    
    //-----------------------Energy Line Chart---------------------------------
    private func generateEnergyData(){
        for i in 0..<orderedMonths.count{
            energyEntryArray.append(ChartDataEntry(x: Double(i), y: energyMonthAvg[i]))

        }
         
    }
    
    private func assignEnergyData(){
        let dataSet = LineChartDataSet(entries: energyEntryArray, label: "Monthy Energy Use (kWh)")
        let data = LineChartData(dataSet: dataSet)
        
        energyLineChart.legend.font =  UIFont(name: "ArialMT", size: 13.0)!
        energyLineChart.data = data
    }
    
    
    
    //--------------------------------------------------------

    //-----------------------Spent Bar Chart---------------------------------
    private func generateSpentData(){
        for i in 0..<orderedMonths.count{
            spentEntryArray.append(BarChartDataEntry(x: Double(i), y: spentMonthAvg[i]))
        }
        
    }
    
    private func assignSpentData(){
        let dataSet = BarChartDataSet(entries: spentEntryArray, label: "Monthy Amount Earned in Dollars ($)")
        let data = BarChartData(dataSet: dataSet)
               
        spendBarChart.legend.font =  UIFont(name: "ArialMT", size: 13.0)!
        spendBarChart.data = data
    }
           
    
    
    //--------------------------------------------------------

    //getEnergyData.0 = array of mm/yy for each month
    //getEnergyData.1 = array of monthly averages depending on type

    private func getLineData(stationData: [StationData], type: String) -> ([String], [Double]){
        var monthYearArray = [String]()
        var monthEnergyArray = [Double]()
        var monthSpentArray = [Double]()
        var energySum = 0.0
        var spentSum = 0.0

        //Get all mm/yy
        for data in stationData{
            //get all months
            let month = (data.endDate.split(separator: "/"))[0]
            let year = (data.endDate.split(separator: "/"))[2]
            let monthYear = "\(month)/\(year)"
            let energy = data.energy
            let spend = data.dollarAmount
            
            //Different month is detected
            if(!monthYearArray.contains(monthYear)) {
                monthYearArray.append(monthYear) //add new month
                monthEnergyArray.append(energySum.rounded(toPlaces: 2)) //add enery sum
                monthSpentArray.append(spentSum) // add spent sum
                energySum = 0.0 //reset
                spentSum = 0.0 //reset
                
            }else{ //same month
                energySum += energy
                spentSum += spend
            }
        }
        if type == "energy" {return (monthYearArray,monthEnergyArray)}
        else{return (monthYearArray,monthSpentArray)}
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
            openURL)! as URL)) : (alert(message: "\(mapType) is not installed on this phone.", title: "\(mapType) Unavailable", actionType: .default))
    }
    
    
    
    
    
}

//Extension that changes x-axis on line graphs to strings
extension DetailVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let months = orderedMonths
        return months[Int(value)]
    }
}
