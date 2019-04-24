//
//  Vechicle.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class Vechicle {
    
    var vechicleId: Int
    var make: String
    var model: String
    var year: Int
    var dealershipId: Int
    
    
    init(vechicleData:VehicleData) {
        self.vechicleId = vechicleData.vehicleId
        self.make = vechicleData.make
        self.model = vechicleData.model
        self.year = vechicleData.year
        self.dealershipId = vechicleData.dealerId
    }
}

struct VehicleData:  Codable {
    let vehicleId: Int
    let year: Int
    let make: String
    let model: String
    let dealerId: Int
}
