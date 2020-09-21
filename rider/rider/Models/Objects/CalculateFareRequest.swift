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
    var estimatedTravelTime: Int
    var estimatedTravelDistance: Int
    var estimatedTravelPath: String? = nil
}
