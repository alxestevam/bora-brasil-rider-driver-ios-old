//
//  UITextField+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 08/10/20.
//  Copyright © 2020 minimal. All rights reserved.
//

extension UITextField {
    
    func modifyClearButtonWithImage(image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }

    @objc func clear(sender : AnyObject) {
        self.text = ""
    }
}
