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
    private var estimate: EstimateModel!
    private var discountUF: Double!
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
    
    func initialize(discountUF: Double, estimate: EstimateModel, service: Service, distance: Int, duration: Int, currency: String) {
        self.service = service
        self.estimate = estimate
        self.discountUF = discountUF
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
    
    func initialize(discountUF: Double, estimate: EstimateModel, service: Service, fareResult: Double, feeEstimationMode: FeeEstimationMode, currency: String) {
        self.service = service
        self.estimate = estimate
        self.discountUF = discountUF
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
            updatePriceDynamic()
            break
        case .Ranged, .RangedStrict:
            if let rangeMinusPercent = service.rangeMinusPercent, let rangePlusPercent = service.rangePlusPercent {
                let cMinus = cost - (cost * Double(rangeMinusPercent / 100))
                let cPlus = cost + (cost * Double(rangePlusPercent / 100))
                self.textCost.text = "\(FormatterUtil.shared.stringFromValue(value: cMinus, monetaryFormat: true, decimalPrecision: 2))~\(FormatterUtil.shared.stringFromValue(value: cPlus, monetaryFormat: true, decimalPrecision: 2)))"
                
            } else {
                self.textCost.text = "-"
            }
        }
        
        // Adicionada verificação de "minimum fee"
        if let minimumFee = service.minimumFee {
            if (cost < minimumFee) {
                self.textCost.text = FormatterUtil.shared.stringFromValue(value: minimumFee, monetaryFormat: true, decimalPrecision: 2)
            }
        }
    }
    
    private func updatePriceDynamic() {
        let cost: Double = fareResult*service.multiplicationFactor //service.baseFare
        
        switch service.serviceType {
        case .Gold:
            self.textCost.text = FormatterUtil.shared.stringFromValue(value: getValueEstimate(serviceType: service.serviceType), monetaryFormat: true, decimalPrecision: 2)
            
        case .Executive:
            self.textCost.text = FormatterUtil.shared.stringFromValue(value: getValueEstimate(serviceType: service.serviceType), monetaryFormat: true, decimalPrecision: 2)
            
        case .Premium:
            self.textCost.text = FormatterUtil.shared.stringFromValue(value: getValueEstimate(serviceType: service.serviceType), monetaryFormat: true, decimalPrecision: 2)
            
        default:
            self.textCost.text = FormatterUtil.shared.stringFromValue(value: cost, monetaryFormat: true, decimalPrecision: 2)
        }
    }
    
    private func getValueEstimate(serviceType: ServiceType) -> Double {
        var result = fareResult*service.multiplicationFactor
        
        switch serviceType {
        case .Gold:
            result = getValueForDriver(typeDriver: "UberX")
        case .Executive:
            result = getValueForDriver(typeDriver: "Black")
        case .Premium:
            result = getValueForDriver(typeDriver: "Black Bag")
        default:
            result = fareResult*service.multiplicationFactor
        }
        
        return result
    }
    
    private func getValueForDriver(typeDriver: String) -> Double {
        var result = fareResult*service.multiplicationFactor
        let priceEstimate = estimate.prices.filter { $0.localized_display_name == typeDriver }
        
        if (!priceEstimate.isEmpty) {
            let discount = 100 - Int(discountUF)
            let lowPrice = Double(discount) * (priceEstimate[0].low_estimate ?? 0.0)
            result = lowPrice / 100
        }
        
        return result
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
