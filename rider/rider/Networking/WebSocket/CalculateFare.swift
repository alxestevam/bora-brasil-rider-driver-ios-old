//
//  CalculateFare.swift
//  rider
//
//  Created by Manly Man on 11/26/19.
//  Copyright © 2019 minimal. All rights reserved.
//

import UIKit
import MapKit


class CalculateFare: SocketRequest {
    typealias ResponseType = CalculateFareResult
    var params: [Any]?
    
    init(locations: [CLLocationCoordinate2D]) {
        let loc = locations.map() { loc in
            return [
                "x": loc.longitude,
                "y": loc.latitude
            ]
        }
        self.params = [try! CalculateFareRequest(locations: loc, estimatedTravelDistance: 100000, estimatedTravelTime: 30).asDictionary()]
    }
}

struct CalculateFareResult: Codable {
    var categories: [ServiceCategory]
    var fareResult: Double
    var currency: String
    var feeEstimationMode: FeeEstimationMode
}

enum FeeEstimationMode: String, Codable {
    case Static = "Static"
    case Dynamic = "Dynamic"
    case Ranged = "Ranged"
    case RangedStrict = "RangedStrict"
    case Disabled = "Disabled"
}
