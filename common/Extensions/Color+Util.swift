//
//  Color+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 10/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

open class Color: UIColor {
    
    // Vermelho
    open class orange {
        static let rgb_255_152_0 = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1)
        static let rgb_236_106_53 = UIColor(red: 236/255, green: 106/255, blue: 53/255, alpha: 1)
    }
    
    open class gray {
        static let rgb_29_28_30 = UIColor(red: 0.29, green: 0.28, blue: 0.30, alpha: 1)
        static let rgb_240_240_240 = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    open class green {
        static let rgb_129_199_132 = UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1)
        static let rgb_56_142_60 = UIColor(red: 56/255, green: 142/255, blue: 60/255, alpha: 1)
    }
    
    // MARK: Aux
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
