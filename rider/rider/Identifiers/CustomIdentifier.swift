//
//  CustomIdentifier.swift
//  mdesp
//
//  Created by Victor Baleeiro on 05/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation

// MARK: Protocol
public protocol CustomIdentifier {
    var key: String { get }
}

// MARK: Extension
extension CustomIdentifier where Self: RawRepresentable, Self.RawValue == String {

    public var key: String { return self.rawValue }
}
