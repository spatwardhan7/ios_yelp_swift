//
//  SwitchCell.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate{
    @objc optional func switchCell(switchcell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var radioButton: ISRadioButton!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
    }

    @IBAction func touchUpInsideButton(_ sender: AnyObject){
        print("touch up inside button")
        print("radio button before toggle :  isSelected: \(radioButton.isSelected)")
        if(radioButton.isSelected){
            print("radio button was not in selected state")
            delegate?.switchCell?(switchcell: self, didChangeValue: radioButton.isSelected)

        }
    }
    func switchValueChanged(){
        print("switch value changed")
        
        delegate?.switchCell?(switchcell: self, didChangeValue: onSwitch.isOn)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
