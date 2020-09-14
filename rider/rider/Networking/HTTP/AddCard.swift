//
//  AddCard.swift
//  rider
//
//  Created by Victor Baleeiro on 13/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation


class AddCard: HTTPRequest {
    
    //MARK: Properties
    var params: [String : Any]?
    var method: HTTPMethod = .post
    var path: String = "tokenZoop/credit"
    typealias ResponseType = AddCardResult
    
    
    //MARK: Constructor
    init(cpf: String, holderName: String, expirationMonth: String, expirationYear: String, cardNumber: String, securityCode: String) {
        path.append("/\(cpf)")
        self.params = [
            "holder_name": holderName,
            "expiration_month": expirationMonth,
            "expiration_year": expirationYear,
            "card_number": cardNumber,
            "security_code": securityCode
        ]
    }
}

struct AddCardResult: Codable {
    
    //MARK: Properties
    var id: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}
