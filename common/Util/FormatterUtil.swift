//
//  FormatterUtil.swift
//  rider
//
//  Created by Victor Baleeiro on 20/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

struct FormatterUtil {
    static let shared = FormatterUtil()
    private init() { }
    
    func stringFromValue(value:Double, monetaryFormat monetary:Bool, decimalPrecision precision:Int) -> String {
        
        var texto:String
        let v = NSNumber.init(value: value)
        let formatter = NumberFormatter()
        let locale = Locale(identifier: "pt-BR")

        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfDown
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = precision
        formatter.minimumFractionDigits = precision
        formatter.minimumIntegerDigits = 1
        texto = formatter.string(from: v)!
        //
        if(monetary) {
            return String("R$ \(texto)")
            
        } else {
            return texto
        }
    }
}





