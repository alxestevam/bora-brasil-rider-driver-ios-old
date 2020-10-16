//
//  Travel.swift
//
//  Copyright (c) Minimalistic Apps. All rights reserved.
//

import Foundation
import CoreLocation


public final class Request: Codable, Hashable {
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static var shared = Request()
    
    // MARK: Properties
    public var addresses: [String]? = []
    public var points: [CLLocationCoordinate2D]? = []
    public var durationReal: Int?
    public var distanceReal: Int?
    public var requestTimestamp: Double?
    public var expectedTimestamp: Double?
    public var currency: String?
    public var startTimestamp: UInt64?
    public var etaPickup: Double?
    public var finishTimestamp: Double?
    public var driver: Driver?
    public var coupon: Coupon?
    public var rating: Int?
    public var costBest: Double?
    public var costAfterCoupon: Double?
    public var rider: Rider?
    public var distanceBest: Int?
    public var status: Status?
    public var durationBest: Int?
    public var cost: Double?
    public var id: Int?
    public var isHidden: Int?
    public var log: String?
    public var service: Service?
    public var confirmationCode: Int?
    public var paymentType: PaymentType?
    public var finalCost: Double?
    public var pickupTime: Int? // tempo em minutos
    public var recalculatedTravelTime: Int? // tempo em minutos

    
    var finalCostEffectively: Double {
        get {
            if let fc = finalCost {
                return fc
            }
            
            return costBest ?? 0.0
        }
      }
    
    var finalStatusEffectively: Status {
        get {
            if let st = status {
                return st
            }
            
            return .NotFound
        }
    }
    
    public enum PaymentType: String, Codable {
        case credit = "credit"
        case cash = "cash"
    }
    
    public enum Status: String, Codable {
        case Requested = "Requested"
        case NotFound = "NotFound"
        case NoCloseFound = "NoCloseFound"
        case Found = "Found"
        case DriverAccepted = "DriverAccepted"
        case WaitingForPrePay = "WaitingForPrePay"
        case DriverCanceled = "DriverCanceled"
        case RiderCanceled = "RiderCanceled"
        case Arrived = "Arrived"
        case Started = "Started"
        case WaitingForPostPay = "WaitingForPostPay"
        case WaitingForReview = "WaitingForReview"
        case Finished = "Finished"
        case Booked = "Booked"
        case Expired = "Expired"
        case RejectedByAntiFraud = "RejectedByAntiFraud"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

