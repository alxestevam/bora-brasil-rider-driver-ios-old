//
//  WalletAddCardViewController.swift
//  rider
//
//  Created by Victor Baleeiro on 13/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit


class WalletAddCardViewController: UIViewController {
    
    //MARK: Properties
    var payment: YRPayment!
    var card: YRPaymentCreditCard!
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    var onChangeBlock: ((_ object: Any?, _ isChange: Bool) -> Void)? = nil

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupData()
        setupText()
    }
    
    
    //MARK: - Setup
    private func setupLayout() {
        
    }
    
    private func setupData() {
        
        // Creating a Credit Card object
        card = YRPaymentCreditCard(type: .custom(UIImage()), isEditing: true)
    
        // Creating Payment object with our card
        payment = YRPayment(creditCard: card, delegate: self)
        
        // Setting Credit Card position
        view.addSubview(card)
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        card.heightAnchor.constraint(equalToConstant: 160).isActive = true
        card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        
        // Setting textFields position and size (can be done using storyboards)
        setupViews()
        
        // Linking textFields to Payment object
        payment.numberTextField = numberTF
        payment.holderNameTextField = nameTF
        payment.validityTextField = validityTF
        payment.cryptogramTextField = cryptoTF
    }
    
    private func setupText() {
        
    }
    
    
    // MARK: textFields created programmatically (can be done using storyboards too)
    let numberTF: UITextField = {
        let textF = CustomTextField()
        textF.placeholder = "Nr. Cartão: (9999 9999 9999 9999)"
        return textF
    }()
    
    let nameTF: UITextField = {
        let textF = CustomTextField()
        textF.placeholder = "NOME (PASSAGEIRO BORA BRASIL)"
        return textF
    }()
    
    let validityTF: UITextField = {
        let textF = CustomTextField()
        textF.placeholder = "Validade: (10/20)"
        
        return textF
    }()
    
    let cryptoTF: UITextField = {
        let textF = CustomTextField()
        textF.placeholder = "Código validador: (123)"
        return textF
    }()
    
    let btnAddCard: UIButton = {
        let btn = UIButton(type: .system)
        btn.isEnabled = false
        btn.backgroundColor = Color.orange.rgb_236_106_53
        btn.alpha = 0.4
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("ADICIONAR CARTÃO", for: .normal)
        btn.setTitle("ADICIONAR CARTÃO", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.addTarget(self, action:#selector(addCard(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    // MARK: Views
    func setupViews() {
        view.addSubview(numberTF)
        numberTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        numberTF.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 30).isActive = true

        view.addSubview(nameTF)
        nameTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTF.topAnchor.constraint(equalTo: numberTF.bottomAnchor, constant: 10).isActive = true
        
        view.addSubview(validityTF)
        validityTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        validityTF.topAnchor.constraint(equalTo: nameTF.bottomAnchor, constant: 10).isActive = true
        
        view.addSubview(cryptoTF)
        cryptoTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cryptoTF.topAnchor.constraint(equalTo: validityTF.bottomAnchor, constant: 10).isActive = true
        
        view.addSubview(btnAddCard)
        btnAddCard.heightAnchor.constraint(equalToConstant: 56).isActive = true
        btnAddCard.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        btnAddCard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnAddCard.topAnchor.constraint(equalTo: cryptoTF.bottomAnchor, constant: 40).isActive = true
    }
    
    
    //MARK: Action
    @IBAction func addCard(_ sender: UIButton) {
        self.view.endEditing(true)
        addCard()
    }
    
    
    //MARK: RequestHtt
    private func addCard() {
        guard let cpf = rider.cpf else {
            DialogBuilder.alertOnError(message: "Ocorreu um erro ao tentar enviar os dados.")
            return
        }
        
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        let month = String(self.card.cardValidity[NSRange(location: 0, length: 2)])
        let year = String(self.card.cardValidity[NSRange(location: 3, length: 2)])
        AddCard(cpf: cpf, holderName: self.card.cardHolderName ?? "", expirationMonth: month, expirationYear: year, cardNumber: self.card.cardNumber ?? "", securityCode: self.card.cardCryptogram ?? "").execute() { result in
          
            switch result {
            case .success( _):
                LoadingOverlay.shared.hideOverlayView()
                if let compl = self.onChangeBlock { compl(nil, true) }
                self.dismiss(animated: true, completion: nil)
                
            case .failure( _):
                LoadingOverlay.shared.hideOverlayView()
                DialogBuilder.alertOnError(message: "Ocorreu um erro ao tentar cadastrar o cartão. Por favor, verifique os dados e tente novamente.")
            }
        }
    }
    
    
    // MARK: Touches events
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        numberTF.resignFirstResponder()
        nameTF.resignFirstResponder()
        validityTF.resignFirstResponder()
        cryptoTF.resignFirstResponder()
    }
}

// MARK: Simple custom textField
class CustomTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        let bar = CALayer()
        bar.backgroundColor = UIColor.gray.cgColor
        bar.frame = CGRect(x: 3, y: 38, width: 300, height: 1.5)
        layer.addSublayer(bar)
        textAlignment = .center
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: YRPaymentDelegate
extension WalletAddCardViewController: YRPaymentDelegate {
    func allValidated() {
        self.btnAddCard.isEnabled = true
        self.btnAddCard.alpha = 1
    }
    
    func notValidated() {
        self.btnAddCard.isEnabled = false
        self.btnAddCard.alpha = 0.4
    }
}

