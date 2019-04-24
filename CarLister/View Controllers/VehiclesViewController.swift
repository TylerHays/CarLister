//
//  VehiclesViewController.swift
//  CarLister
//
//  Created by Tyler Hays on 4/23/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class VehiclesViewController: UIViewController {

    let vehicleCellIdentifier = "VehicleTableViewCell"
    
    var dealership: Dealership?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VehiclesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealership?.vechicles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vechicle = dealership?.vechicles[indexPath.row] else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: vehicleCellIdentifier, for: indexPath) as? VehicleTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(with: vechicle)
        return cell
    }
}
