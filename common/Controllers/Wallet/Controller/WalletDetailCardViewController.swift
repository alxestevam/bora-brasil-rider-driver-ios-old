//
//  WalletDetailCardViewController.swift
//  rider
//
//  Created by Victor Baleeiro on 30/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit
import Eureka


class WalletDetailCardViewController: FormViewController {
    
    //MARK: - Properties
    var router: WalletDetailCardRouter!
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    var onChangeBlock: ((_ object: Any?, _ isChange: Bool) -> Void)? = nil
    var card: GetCardDetailResult? = nil
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    
    //MARK: Setup
    private func setupLayout() {
        form +++ Section()
            
            <<< WalletCardRow {
                $0.cellProvider = CellProvider(nibName: "WalletViewCardCellV2", bundle: Bundle.main)
                
            }.cellSetup { (cell, row) in
                cell.height = { 240 }
                guard let c = self.card else { return }
                cell.setupCell(c)
            }
            
            <<< ButtonRow() {
                $0.title = "Excluir cartão"
                
            }.cellSetup { (cell, row) in
                cell.height = { 80 }
                
            }.cellUpdate { cell, _ in
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                cell.textLabel?.textColor = Color.red.rgb_255_0_0
                
            }.onCellSelection { (cell, row) in
                
                let alert = UIAlertController(title: "Excluir cartão", message: "Deseja realmente excluir o cartão?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Excluir", style: .destructive, handler: { _ in
                    self.deleteCard()
                }))
                self.present(alert, animated: true)
            }
    }
    
    
    //MARK: - RequestHttp
    private func deleteCard() {
    
        let messageError = "Ocorreu um erro ao tentar excluir o cartão."
        guard let cpf = rider.cpf else {
            DialogBuilder.alertOnError(message: messageError)
            return
        }
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        DeleteCard(cpf: cpf).execute() { result in
            
            switch result {
            case .success( _):
                
                LoadingOverlay.shared.hideOverlayView()
                DialogBuilder.alertOnSuccess(message: NSLocalizedString("O cartão foi excluído com sucesso!", comment: ""))
                if let compl = self.onChangeBlock { compl(nil, true) }
                self.dismiss(animated: true, completion: nil)
                
            case .failure( _):
                LoadingOverlay.shared.hideOverlayView()
                DialogBuilder.alertOnError(message: messageError)
            }
        }
    }
}
