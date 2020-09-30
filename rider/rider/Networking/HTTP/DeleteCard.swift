//
//  DeleteCard.swift
//  rider
//
//  Created by Victor Baleeiro on 30/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation


class DeleteCard: HTTPRequest {
    
    //MARK: - Properties
    var params: [String : Any]?
    var method: HTTPMethod = .delete
    var path: String = "cardZoop"
    typealias ResponseType = EmptyClass
    
    
    //MARK: - Constructor
    init(cpf: String) {
        path.append("/\(cpf)")
        self.params = [
            "": ""
        ]
    }
}
