//
//  ServicesListCell.swift
//
//  Copyright © 2018 Minimalistic Apps. All rights reserved.
//

import UIKit

import Kingfisher

class ServicesListCell: UICollectionViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var textCost: UILabel!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    private var service: Service!
    private var quantity: Int = 0
    private var distance: Double = 0
    private var duration: Double = 0
    private var currency: String = ""
    private var fareResult: Double = 0
    private var feeEstimationMode: FeeEstimationMode = .Dynamic
    
    override var isSelected: Bool {
        didSet {
            self.contentView.alpha = isSelected ? 1 : 0.5
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.alpha = 0.5
    }
    
    func initialize(service: Service, distance: Int, duration: Int, currency: String) {
        self.service = service
        self.distance = Double(distance)
        self.duration = Double(duration)
        self.currency = currency
        self.updatePrice()
        textTitle.text = service.title
        if let media = service.media, let address = media.address {
            let url = URL(string: Config.Backend + address)
            imageIcon.kf.setImage(with: url)
        }
        buttonPlus.isHidden = true
        buttonMinus.isHidden = true
    }
    
    func initialize(service: Service, fareResult: Double, feeEstimationMode: FeeEstimationMode, currency: String) {
        self.service = service
        self.fareResult = fareResult
        self.feeEstimationMode = feeEstimationMode
        self.currency = currency
        self.updatePrice()
        textTitle.text = service.title
        if let media = service.media, let address = media.address {
            let path = Config.Backend + address
            guard let urlString = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return  }
            let url = URL(string: urlString)
            imageIcon.kf.setImage(with: url)
        }
        buttonPlus.isHidden = true
        buttonMinus.isHidden = true
    }
    
    func updatePrice() {
        
        let cost: Double = fareResult*service.multiplicationFactor //service.baseFare
        switch feeEstimationMode {
        case .Disabled:
            self.textCost.text = "-"
            break
        case .Static:
            self.textCost.text = FormatterUtil.shared.stringFromValue(value: cost, monetaryFormat: true, decimalPrecision: 2)
            break
        case .Dynamic:
            self.textCost.text = "~\(FormatterUtil.shared.stringFromValue(value: cost, monetaryFormat: true, decimalPrecision: 2))"
            break
        case .Ranged, .RangedStrict:
            if let rangeMinusPercent = service.rangeMinusPercent, let rangePlusPercent = service.rangePlusPercent {
                let cMinus = cost - (cost * Double(rangeMinusPercent / 100))
                let cPlus = cost + (cost * Double(rangePlusPercent / 100))
                self.textCost.text = "\(FormatterUtil.shared.stringFromValue(value: cMinus, monetaryFormat: true, decimalPrecision: 2))~\(FormatterUtil.shared.stringFromValue(value: cPlus, monetaryFormat: true, decimalPrecision: 2)))"
                
            } else {
                self.textCost.text = "- ~ -"
            }
        }
        
        // Adicionada verificação de "minimum fee"
        if let minimumFee = service.minimumFee {
            if (cost < minimumFee) {
                self.textCost.text = FormatterUtil.shared.stringFromValue(value: minimumFee, monetaryFormat: true, decimalPrecision: 2)
            }
        }
    }
    
    @IBAction func onButtonMinusTouched(_ sender: UIButton) {
        if quantity > 0 {
            quantity -= 1
        }
        updatePrice()
    }
    
    @IBAction func onButtonPlusTouched(_ sender: UIButton) {
        if quantity < service.maxQuantity {
            quantity += 1
            updatePrice()
        }
    }
}
