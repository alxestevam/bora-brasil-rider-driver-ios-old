//
//  GradientButton.swift
//  rider
//
//  Created by Victor Baleeiro on 18/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

@IBDesignable
final class GradientButton: UIButton {

    @IBInspectable var firstColor: UIColor = .clear { didSet { updateView() } }
    @IBInspectable var secondColor: UIColor = .clear { didSet { updateView() } }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) { didSet { updateView() } }
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1, y: 1) { didSet { updateView() } }
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { updateView() } }


    override class var layerClass: AnyClass { get { CAGradientLayer.self } }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
        //layer.frame = bounds
    }

    private func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.cornerRadius = cornerRadius
    }
}
