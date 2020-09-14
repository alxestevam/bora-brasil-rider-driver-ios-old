//
//  YRPayment.swift
//  YRPayment
//
//  Created by Yassir RAMDANI on 6/27/19.
//  Copyright © 2019 Yassir RAMDANI. All rights reserved.
//

import Foundation

// MARK: Delegate
@objc public protocol YRPaymentDelegate: class {
    func allValidated()
    func notValidated()
}


public final class YRPayment: NSObject, UITextFieldDelegate {
    
    // MARK: Properties
    public let creditCard: YRPaymentCreditCard
    private var monthYearMask: TLCustomMaskUtil
    private var cardNumberMask: TLCustomMaskUtil
    private var cvvMask: TLCustomMaskUtil
    weak var actionDelegate: YRPaymentDelegate?

    
    public var flipOnClick: Bool = true {
        didSet {
            creditCard.flipOnClick = flipOnClick
        }
    }

    public var numberTextField: UITextField! {
        didSet {
            numberTextField.delegate = self
            numberTextField.keyboardType = .numberPad
            numberTextField.autocorrectionType = .no
            numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    public var holderNameTextField: UITextField! {
        didSet {
            holderNameTextField.delegate = self
            holderNameTextField.keyboardType = .default
            holderNameTextField.autocapitalizationType = .allCharacters
            holderNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    public var validityTextField: UITextField! {
        didSet {
            validityTextField.delegate = self
            validityTextField.keyboardType = .numberPad
            validityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    public var cryptogramTextField: UITextField! {
        didSet {
            cryptogramTextField.delegate = self
            cryptogramTextField.keyboardType = .numberPad
            cryptogramTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    public init(creditCard: YRPaymentCreditCard, flipOnClick: Bool = true, delegate: YRPaymentDelegate?) {
        self.creditCard = creditCard
        self.flipOnClick = flipOnClick
        self.actionDelegate = delegate
        self.monthYearMask = TLCustomMaskUtil()
        self.cardNumberMask = TLCustomMaskUtil()
        self.cvvMask = TLCustomMaskUtil()
        self.monthYearMask.formattingPattern = "$$/$$"
        self.cardNumberMask.formattingPattern = "$$$$ $$$$ $$$$ $$$$"
        self.cvvMask.formattingPattern = "$$$$"
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        defer {
            if validateFields() {
                actionDelegate?.allValidated()
            } else {
                actionDelegate?.notValidated()
            }
        }
        
        if textField == numberTextField {
            textField.text = self.cardNumberMask.formatString(string: textField.text ?? "")
            let unmasked = self.cardNumberMask.cleanText
            creditCard.cardNumber = unmasked
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == holderNameTextField {
            creditCard.cardHolderName = textField.text
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == validityTextField {
            textField.text = self.monthYearMask.formatString(string: textField.text ?? "")
            creditCard.cardValidity = textField.text
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == cryptogramTextField {
            textField.text = self.cvvMask.formatString(string: textField.text ?? "")
            let unmasked = self.cvvMask.cleanText
            creditCard.cardCryptogram = unmasked
            if creditCard.isFace { creditCard.flip() }
        }
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        creditCard.unselectAll()
        if textField == numberTextField {
            creditCard.cardNumberLabel.select()
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == holderNameTextField {
            creditCard.cardHolderNameLabel.select()
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == validityTextField {
            creditCard.cardValidityLabel.select()
            if !creditCard.isFace { creditCard.flip() }
        } else if textField == cryptogramTextField {
            creditCard.cardCryptogramLabel.select()
            if creditCard.isFace { creditCard.flip() }
        }
    }

    public func textFieldDidEndEditing(_: UITextField) {
        creditCard.unselectAll()
    }

    public func getCardNumber() -> String {
        return creditCard.cardNumber.replacingOccurrences(of: "X", with: "").replacingOccurrences(of: " ", with: "")
    }

    public func getCardHolderName() -> String {
        return creditCard.cardHolderName
    }

    public func getCardValidity() -> String {
        return creditCard.cardValidity
    }

    public func getCardCryptogram() -> String {
        return creditCard.cardCryptogram
    }

    func flip() {
        creditCard.flip()
    }
    
    
    // MARK: Validates
    private func validateFields() -> Bool {
        if let cNumber = creditCard.cardNumber, let cExpirationDate = creditCard.cardValidity, let cCryptogram = creditCard.cardCryptogram {
            let status = ValidatorUtil.shared.cardNumberIsValid(cNumber) && ValidatorUtil.shared.expirationDateIsValid(cExpirationDate) &&
                ValidatorUtil.shared.cvvIsValid(cCryptogram)
            self.updateLayoutCard(status)
            return status
        }
        
        self.updateLayoutCard(false)
        return false
    }
    
    private func updateLayoutCard(_ validated: Bool) {
        if validated {
            let gradientImage = CAGradientLayer.viewToImageGradient(on: creditCard)
            self.creditCard.backgroundColor = UIColor(patternImage: gradientImage!)
            
        } else {
            self.creditCard.backgroundColor = Color.gray.rgb_29_28_30
        }
    }
}
