//
//  Station.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//

struct StationDataStruct: Codable{
    
    let id : String
    let startDate : String
    let endDate : String
    let duration : String
    let energy : String //kwH
    let dollarAmount : String //in dollars $$
    let portType : String //Cases-> CHADEMO or DCCOMBOTYP1
    let paymentMethod : String //Cases -> CREDITCARD or RFID
    
    private enum CodingKeys: String, CodingKey {
        case id,startDate,endDate,duration,energy,dollarAmount,portType,paymentMethod
        //        case id = "barID"
        //        case startDate = "sa"
        //        case type = "type"
        //        case price = "price"
        //        case size = "size"
    }
    
}

class StationData{
    var id : Int
    var startDate : String
    var endDate : String
    var duration : Int
    var energy : Double //kwH
    var dollarAmount : Double //in dollars $$
    var portType : String //Cases-> CHADEMO or DCCOMBOTYP1
    var paymentMethod : String //Cases -> CREDITCARD or RFID
    
    init(id: Int, startDate: String, endDate: String, duration: Int,
         energy: Double, dollarAmount: Double, portType: String, paymentMethod: String){
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.energy = energy
        self.dollarAmount = dollarAmount
        self.portType = portType
        self.paymentMethod = paymentMethod
    }
    
    
 
    
    
}
