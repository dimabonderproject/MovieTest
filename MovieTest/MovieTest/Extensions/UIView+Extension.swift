//
//  UIView+Extension.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    func addShadow(color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 5
    }
}
