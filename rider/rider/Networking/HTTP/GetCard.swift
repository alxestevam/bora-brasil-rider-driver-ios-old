//
//  GetCard.swift
//  rider
//
//  Created by Victor Baleeiro on 13/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation


class GetCard: HTTPRequest {
    
    //MARK: Properties
    var params: [String : Any]?
    var method: HTTPMethod = .get
    var path: String = "cardZoop"
    typealias ResponseType = GetCardResult
    
    
    //MARK: Constructor
    init(cpf: String) {
        path.append("/\(cpf)")
        self.params = [
            "": ""
        ]
    }
}

struct GetCardResult: Codable {
    var cards: [GetCardDetailResult]
}

struct GetCardDetailResult: Codable {
    
    var cardBrand: String?
    var last4Digits: String?
    var expirationMonth: String?
    var expirationYear: String?
    var holderName: String?
    
    enum CodingKeys: String, CodingKey {
        case cardBrand = "card_brand"
        case last4Digits = "last4_digits"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case holderName = "holder_name"
    }
}
