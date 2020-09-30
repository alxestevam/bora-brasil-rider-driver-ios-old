//
//  WalletViewCardCellV2.swift
//  rider
//
//  Created by Victor Baleeiro on 30/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import Eureka


//MARK: - Aditional View
open class WalletViewCardCellV2: Cell<Bool>, CellType {
    
    //MARK: - Properties
    @IBOutlet weak var viewContent: UIView!
    
    
    //MARK: - Init
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    //MARK: - Setup/Lifecycle
    open func setupCell(_ card: GetCardDetailResult) {
        
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
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
    }

    open override func update() {
        super.update()
    }
}


// MARK: WalletCardRow
open class _WalletCardRow: Row<WalletViewCardCellV2> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class WalletCardRow: _WalletCardRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
