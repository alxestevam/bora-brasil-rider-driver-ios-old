//
//  WalletRouter.swift
//  rider
//
//  Created by Victor Baleeiro on 29/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//


final class WalletRouter: Storyboarded  {
    
    // MARK: - Properties
    static let storyboardName = StoryboardIdentifier.Wallet.key
    weak var viewController: WalletViewControllerV3?
    
    
    //MARK: - Init
    static func build<T : WalletViewControllerV3>() -> T {
        
        let router = WalletRouter()
        let view = viewController()
        view.router = router
        router.viewController = view
        
        return view as! T
    }
    
    static func viewController() -> WalletViewControllerV3 {
        return storyboard.instantiateViewController()
    }
}


//  MARK: - BaseRouterProtocol
extension WalletRouter {
    
    func presentNextController(card: GetCardDetailResult, changeBlock: ((_ object: Any?, _ isChange: Bool) -> Void)?) {
        let vc = WalletDetailCardRouter.build()
        vc.card = card
        vc.onChangeBlock = changeBlock
        viewController?.present(vc, animated: true, completion: nil)
    }
}

