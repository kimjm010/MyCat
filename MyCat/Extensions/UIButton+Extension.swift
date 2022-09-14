//
//  UIButton+Extension.swift
//  MyCat
//
//  Created by Chris Kim on 9/14/22.
//

import Foundation
import UIKit


extension UIButton {
    func setToEnabledButtonTheme() {
        self.backgroundColor = UIColor(named: "black")
        self.tintColor = UIColor.white
        self.frame.size.height = 40
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
