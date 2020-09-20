//
//  ReviewStarCell.swift
//  rider
//
//  Created by Victor Baleeiro on 20/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import Cosmos


// MARK: - Delegate
@objc protocol ReviewStarCellDelegate: class {
    func selectedStar(_ value: Int)
}


class ReviewStarCell: UITableViewCell {

    // MARK: - Propriedades
    weak var starDelegate: ReviewStarCellDelegate?
    @IBOutlet weak var viewStars: CosmosView!
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
        self.viewContent.backgroundColor = .white
        self.viewStars.settings.fillMode = .full
        self.viewStars.settings.emptyColor = UIColor.gray.withAlphaComponent(0.6)
        self.viewStars.settings.emptyBorderColor = .clear
        self.viewStars.settings.filledColor = Color.orange.rgb_236_106_53
        
    }
    
    private func setupData() {
        self.viewStars.rating = 0
        self.viewStars.didFinishTouchingCosmos = { rating in
            self.starDelegate?.selectedStar(Int(rating))
        }
    }
    
    private func setupText() {
        
    }
}
