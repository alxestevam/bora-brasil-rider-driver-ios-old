//
//  UIView+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 10/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    @discardableResult
    func configuraGradient(cores: [UIColor], comRaio raio: CGFloat = 0) -> CAGradientLayer {
        return configuraGradient(cores: cores, locations: nil, comRaio: raio)
    }
    
    @discardableResult
    func configuraGradient(cores: [UIColor], comRaio raio: CGFloat = 0, locations: [NSNumber] = [], pontoInicial: CGPoint, pontoFinal: CGPoint) -> CAGradientLayer {
        return configuraGradient(cores: cores, locations: locations, comRaio: raio, pontoInicial: pontoInicial, pontoFinal: pontoFinal)
    }
    
    @discardableResult
    private func configuraGradient(cores: [UIColor], locations: [NSNumber]?, comRaio raio: CGFloat = 0) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = cores.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = raio
        var replaced = false
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                if (sublayer.isKind(of: CAGradientLayer.self)) {
                    layer.replaceSublayer(sublayer, with: gradient)
                    replaced = true
                    break
                }
            }
        }
        
        if (!replaced) {
            layer.insertSublayer(gradient, at: 0)
        }
        
        return gradient
    }
    
    @discardableResult
    private func configuraGradient(cores: [UIColor], locations: [NSNumber]?, comRaio raio: CGFloat = 0, pontoInicial: CGPoint, pontoFinal: CGPoint) -> CAGradientLayer {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = cores.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = raio
        gradient.startPoint = pontoInicial
        gradient.endPoint = pontoFinal
        gradient.contentsCenter = layer.contentsCenter
        gradient.masksToBounds = true
        var replaced = false
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                if (sublayer.isKind(of: CAGradientLayer.self)) {
                    layer.replaceSublayer(sublayer, with: gradient)
                    replaced = true
                    break
                }
            }
        }
        
        if (!replaced) {
            layer.insertSublayer(gradient, at: 0)
        }
        
        return gradient
    }
    
    
    
    func configuraBorda(tamanhoBorda: CGFloat = 24.0) {
        layer.cornerRadius = tamanhoBorda
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func addEfeitoBlur(estilo: UIBlurEffect.Style = .dark) {
        
        let darkBlur = UIBlurEffect(style: estilo)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = bounds
        blurView.alpha = 0.8
        addSubview(blurView)
    }
}
