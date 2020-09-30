//
//  WalletViewControllerV2.swift
//  rider
//
//  Created by Victor Baleeiro on 10/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit


@available(*, deprecated, message: "Use WalletViewControllerV3 instead")
class WalletViewControllerV2: UIViewController {
    
    //MARK: - Properties
    @IBOutlet fileprivate weak var viewContent: UIView!
    @IBOutlet fileprivate weak var viewHeader: UIView!
    @IBOutlet fileprivate weak var tbvCards: UITableView!
    @IBOutlet fileprivate weak var btnAddCard: UIButton!
    private var wasLoaded: Bool = false
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    private var cards: [GetCardDetailResult] = [GetCardDetailResult]()

    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupData()
        setupText()
    }
    
    
    //MARK: Setup
    private func setupLayout() {
        self.viewContent.backgroundColor = .white
        self.viewHeader.backgroundColor = .white
        self.tbvCards.backgroundColor = .white
        self.btnAddCard.backgroundColor = Color.orange.rgb_236_106_53
        self.tbvCards.isScrollEnabled = false
        self.tbvCards.separatorColor = .clear
    }
    
    private func setupData() {
        self.tbvCards.delegate = self
        self.tbvCards.dataSource = self
        self.fetchCards()
    }
    
    private func setupText() {
        self.btnAddCard.setTitle("ADICIONAR CARTÃO", for: .normal)
        self.btnAddCard.setTitle("ADICIONAR CARTÃO", for: .selected)
        self.btnAddCard.setTitleColor(.white, for: .normal)
        self.btnAddCard.setTitleColor(.white, for: .selected)
        self.navigationItem.title = "Carteira"
    }
    
    
    //MARK: - RequestHttp
    private func fetchCards() {
        
        self.wasLoaded = false
        guard let cpf = rider.cpf else {
            DialogBuilder.alertOnError(message: "Ocorreu um erro ao tentar buscar os dados.")
            return
        }
        
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        GetCard(cpf: cpf).execute() { result in
            defer {
                self.wasLoaded = true
                LoadingOverlay.shared.hideOverlayView()
                self.tbvCards.reloadData()
            }
            
            switch result {
            case .success(let response):
                self.cards = response.cards
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: Action
    @IBAction func presentAddCard(_ sender: UIButton) {
        let vc = WalletAddCardViewController()
        vc.onChangeBlock = {(_ object: Any?, _ isChange: Bool) -> Void in
            if (isChange) {
                self.fetchCards()
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}


//MARK: UITableViewDelegate && UITableViewDataSource
extension WalletViewControllerV2: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.cards.count == 0 {
            if wasLoaded {
                tableView.setEmptyView(title: "Oops! Nenhum cartão registrado", message: "Clique em Adicionar Cartão para cadastrar")
                self.btnAddCard.isHidden = false
                
            } else {
                self.btnAddCard.isHidden = true
            }
            
            return 0
        }
        else {
            self.btnAddCard.isHidden = true
            tableView.restore()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCard", for: indexPath) as! WalletViewCardCell
        let card = cards[indexPath.row]
        
        cell.setupCard(card)
        return cell
    }
}
