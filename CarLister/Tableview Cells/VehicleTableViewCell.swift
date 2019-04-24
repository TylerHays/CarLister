//
//  VehicleTableViewCell.swift
//  CarLister
//
//  Created by Tyler Hays on 4/23/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class VehicleTableViewCell: UITableViewCell {

    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var vehicleIdLabel: UILabel!
    @IBOutlet weak var dealershipIdLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(with vechicle:Vechicle) {
        self.yearLabel.text = "\(vechicle.year)"
        self.makeLabel.text = vechicle.make
        self.modelLabel.text = vechicle.model
        self.vehicleIdLabel.text = "\(vechicle.vechicleId)"
        self.dealershipIdLabel.text =  "\(vechicle.dealershipId)"
        
    }

}
