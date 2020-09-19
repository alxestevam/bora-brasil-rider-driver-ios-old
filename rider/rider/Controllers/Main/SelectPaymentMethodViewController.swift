//
//  SelectPaymentMethodViewController.swift
//  rider
//
//  Created by Victor Baleeiro on 18/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import PullUpController


protocol SelectPaymentMethodViewControllerDelegate: class{
    func paymentCardSelected(_ card: GetCardDetailResult)
}

class SelectPaymentMethodViewController: PullUpController {
    
    enum InitialState {
        case contracted
        case expanded
    }
    
    var initialState: InitialState = .contracted
    
    // MARK: - IBOutlets
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var btnMoneyPay: GradientButton!
    @IBOutlet private weak var btnAddCard: GradientButton!
    @IBOutlet private weak var searchBoxContainerView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    @IBOutlet private weak var firstPreviewView: UIView!
    @IBOutlet private weak var secondPreviewView: UIView!
    weak var delegate: SelectPaymentMethodViewControllerDelegate?
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    private var cards: [GetCardDetailResult] = [GetCardDetailResult]()
    private var currentCard: GetCardDetailResult? = nil

    var initialPointOffset: CGFloat {
        switch initialState {
        case .contracted:
            return (searchBoxContainerView?.frame.height ?? 0) + safeAreaAdditionalOffset
        case .expanded:
            return pullUpControllerPreferredSize.height
        }
    }
    
    public var portraitSize: CGSize = .zero
    public var landscapeFrame: CGRect = .zero
    
    private var safeAreaAdditionalOffset: CGFloat {
        hasSafeArea ? 20 : 0
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: secondPreviewView.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)
        
        self.setupLayout()
        self.setupData()
        self.setupText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 24
    }
    
    override func pullUpControllerWillMove(to stickyPoint: CGFloat) {
        print("will move to \(stickyPoint)")
    }
    
    override func pullUpControllerDidMove(to stickyPoint: CGFloat) {
        print("did move to \(stickyPoint)")
        if stickyPoint == (searchBoxContainerView?.frame.height ?? 0) + safeAreaAdditionalOffset {
            removePullUpController(self, animated: true, completion: nil)
        }
    }
    
    override func pullUpControllerDidDrag(to point: CGFloat) {
        print("did drag to \(point)")
    }
    
    //MARK: - Setup
    private func setupLayout() {
        self.view.backgroundColor = .white
        
        self.btnMoneyPay.firstColor = Color.green.rgb_129_199_132
        self.btnMoneyPay.secondColor = Color.green.rgb_56_142_60
        self.btnAddCard.firstColor = Color.orange.rgb_255_152_0
        self.btnAddCard.secondColor = Color.orange.rgb_236_106_53
        self.btnAddCard.isHidden = true
    }
    
    private func setupData() {
        self.fetchCards()
    }
    
    private func setupText() {
    
        self.btnAddCard.setTitle("ADICIONAR CARTÃO", for: .normal)
        self.btnAddCard.setTitle("ADICIONAR CARTÃO", for: .selected)
        self.btnAddCard.setTitleColor(.white, for: .normal)
        self.btnAddCard.setTitleColor(.white, for: .selected)
    }
    
    
    //MARK: - Action
    @IBAction func presentAddCard(_ sender: GradientButton) {
        let vc = WalletAddCardViewController()
        vc.onChangeBlock = {(_ object: Any?, _ isChange: Bool) -> Void in
            if (isChange) {
                self.fetchCards()
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func handleSelectCard(_ sender: UIButton) {
        removePullUpController(self, animated: true, completion: { _ in
            self.delegate?.paymentCardSelected(self.currentCard!)
        })
    }
    
    @IBAction func selectMoney(_ sender: GradientButton) {
        
    }
    
    
    //MARK: - RequestHttp
    private func fetchCards() {
        
        guard let cpf = rider.cpf else {
            DialogBuilder.alertOnError(message: "Ocorreu um erro ao tentar buscar os dados.")
            return
        }
        
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        GetCard(cpf: cpf).execute() { result in
            defer {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            switch result {
            case .success(let response):
                self.cards = response.cards
                self.btnAddCard.isHidden = true
                
                if let card = self.cards.first {
                    
                    // Creating a Credit Card object
                    self.currentCard = card
                    let cardObj = YRPaymentCreditCard(type: .custom(UIImage()), isEditing: false)
                    
                    // Setting Credit Card position
                    self.view.addSubview(cardObj)
                    cardObj.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    cardObj.topAnchor.constraint(equalTo: self.btnMoneyPay.bottomAnchor, constant: 20).isActive = true
                    cardObj.heightAnchor.constraint(equalToConstant: 160).isActive = true
                    cardObj.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24).isActive = true
                
                    // Data
                    cardObj.cardNumber = "**** **** **** \(card.last4Digits ?? "")"
                    cardObj.cardHolderName = card.holderName
                    cardObj.cardValidity = (card.expirationMonth?.count == 1) ? "0\(card.expirationMonth ?? "00")/\(card.expirationYear ?? "00")" : "\(card.expirationMonth ?? "00")/\(card.expirationYear ?? "00")"
                    
                    // Layout
                    let gradientImage = CAGradientLayer.viewToImageGradient(on: self.view)
                    cardObj.backgroundColor = UIColor(patternImage: gradientImage!)
                    cardObj.layoutSubviews()
                    cardObj.layoutIfNeeded()
                    
                    let btnAction = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 48, height: 160))
                    cardObj.addSubview(btnAction)
                    cardObj.bringSubviewToFront(btnAction)
                    btnAction.addTarget(self, action: #selector(self.handleSelectCard(_:)), for: .touchUpInside)
                    btnAction.backgroundColor = .clear
                    btnAction.layoutSubviews()
                    btnAction.layoutIfNeeded()
                }
                
            case .failure(let error):
                print(error)
                self.btnAddCard.isHidden = false
            }
        }
    }
    
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return portraitSize
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return landscapeFrame
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        switch initialState {
        case .contracted:
            return [firstPreviewView.frame.maxY]
        case .expanded:
            return [searchBoxContainerView.frame.maxY + safeAreaAdditionalOffset, firstPreviewView.frame.maxY]
        }
    }
    
    override var pullUpControllerBounceOffset: CGFloat {
        return 20
    }
    
    override func pullUpControllerAnimate(action: PullUpController.Action,
                                          withDuration duration: TimeInterval,
                                          animations: @escaping () -> Void,
                                          completion: ((Bool) -> Void)?) {
        switch action {
        case .move:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        default:
            UIView.animate(withDuration: 0.3,
                           animations: animations,
                           completion: completion)
        }
    }
}


extension UIViewController {
    var hasSafeArea: Bool {
        guard
            #available(iOS 11.0, tvOS 11.0, *)
        else {
            return false
        }
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}

enum VerticalLocation: String {
    case bottom
    case top
}
