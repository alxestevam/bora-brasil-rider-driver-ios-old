//
//  NavigationMenuViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit

import Kingfisher

class NavigationMenuViewController : MenuViewController {
    
    //MARK: Properties
    let kCellReuseIdentifier = "MenuCell"
    let menuItems = ["Main"]
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCredit: UILabel!
    @IBOutlet weak var lblVersion: UILabel!

    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVersion()
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.clipsToBounds = true
        imageUser.layer.borderColor = UIColor.white.cgColor
        imageUser.layer.borderWidth = 3.0
        
        let gradientImage = CAGradientLayer.viewToImageGradient(on: self.view)
        self.view.backgroundColor = UIColor(patternImage: gradientImage!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = try! Rider(from: UserDefaultsConfig.user!)
        if let riderImage = user.media?.address {
            let processor = DownsamplingImageProcessor(size: imageUser.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: imageUser.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + riderImage.replacingOccurrences(of: " ", with: "%20"))
            imageUser.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ], completionHandler:  { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        labelName.text = "\(user.firstName == nil ? "" : user.firstName!) \(user.lastName == nil ? "" : user.lastName!)"
        labelCredit.text = "\(user.mobileNumber!)"
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func onTravelsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TripHistory") as? TripHistoryCollectionViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    @IBAction func onProfileClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showEditProfile", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onWalletClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
//        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletV2") as? WalletViewControllerV2 {
//            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
//            menuContainerViewController.hideSideMenu()
//        }
        let vc = WalletRouter.build()
        (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
        menuContainerViewController.hideSideMenu()
    }
    
//    @IBAction func onCouponsClicked(_ sender: UIButton) {
//        guard let menuContainerViewController = self.menuContainerViewController else {
//            return
//        }
//        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showCoupons", sender: nil)
//        menuContainerViewController.hideSideMenu()
//    }
    
    @IBAction func onPromotionsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showPromotions", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onTransactionsClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Transactions") as? TransactionsCollectionViewController {
            (menuContainerViewController.contentViewControllers[0] as! UINavigationController).pushViewController(vc, animated: true)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    @IBAction func onFavoritesClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showFavorites", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onAboutClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        menuContainerViewController.contentViewControllers[0].performSegue(withIdentifier: "showAbout", sender: nil)
        menuContainerViewController.hideSideMenu()
    }
    
    @IBAction func onExitClicked(_ sender: UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
            self.dismiss(animated: true, completion: nil)
            menuContainerViewController.hideSideMenu()
        }
    }
    
    private func setupVersion() {
        let version = UIApplication.appVersion ?? ""
        let build = UIApplication.appBuild
        var environment = ""
        
        #if DEBUG
            environment += "D"
        #elseif STAG
            environment += "S"
        #elseif PROD || RELEASE
            environment += "P"
        #endif
        
        self.lblVersion.text = "Versão: " + version + " - " + build + " - " + environment
        self.lblVersion.textAlignment = .left
        self.lblVersion.textColor = .white
        self.lblVersion.font = UIFont.systemFont(ofSize: 14)
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}
