//
//  CF.swift
//  Modamania
//
//  Created by macbook  on 17.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit
class CF {
    
    static let medium = "OpenSans-Medium"
    static let regular = "OpenSans-Regular"
    static let bold = "OpenSans-Bold"
    static let semiBold = "OpenSans-Semibold"
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Geçersiz red component")
        assert(green >= 0 && green <= 255, "Geçersiz green component")
        assert(blue >= 0 && blue <= 255, "Geçersiz blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
extension UIColor{
    
    static var primaryBlue = UIColor(rgb: 0x531B93)
    static var darkBlue = UIColor(rgb: 0x373b44)
    static var darkTextColor = UIColor(rgb: 0x212121) // 212121
    static var secondTextColor = UIColor(rgb: 0x545454)
    static var lightTextColor = UIColor(rgb: 0x797979)
    static var shimmerColor = UIColor(rgb: 0xd9d9d9)
    static var darkSmokeColor = UIColor(rgb: 0xc5c5c5)
    static var smokeWhite = UIColor(rgb: 0xf5f5f5)
    static var middlePrimary = UIColor(rgb: 0x531B93)
    static var middleDarkColor = UIColor(rgb: 0x323232)
    static var fullDark = UIColor(rgb: 0x101010)
    static var mor = UIColor(rgb: 0x6a2e57)
    static var joinersBtnColor = UIColor(rgb: 0x46B5B8)
    static var join1 = UIColor(rgb: 0xFF416C)
    static var join2 = UIColor(rgb: 0xFF4B2B)
    static var orange = UIColor(rgb: 0xD1693F)
    static var startDateG1 = UIColor(rgb: 0xF7971E)
    static var startDateG2 = UIColor(rgb: 0xFFD200)
    static var endDateG1 = UIColor(rgb: 0x4A00E0)
    static var endDateG2 = UIColor(rgb: 0x8E2DE2)
    static var androidGreen = UIColor(rgb: 0x109d58)
    static var priceG1 = UIColor(rgb: 0xa044ff)
    static var priceG2 = UIColor(rgb: 0x6a3093)
    static var mapBtnG2 = UIColor(rgb: 0x00B4DB)
    static var mapBtnG1 = UIColor(rgb: 0x0083B0)
    static var coolBluesDark = UIColor(rgb: 0x2193b0)
    static var coolBluesLight = UIColor(rgb: 0x6dd5ed)
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
