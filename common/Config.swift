//
//  Config.swift
//  Shared
//
//  Created by Manly Man on 11/22/19.
//  Copyright © 2019 Innomalist. All rights reserved.
//

import Foundation

class Config {
    //static var Backend: String = "http://192.168.0.26:8080/" // Local

    #if DEBUG || STAG
        static var Backend: String = "http://35.247.213.217:8080/"
    #elseif PROD || RELEASE
        static var Backend: String = "http://35.247.194.163:8080/"
    #endif
    
    static var Version: String {
        get {
            return self.Info["CFBundleVersion"] as! String
        }
    }
    
    static var Info: [String:Any] {
        get {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
            return NSDictionary(contentsOfFile: path) as! [String: Any]
        }
    }
}
