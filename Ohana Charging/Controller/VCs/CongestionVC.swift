//
//  CongestionVC.swift
//  Ohana Charging
//
//  Created by Zachary Kline on 11/2/19.
//

import UIKit
import MaterialComponents.MaterialButtons
class CongestionVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    private var selectedNum = 0
    private var savedRowNum = 0
    private var durationNumbers = [Int]()

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var doneButton: MDCFloatingButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationNumbers = fillPicker(min: 0, max: 120)
        selectRowForPicker()
        doneButton.setShadowColor(UIColor.black, for: .normal)
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        //if this first time opening app then set first open to false and save
        if !InitialVC.isKeyPresentInUserDefaults(key: "firstOpen") {UserDefaults.standard.set(false, forKey: "firstOpen")}
        
        UserDefaults.standard.set(selectedNum, forKey: "congestNum") //save selected num
        UserDefaults.standard.set(savedRowNum, forKey: "savedRow")//save row they selected
        InitialVC.goTo("MainNavVC", animate: true) //navigate
        
    }
    
    func selectRowForPicker(){
        if InitialVC.isKeyPresentInUserDefaults(key: "savedRow") {picker.selectRow(UserDefaults.standard.integer(forKey: "savedRow"), inComponent: 0, animated: false)}
        else{picker.selectRow(0, inComponent: 0, animated: false)}
    }
    
    //number of items in one row
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //number of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durationNumbers.count
    }
    
    //item properties
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: String(durationNumbers[row]), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
          return attributedString
    }
    //Use to retrieve selected item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedNum = durationNumbers[row] as Int //keep track of what number they selected
        savedRowNum = row //keep track of what row user is on
            
    }
    
    //Iterate every 5 min
    private func fillPicker(min: Int, max: Int) -> [Int]{
        var output = [Int]()
        for i in min...max{
            if(i % 5 == 0) {output.append(i)}
        }
        return output
    }
      
}
