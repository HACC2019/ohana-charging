//
//  Station.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//

struct StationDataStruct: Codable{
    
    let startDate : String
    let startTime: String
    let endDate : String
    let endTime: String
    let duration : Int
    let energy : Double //kwH
    let dollarAmount : Double //in dollars $$
    let portType : String //Cases-> CHADEMO or DCCOMBOTYP1
    let paymentMethod : String //Cases -> CREDITCARD or RFID
    
    private enum CodingKeys: String, CodingKey {
        case startDate = "startDate"
        case startTime = "startTime"
        case endDate = "endDate"
        case endTime = "endTime"
        case duration = "duration"
        case energy = "energy"
        case dollarAmount = "amount"
        case portType = "portType"
        case paymentMethod = "paymentMode"
    }
    
}

class StationData{
    var startDate : String
    var startTime: String
    var endDate : String
    var endTime : String
    var duration : Int
    var energy : Double //kwH
    var dollarAmount : Double //in dollars $$
    var portType : String //Cases-> CHADEMO or DCCOMBOTYP1
    var paymentMethod : String //Cases -> CREDITCARD or RFID
    
    init(startDate: String,startTime: String, endDate: String,endTime: String, duration: Int,
         energy: Double, dollarAmount: Double, portType: String, paymentMethod: String){
        self.startDate = startDate
        self.startTime = startTime
        self.endDate = endDate
        self.endTime = endTime
        self.duration = duration
        self.energy = energy
        self.dollarAmount = dollarAmount
        self.portType = portType
        self.paymentMethod = paymentMethod
    }
    
    
 
    
    
}
