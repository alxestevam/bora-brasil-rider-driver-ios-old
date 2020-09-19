//
//  RequestDTO.swift
//  rider
//
//  Created by Manly Man on 11/15/19.
//  Copyright © 2019 minimal. All rights reserved.
//

import Foundation
import MapKit

struct RequestDTO: Codable {
    var locations: LocationWithNames
    var services: OrderedServices
    var intervalMinutes: Int = 0
    var paymentType: String
    var estimatedTravelTime: Int // tempo em minutos
    var estimatedTravelDistance: Int // distancia em metros
    var estimatedTravelPath: String = "" // valor do caminho a ser desenhado no mapa em base64
}

struct OrderedService: Codable {
    var serviceId: Int
    var quantity: Int
}

struct LocationWithName: Codable {
    public var loc: CLLocationCoordinate2D
    public var add: String
}

typealias LocationWithNames = [LocationWithName]
typealias OrderedServices = [OrderedService]
