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
    }
    
    
    // MARK: - Setup
    private func setupLayout() {
        self.viewContent.backgroundColor = .white
    }
    
    func setupData(_ request: Request) {
        let source = request.addresses?.first ?? "Não identificado"
        let destination = request.addresses?.last ?? "Não identificado"
        lblSource.text = source
        lblDestination.text = destination
    }
}
