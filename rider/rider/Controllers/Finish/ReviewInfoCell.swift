//
//  ReviewInfoCell.swift
//  rider
//
//  Created by Victor Baleeiro on 20/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


class ReviewInfoCell: UITableViewCell {

    // MARK: - Propriedades
    @IBOutlet weak var lblTitleSource: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblTitleDestination: UILabel!
    @IBOutlet weak var lblDestination: UILabel!
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
    }
    
    private func setupData() {
        
    }
    
    private func setupText() {
        
    }
}
