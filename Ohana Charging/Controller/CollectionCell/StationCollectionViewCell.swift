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
    @IBOutlet weak var stationStatus: UILabel!
    
    override func layoutSubviews() {
        createShadow(imageView: stationImage)
        stationId.layer.shadowOpacity = 0.2
        averageTitle.layer.shadowOpacity = 0.2
        averageCars.layer.shadowOpacity = 0.2
        averageEnergy.layer.shadowOpacity = 0.2
        averageDuration.layer.shadowOpacity = 0.2
        averageSpent.layer.shadowOpacity = 0.2
        //        stationStatus.layer.shadowOpacity = 0.2
    }
    
    private func createShadow(imageView: UIImageView){
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 1.0
        imageView.clipsToBounds = false
    }
    
    
}
