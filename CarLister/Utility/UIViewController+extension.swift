//
//  UIViewController+extension.swift
//  CarLister
//
//  Created by Tyler Hays on 4/24/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

extension UIViewController {
    func showOKAlertMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
