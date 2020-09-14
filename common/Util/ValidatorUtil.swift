//
//  ValidatorUtil.swift
//  driver
//
//  Created by Victor Baleeiro on 09/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation

struct ValidatorUtil {
    static let shared = ValidatorUtil()
    private init() { }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isCpfValid(_ cpf: String) -> Bool {
        let cpf = cpf.onlyNumbers()
        guard cpf.count == 11 else { return false }
        
        let i1 = cpf.index(cpf.startIndex, offsetBy: 9)
        let i2 = cpf.index(cpf.startIndex, offsetBy: 10)
        let i3 = cpf.index(cpf.startIndex, offsetBy: 11)
        let d1 = Int(cpf[i1..<i2])
        let d2 = Int(cpf[i2..<i3])
        
        var temp1 = 0, temp2 = 0
        
        for i in 0...8 {
            let start = cpf.index(cpf.startIndex, offsetBy: i)
            let end = cpf.index(cpf.startIndex, offsetBy: i+1)
            let char = Int(cpf[start..<end])
            
            temp1 += char! * (10 - i)
            temp2 += char! * (11 - i)
        }
        
        temp1 %= 11
        temp1 = temp1 < 2 ? 0 : 11-temp1
        
        temp2 += temp1 * 2
        temp2 %= 11
        temp2 = temp2 < 2 ? 0 : 11-temp2
        
        return temp1 == d1 && temp2 == d2
    }
    
    func cardNumberIsValid(_ number: String) -> Bool {
        let finalNumber = number.replacingOccurrences(of: " ", with: "")
        let v = CreditCardValidator()
        return finalNumber != "0000000000000000" && finalNumber != "000000000000000" && finalNumber.count >= 15 && luhnCheck(finalNumber) && v.validate(string: finalNumber)
    }
    
    func expirationDateIsValid(_ date: String) -> Bool {
        let numeros = date.compactMap({ $0.wholeNumberValue })
        if (numeros.count == 4) {
            if dateFromString(dateString: date, stringFormat: "MM/yy") != nil {
                return true
            }
        }
        
        return false
    }
    
    func cvvIsValid(_ code: String) -> Bool {
        let numbers = code.compactMap({ $0.wholeNumberValue })
        return numbers.count >= 3
    }
    
    func luhnCheck(_ numero: String) -> Bool {
        var sum = 0
        let digitStrings = numero.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    func dateFromString(dateString: String?, stringFormat: String!) -> Date? {

        if let str = dateString {

            let updatedString: String = str.replacingOccurrences(of: " 0000", with: " +0000")

            let dateFormatter: DateFormatter = DateFormatter()
            let calendar: Calendar = Calendar(identifier: .gregorian)
            let enUSPOSIXLocale: Locale = Locale(identifier: "en_US_POSIX")
            
            //
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.calendar = calendar
            dateFormatter.dateFormat = stringFormat
            dateFormatter.locale = enUSPOSIXLocale
            //
            let date: Date? = dateFormatter.date(from: updatedString)
            //
            return date

        } else {
            return nil
        }
    }
}

// MARK: Aux
extension String {
    func onlyNumbers() -> String {
        guard !isEmpty else { return "" }
        return replacingOccurrences(of: "\\D",
                                    with: "",
                                    options: .regularExpression,
                                    range: startIndex..<endIndex)
    }
}

