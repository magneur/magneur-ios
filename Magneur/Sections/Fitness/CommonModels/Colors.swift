//
//  Colors.swift
//  Magneur Fitness
//
//  Created by Andrei Istoc on 24.07.2022.
//

import UIKit

extension UIColor {
    
    class func magneurOrange() -> UIColor {
        return UIColor(hex: "#D4AF37")! // Metallic Gold
    }
    
    class func magneurRed() -> UIColor {
        return UIColor(hex: "#800000")! // Maroon/Deep Crimson
    }
    
    class func magneurBlack() -> UIColor {
        return UIColor(hex: "#050505")! // Deep Onyx
    }
    
    class func magneurBlue() -> UIColor {
        return UIColor(hex: "#1C2526")! // Dark Gunmetal
    }
    
    class func magneurDarkBlue() -> UIColor {
        return UIColor(hex: "#0F1112")! // Midnight
    }
    
    class func gradientOrange() -> UIColor {
        return UIColor(hex: "#B8860B")! // Dark Goldenrod
    }
    
    class func magneurLightGray() -> UIColor {
        return UIColor(hex: "#2C2C2E")! // Charcoal
    }
    
    class func magneurGreen() -> UIColor {
        return UIColor(hex: "#004225")! // British Racing Green
    }
    
    class func defaultWorkoutColor() -> UIColor {
        return UIColor(hex: "#800000")!
    }
    
    class func poolLightBlue() -> UIColor {
        return UIColor(hex: "#1C2526")!
    }
    
    class func poolDarkBlue() -> UIColor {
        return UIColor(hex: "#0F1112")!
    }
    
    class func upcomingLightRed() -> UIColor {
        return UIColor(hex: "#800000")!
    }
    
    class func upcomingDarkRed() -> UIColor {
        return UIColor(hex: "#400000")!
    }
    
    // New Premium Colors
    class func magneurSilver() -> UIColor {
        return UIColor(hex: "#E5E5EA")!
    }
    
    class func magneurPlatinum() -> UIColor {
        return UIColor(hex: "#F2F2F7")!
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    func hexStringFromColor() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        let a: CGFloat = components?[3] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)), lroundf(Float(a * 255)))
        return hexString
     }
}
