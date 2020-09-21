//
//  WaitingForPaymentViewController.swift
//  driver
//
//  Created by Manly Man on 1/1/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit
import Lottie

class WaitingForPaymentViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var lblValue: UILabel!
    var onChangeBlock: ((_ object: Any?, _ isChange: Bool) -> Void)? = nil
    var animationView: AnimationView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.onFinished), name: .serviceFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.onForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        //blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundView.addSubview(blurEffectView)
        animationView = AnimationView(name: "cash")
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .loop
        animationView.backgroundColor = .clear
        viewLoading.addSubview(animationView)
        animationView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        animationView.centerXAnchor.constraint(equalTo: self.viewLoading.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: self.viewLoading.centerYAnchor).isActive = true
        animationView.play()
        
        self.requestRefresh()
    }
    
    @objc func onForeground(_ notification: Notification) {
        self.requestRefresh()
    }
    
    @objc func onFinished(_ notification: Notification) {
        self.requestRefresh()
    }
    
    func refreshScreen() {
        
        let request = Request.shared
        self.lblValue.text = FormatterUtil.shared.stringFromValue(value: request.cost ?? 0.0, monetaryFormat: true, decimalPrecision: 2)
        
        switch request.status! {
        case .Finished, .WaitingForReview:
            
            self.dismiss(animated: true, completion: {
                if let compl = self.onChangeBlock { compl(nil, true) }
            })
            break
            
        default:
            break
        }
    }
    
    @objc private func requestRefresh() {
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                Request.shared = response.request
                self.refreshScreen()
                
            case .failure(_):
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
