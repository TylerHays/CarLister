//
//  DealerTableViewCell.swift
//  CarLister
//
//  Created by Tyler Hays on 4/23/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class DealerTableViewCell: UITableViewCell {
    @IBOutlet weak var dealerIdLabel: UILabel!
    @IBOutlet weak var dealerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setup(with dealership:Dealership) {
        self.dealerNameLabel.text = dealership.name
        self.dealerIdLabel.text = "\(dealership.dealerId)"
    }

}
