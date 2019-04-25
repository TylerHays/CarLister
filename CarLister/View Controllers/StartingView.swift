//
//  StartingView.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class StartingView: UIViewController {
    lazy var dataWork = DealersAndVehiclesWorker(workerDelegate: self)
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityMessageLabel: UILabel!
    let showDealershipSegue = "ShowDealershipsSegue"
    
    var dealerships: [Dealership]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideActivityView()
        // Do any additional setup after loading the view.
    }

    @IBAction func fetchDataPressed(_ sender: Any) {
        showActivityView()
        dataWork.fetchData()
    }
    
    func showActivityView() {
        activityView.isHidden = false
        activityIndicator.startAnimating()
        activityMessageLabel.text = "Gathering Data"
    }
    
    func hideActivityView() {
        activityView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if showDealershipSegue == segue.identifier {
            setupDealershipSegue(segue)
        }
    }
    
    func setupDealershipSegue(_ segue: UIStoryboardSegue) {
        guard let controller = segue.destination as? DealershipViewController, let dealerships = self.dealerships else {
            return
        }
        controller.setup(dealerships: dealerships)
    }
}

extension StartingView: DealersAndVehiclesWorkerDelegate {
    func dealersAndVehiclesWorkerComplete(_ worker: DealersAndVehiclesWorker, dataResponse: DealerVehicleCallResponse) {
        self.hideActivityView()
        if dataResponse.responseStatus == .successfull {
            self.dealerships = dataResponse.dealerships
            self.performSegue(withIdentifier: showDealershipSegue, sender: self)
        } else {
            self.showOKAlertMessage(title: "Error", message: "There was trouble collecting the data. Please check your internet connection and try again")
        }
    }
    
    func dealersAndVehiclesWorker(_ worker: DealersAndVehiclesWorker, updateMessage: String) {
        DispatchQueue.main.async {
            self.activityMessageLabel.text = updateMessage
        }
    }
}

