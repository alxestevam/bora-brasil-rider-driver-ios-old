//
//  ReviewTextFieldCell.swift
//  rider
//
//  Created by Victor Baleeiro on 19/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Delegate
@objc protocol ReviewTextFieldCellDelegate: class {
    func textInput(_ text: String)
}


class ReviewTextFieldCell: UITableViewCell {

    // MARK: - Propriedades
    weak var textDelegate: ReviewTextFieldCellDelegate?
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var lblCountText: UILabel!
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
        self.txtComment.placeholder = "Escreva aqui o seu comentário"
        self.txtComment.autocapitalizationType = .sentences
        self.txtComment.delegate = self
        self.txtComment.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    private func setupText() {
        self.lblCountText.text = "0/250"
    }
}


// MARK: - UITextFieldDelegate
extension ReviewTextFieldCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 250
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textChanged(_ textField: UITextField) {
        let count = textField.text?.count ?? 0
        self.lblCountText.text = "\(count)/250"
        self.textDelegate?.textInput(textField.text ?? "")
    }
}

