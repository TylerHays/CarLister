//
//  StartingView.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class StartingView: UIViewController {
    lazy var dataWork = DealersAndVehiclesWorker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func fetchDataPressed(_ sender: Any) {
        dataWork.loadData()
    }
    
}

