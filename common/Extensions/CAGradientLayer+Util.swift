//
//  CAGradientLayer+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 10/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    
    class func viewToImageGradient(on view: UIView, firstColor fc: UIColor = Color.orange.rgb_236_106_53, secondColor sc: UIColor = Color.orange.rgb_255_152_0) -> UIImage? {
        let gradient = CAGradientLayer()
        let firstColor = fc
        let secondColor = sc
        var bounds = view.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient.createGradientImage(on: view)
    }
    
    private func createGradientImage(on view: UIView) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(view.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}
