//
//  WalletCell.swift
//  rider
//
//  Created by Victor Baleeiro on 29/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import Eureka


open class WalletCell: Cell<Bool>, CellType {

    //MARK: - Properties
    @IBOutlet public weak var imgCardBrand: UIImageView!
    @IBOutlet public weak var lblCardNumber: UILabel!
    
    
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
        self.imgCardBrand?.image = self.fetchImageForBrand(card.cardBrand ?? "")
        self.lblCardNumber?.text = self.applyMaskToCardNumber(card.last4Digits ?? "")
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    open override func update() {
        super.update()
    }
    
    
    //MARK: - Aux
    private func applyMaskToCardNumber(_ last4: String) -> String {
        return "**** \(last4)"
    }
    
    private func fetchImageForBrand(_ brand: String) -> UIImage {
        
        let lowercased = brand.lowercased()
        switch lowercased {
        case "visa":
            return #imageLiteral(resourceName: "visa-color_large")
        case "mastercard":
            return #imageLiteral(resourceName: "mastercard-color_large")
        case "americanexpress":
            return #imageLiteral(resourceName: "americanexpress-color-large")
        case "paypal":
            return #imageLiteral(resourceName: "paypal-color-large")
        case "bitcoin":
            return #imageLiteral(resourceName: "bitcoin-color-large")
        default:
            return #imageLiteral(resourceName: "logo")
        }
    }
}


// MARK: WalletRow
open class _WalletRow: Row<WalletCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class WalletRow: _WalletRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
