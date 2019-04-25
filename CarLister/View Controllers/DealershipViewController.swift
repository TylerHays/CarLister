//
//  DealershipViewController.swift
//  CarLister
//
//  Created by Tyler Hays on 4/23/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class DealershipViewController: UIViewController {

    var dealerships: [Dealership]?
    let dealershipCellId = "DealershipCell"
    let showVehiclesSegue = "ShowVehiclesSegue"
    
    var dealershipToShow: Dealership?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setup(dealerships: [Dealership]) {
        self.dealerships = dealerships
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showVehiclesSegue {
            setupshowVehiclesSegue(segue)
        }
    }
    
    func setupshowVehiclesSegue(_ segue: UIStoryboardSegue) {
        guard let controller = segue.destination as? VehiclesViewController,
            let dealershipToShow = self.dealershipToShow else {
                return
        }
        
        controller.setup(dealership: dealershipToShow)
    }
}

extension DealershipViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealerships?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dealership = dealerships?[indexPath.row] else {
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: dealershipCellId, for: indexPath) as? DealerTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: dealership)
        return cell
    }
}

extension DealershipViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let dealerships = self.dealerships else {
            return
        }
        
        dealershipToShow = dealerships[indexPath.row]
        self.performSegue(withIdentifier: showVehiclesSegue, sender: self)
    }
    
}
