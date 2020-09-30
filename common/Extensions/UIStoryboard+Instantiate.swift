//
//  UIStoryboard+Instantiate.swift
//
//  Created by Victor Baleeiro on 05/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation
import UIKit

// MARK: Extension
extension UIStoryboard {
    
    convenience init(name: String) {
        self.init(name: name, bundle: nil)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        let identifier = String(describing: T.self)
        guard let viewController: T = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Failed to instantiate ViewController with identifier '\(identifier)'")
        }
        return viewController
    }
}
