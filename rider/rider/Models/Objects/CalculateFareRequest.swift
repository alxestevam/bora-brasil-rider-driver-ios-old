//
//  CalculateFareRequest.swift
//  driver
//
//  Created by Victor Baleeiro on 17/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

struct CalculateFareRequest: Codable {
    var locations: Array<Dictionary<String, Double>>
    var estimatedTravelDistance: Int = 30
    var estimatedTravelTime: Int = 10000
}
