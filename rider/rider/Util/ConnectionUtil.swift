//
//  ConnectionUtil.swift
//  rider
//
//  Created by Victor Baleeiro on 09/10/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Toast_Swift

class ConnectionUtil {
    
    static let shared = ConnectionUtil()
    private var reachability: Reachability!
    private var previousState: Reachability.Connection = .none
    lazy var dimmedView = UIView()

    
    func observeReachability() {
        
        do {
            self.reachability = try Reachability()
            NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
            try self.reachability.startNotifier()
        }
        catch let error {
            Crashlytics.crashlytics().record(error: error)
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            if previousState == .unavailable {
                showMessageConnection(connected: true)
            }
            self.enableInteractionView(true)
            previousState = .cellular
            break
        case .wifi:
            print("Network available via WiFi.")
            if previousState == .unavailable {
                showMessageConnection(connected: true)
            }
            self.enableInteractionView(true)
            previousState = .wifi
            break
        case .none:
            print("Network is not available.")
            self.enableInteractionView(true)
            previousState = .unavailable
            break
        case .unavailable:
            print("Network is unavailable.")
            previousState = .unavailable
            self.enableInteractionView(false)
            showMessageConnection()
            break
        }
    }
    
    private func showMessageConnection(connected: Bool = false) {
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let view = app.window {
              
            let message = (connected) ? "Conectado com a intenet!" : "Sem conexão com a internet!"
            
            view.hideAllToasts()
            
            // toast presented with multiple options and with a completion closure
            view.makeToast(message, duration: (connected) ? 3.0 : .infinity, position: .top, title: "Atenção", image: nil) {
                didTap in
                    if didTap {
                        print("completion from tap")
                    } else {
                        print("completion without tap")
                    }
            }
        }
    }
    
    private func enableInteractionView(_ isEnable: Bool) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let view = app.window {
            
            // Backdrop
            if (!isEnable) {
                self.dimmedView.backgroundColor = .black
                self.dimmedView.alpha = 0.44
                view.addSubview(dimmedView)
                self.dimmedView.frame = view.bounds
                
            } else {
                self.dimmedView.removeFromSuperview()
            }
            
            view.isUserInteractionEnabled = isEnable
        }
    }
}
