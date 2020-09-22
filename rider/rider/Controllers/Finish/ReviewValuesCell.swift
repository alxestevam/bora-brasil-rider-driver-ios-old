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
    }
    
    
    // MARK: - Setup
    private func setupLayout() {
        self.viewContent.backgroundColor = Color.gray.rgb_240_240_240
        self.lblPaymentType.textColor = .gray
        self.lblTime.textColor = .gray
        self.lblKm.textColor = .gray
    }
    
    func setupData(_ request: Request) {
        self.lblTotalValue.text = FormatterUtil.shared.stringFromValue(value: request.finalCostEffectively, monetaryFormat: true, decimalPrecision: 2)
        self.lblPaymentType.text = request.paymentType == .credit ? "Cartão" : "Dinheiro"
        
        let timeFormatted = Double(request.durationBest ?? 0).asString(style: .brief, allowedUnits: [.minute, .second])
        self.lblTime.text = timeFormatted
            
        let doubleDistance = Double(request.distanceBest ?? 0)
        let distanceFormatted = Measurement(value: Double(doubleDistance/1000), unit: UnitLength.kilometers)
        let n = NumberFormatter()
        n.maximumFractionDigits = 1
        let m = MeasurementFormatter()
        m.numberFormatter = n
        self.lblKm.text = m.string(from: distanceFormatted)
    }
}
