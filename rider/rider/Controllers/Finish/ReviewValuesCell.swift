//
//  ReviewValuesCell.swift
//  rider
//
//  Created by Victor Baleeiro on 20/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


class ReviewValuesCell: UITableViewCell {

    // MARK: - Propriedades
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblKm: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupLayout()
        self.setupData()
        self.setupText()
    }
    
    
    // MARK: - Setup
    private func setupLayout() {
        self.viewContent.backgroundColor = Color.gray.rgb_240_240_240
        self.lblPaymentType.textColor = .gray
        self.lblTime.textColor = .gray
        self.lblKm.textColor = .gray
    }
    
    private func setupData() {
        
    }
    
    private func setupText() {
        
    }
}
