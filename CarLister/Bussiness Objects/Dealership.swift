//
//  Dealership.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class Dealership {

    
    var dealerId: Int
    var name: String
    var vechicles: [Vechicle]
    
    init(dealerData: DealershipData, vechicles: [Vechicle] = []) {
        self.dealerId = dealerData.dealerId
        self.name = dealerData.name
        self.vechicles = vechicles
    }
}

struct DealershipData: Codable {
    let dealerId: Int
    let name: String
}
