//
//  WalletViewControllerV3.swift
//  rider
//
//  Created by Victor Baleeiro on 29/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit
import Eureka


class WalletViewControllerV3: FormViewController {
    
    //MARK: - Properties
    var router: WalletRouter!
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    private let sectionCard = Section() { section in
        var header = HeaderFooterView<UILabel>(.class)
        header.height = { 60.0 }
        header.onSetupView = { view, _ in
            view.textColor = .gray
            view.text = "   Cartões"
            view.font = .boldSystemFont(ofSize: 20)
        }
        section.header = header
    }
    private var fecthingData = false {
        didSet {
            if fecthingData {
                sectionCard.removeAll()
                sectionCard.reload()
            }
        }
    }
    private var cards: [GetCardDetailResult] = [GetCardDetailResult]() {
        didSet {
            
            for card in cards {
                sectionCard
                    
                    <<< WalletRow {
                        $0.cellProvider = CellProvider(nibName: "WalletCell", bundle: Bundle.main)
                        
                    }.cellSetup { (cell, row) in
                        cell.height = { 80 }
                        cell.setupCell(card)
                        
                    }.onCellSelection { [weak self] _, _ in
                        self?.goToDetailCard(detailCard: card)
                    }
            }
            
            if cards.isEmpty {
                
                sectionCard
                    <<< WalletEmptyRow {
                        $0.cellProvider = CellProvider(nibName: "WalletEmptyViewCell", bundle: Bundle.main)
                        
                    }.cellSetup { (cell, row) in
                        cell.height = { 120 }
                    }
                    
                    <<< ButtonRow() {
                        $0.title = "Adicionar cartão"
                        
                    }.cellSetup { (cell, row) in
                        cell.height = { 80 }
                        
                    }.cellUpdate { cell, _ in
                        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                        cell.textLabel?.textColor = Color.orange.rgb_236_106_53
                        
                    }.onCellSelection { (cell, row) in
                        self.presentAddCard()
                    }
            }
        }
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupData()
        setupText()
    }
    
    
    //MARK: Setup
    private func setupLayout() {
        self.view.backgroundColor = .white
        form +++ sectionCard
    }
    
    private func setupData() {
        self.fetchCards()
    }
    
    private func setupText() {
        self.navigationItem.title = "Carteira"
    }
    
    
    //MARK: - RequestHttp
    private func fetchCards() {
        
        self.fecthingData = true
        guard let cpf = rider.cpf else {
            DialogBuilder.alertOnError(message: "Ocorreu um erro ao tentar buscar os dados.")
            return
        }
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        GetCard(cpf: cpf).execute() { result in
            defer {
                self.fecthingData = false
                LoadingOverlay.shared.hideOverlayView()
            }
            
            switch result {
            case .success(let response):
                self.cards = response.cards
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: - Actions
    private func goToDetailCard(detailCard: GetCardDetailResult) {
        self.router.presentNextController(card: detailCard, changeBlock: {(_ object: Any?, _ isChange: Bool) -> Void in
            if (isChange) {
                self.fetchCards()
            }
        })
    }
    
    private func presentAddCard() {
        let vc = WalletAddCardViewController()
        vc.onChangeBlock = {(_ object: Any?, _ isChange: Bool) -> Void in
            if (isChange) {
                self.fetchCards()
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}



