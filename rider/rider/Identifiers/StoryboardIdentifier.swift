//
//  StoryboardIdentifier.swift
//
//  Created by Victor Baleeiro on 05/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation

// MARK: - Enum
enum StoryboardIdentifier: String, CustomIdentifier {
    
    // Storyboard
    case Wallet
    case WalletDetail
}

// MARK: Extension
extension StoryboardIdentifier {
    
    func toString() -> String {
        return String(withCustomIdentifier: self)
    }
}
