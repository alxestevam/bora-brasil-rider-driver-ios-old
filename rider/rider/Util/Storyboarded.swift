//
//  Storyboarded.swift
//
//  Created by Victor Baleeiro on 05/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation
import UIKit

// MARK: Protocol
protocol Storyboarded {
    
    static var storyboardName: String { get }
    static var storyboard: UIStoryboard { get }
}


// MARK: Extension
extension Storyboarded {
    
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName)
    }
}
