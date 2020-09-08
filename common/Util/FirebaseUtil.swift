//
//  FirebaseUtil.swift
//  driver
//
//  Created by Victor Baleeiro on 10/08/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

struct FirebaseUtil {
    static let shared = FirebaseUtil()
    private init() { }
    
    func createDefaultFUIPhoneAuth(delegate: FUIAuthDelegate) -> FUIPhoneAuth {
        let auth = FUIAuth.defaultAuthUI()
        auth?.delegate = delegate
        let phoneAuth = FUIPhoneAuth(authUI: auth!, whitelistedCountries: ["BR"])
        auth?.providers = [phoneAuth]
        return phoneAuth
    }
}
