//
//  viewControllerExtension.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 18/05/2019.
//  Copyright © 2019 Dimmy Maenhout. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideKeyBoardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
