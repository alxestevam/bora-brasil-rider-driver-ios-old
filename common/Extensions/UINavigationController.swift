//
//  UINavigationController.swift
//  rider
//
//  Created by Victor Baleeiro on 09/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

public protocol VCWithBackButtonHandler {
     func shouldPopOnBackButton() -> Bool
}

extension UINavigationController: UINavigationBarDelegate  {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {

        if viewControllers.count < (navigationBar.items?.count) ?? 0 {
            return true
        }

        var shouldPop = true
        let vc = self.topViewController

        if let vc = vc as? VCWithBackButtonHandler {
            shouldPop = vc.shouldPopOnBackButton()
        }

        if shouldPop {
            DispatchQueue.main.async {[weak self] in
                _ = self?.popViewController(animated: true)
            }
        } else {
            for subView in navigationBar.subviews {
                if(0 < subView.alpha && subView.alpha < 1) {
                    UIView.animate(withDuration: 0.25, animations: {
                        subView.alpha = 1
                    })
                }
            }
        }

        return false
    }
}
