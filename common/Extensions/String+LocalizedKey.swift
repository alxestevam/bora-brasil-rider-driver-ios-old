//
//  String+LocalizedKey.swift
//
//  Created by Victor Baleeiro on 05/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation
import UIKit

extension String  {
    
    public init(withCustomIdentifier identifier: CustomIdentifier) {
        self.init(NSLocalizedString(identifier.key, comment: ""))
    }
    
    public init(withCustomIdentifier identifier: CustomIdentifier, comment: String) {
        self.init(NSLocalizedString(identifier.key, comment: comment))
    }
}
