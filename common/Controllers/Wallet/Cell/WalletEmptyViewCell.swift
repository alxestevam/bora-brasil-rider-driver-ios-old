//
//  WalletEmptyViewCell.swift
//  rider
//
//  Created by Victor Baleeiro on 30/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import Eureka


//MARK: - Aditional View
open class WalletEmptyViewCell: Cell<Bool>, CellType {
    
    //MARK: - Properties
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    
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
    open override func setup() {
        super.setup()
        selectionStyle = .none
    }

    open override func update() {
        super.update()
    }
}


// MARK: WalletRow
open class _WalletEmptyRow: Row<WalletEmptyViewCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class WalletEmptyRow: _WalletEmptyRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
