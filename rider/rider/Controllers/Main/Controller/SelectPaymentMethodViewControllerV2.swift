//
//  SelectPaymentMethodViewControllerV2.swift
//  rider
//
//  Created by Victor Baleeiro on 09/10/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import UIKit
import PullUpController
import Eureka


protocol SelectPaymentMethodViewControllerV2Delegate: class{
    func paymentCardSelected(_ card: GetCardDetailResult)
    func paymentMoneySelected()
}

class SelectPaymentMethodViewControllerV2: PullUpController {
    
    enum InitialState {
        case contracted
        case expanded
    }
    
    var initialState: InitialState = .contracted
    
    // MARK: - IBOutlets
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var btnMoneyPay: GradientButton!
    @IBOutlet private weak var searchBoxContainerView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    @IBOutlet private weak var firstPreviewView: UIView!
    @IBOutlet private weak var secondPreviewView: UIView!
    @IBOutlet private weak var containerSelectCardView: UIView!
    weak var delegate: SelectPaymentMethodViewControllerV2Delegate?
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
        
        let controller = WalletRouter.build()
        controller.allowDelete = false
        controller.delegate = self
        controller.view.frame = self.containerSelectCardView.bounds;
        controller.willMove(toParent: self)
        self.containerSelectCardView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
    }
    
    private func setupData() {
        self.btnMoneyPay.addTarget(self, action: #selector(self.handleSelectMoney(_:)), for: .touchUpInside)
    }
    
    
    //MARK: - Action
    @objc func handleSelectCard() {
        removePullUpController(self, animated: true, completion: { _ in
            self.delegate?.paymentCardSelected(self.currentCard!)
        })
    }
    
    @objc func handleSelectMoney(_ sender: GradientButton) {
        removePullUpController(self, animated: true, completion: { _ in
            self.delegate?.paymentMoneySelected()
        })
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


// MARK: - IBOutlets
extension SelectPaymentMethodViewControllerV2: WalletViewControllerV3Delegate {
    func cardSelected(_ card: GetCardDetailResult) {
        self.currentCard = card
        self.handleSelectCard()
    }
}
