//
//  WalletDetailCardRouter.swift
//  rider
//
//  Created by Victor Baleeiro on 30/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

final class WalletDetailCardRouter: Storyboarded  {
    
    // MARK: - Properties
    static let storyboardName = StoryboardIdentifier.WalletDetail.key
    weak var viewController: WalletDetailCardViewController?
    
    
    //MARK: - Init
    static func build<T : WalletDetailCardViewController>() -> T {
        
        let router = WalletDetailCardRouter()
        let view = viewController()
        view.router = router
        router.viewController = view
        
        return view as! T
    }
    
    static func viewController() -> WalletDetailCardViewController {
        return storyboard.instantiateViewController()
    }
}


//  MARK: - BaseRouterProtocol
extension WalletDetailCardRouter {
    
}

