//
//  Double+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 20/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle, allowedUnits: NSCalendar.Unit = [.hour, .minute, .second, .nanosecond]) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = allowedUnits
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
