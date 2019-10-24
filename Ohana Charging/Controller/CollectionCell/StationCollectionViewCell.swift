//
//  StationCollectionViewCell.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 10/21/19.
//

import UIKit
class StationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stationId: UILabel!
    @IBOutlet weak var stationImage: UIImageView!
    @IBOutlet weak var averageTitle: UILabel!
    @IBOutlet weak var averageCars: UILabel!
    @IBOutlet weak var averageEnergy: UILabel!
    @IBOutlet weak var averageDuration: UILabel!
    @IBOutlet weak var averageSpent: UILabel!
    
    override func layoutSubviews() {
        stationImage.tintColor = UIColor.black
    }
    
    
}
