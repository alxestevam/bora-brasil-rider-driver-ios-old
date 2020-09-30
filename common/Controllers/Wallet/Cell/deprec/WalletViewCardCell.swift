//
//  WalletViewCardCell.swift
//  rider
//
//  Created by Victor Baleeiro on 13/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


@available(*, deprecated, message: "Use WalletViewCardCellV2 instead")
class WalletViewCardCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var viewContent: UIView!
    
    
    //MARK: Method
    func setupCard(_ card: GetCardDetailResult) {
        
        // Creating a Credit Card object
        let cardObj = YRPaymentCreditCard(type: .custom(UIImage()), isEditing: false)
        
        // Setting Credit Card position
        viewContent.addSubview(cardObj)
        cardObj.centerXAnchor.constraint(equalTo: viewContent.centerXAnchor).isActive = true
        cardObj.topAnchor.constraint(equalTo: viewContent.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        cardObj.heightAnchor.constraint(equalToConstant: 160).isActive = true
        cardObj.leadingAnchor.constraint(equalTo: viewContent.leadingAnchor, constant: 25).isActive = true
        
        // Data
        cardObj.cardNumber = "**** **** **** \(card.last4Digits ?? "")"
        cardObj.cardHolderName = card.holderName
        cardObj.cardValidity = (card.expirationMonth?.count == 1) ? "0\(card.expirationMonth ?? "00")/\(card.expirationYear ?? "00")" : "\(card.expirationMonth ?? "00")/\(card.expirationYear ?? "00")"
        
        // Layout
        let gradientImage = CAGradientLayer.viewToImageGradient(on: viewContent)
        cardObj.backgroundColor = UIColor(patternImage: gradientImage!)
        cardObj.isUserInteractionEnabled = false
        cardObj.layoutSubviews()
        cardObj.layoutIfNeeded()
    }
}
