//
//  OptionalString.swift
//  rider
//
//  Created by Victor Baleeiro on 09/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

protocol OptionalString {}
extension String: OptionalString {}

extension Optional where Wrapped: OptionalString {
    var isNilOrEmpty: Bool {
        return ((self as? String) ?? "").isEmpty
    }
}
