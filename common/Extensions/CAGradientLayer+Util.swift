//
//  CAGradientLayer+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 10/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    
    class func navBarGradient(on view: UIView) -> UIImage? {
        let gradient = CAGradientLayer()
        let firstColor = Color.orange.rgb_236_106_53
        let secondColor = Color.orange.rgb_255_152_0
        var bounds = view.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient.createGradientImage(on: view)
    }
    
    private func createGradientImage(on view: UIView) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}
