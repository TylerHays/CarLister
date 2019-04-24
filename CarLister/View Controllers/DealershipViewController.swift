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
    
}
