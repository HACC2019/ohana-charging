//
//  Station.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//

struct Station{
    
    var id : Int
    var startDate : String
    var endDate : String
    var duration : Int
    var energy : Double //kwH
    var dollarAmount : Double //in dollars $$
    var portType : String //Cases-> CHADEMO or DCCOMBOTYP1
    var paymentMethod : String //Cases -> CREDITCARD or RFID
    
    private enum CodingKeys: String, CodingKey {
        case id,startDate,endDate,duration,energy,dollarAmount,portType,paymentMethod
    }
    
}
