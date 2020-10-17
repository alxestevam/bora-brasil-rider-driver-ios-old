//
//  AboutViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Eureka

class AboutViewController:FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(header: NSLocalizedString("Info", comment: ""), footer: NSLocalizedString("© 2020 Bora Brasil Apps All rights reserved.", comment: ""))
            <<< LabelRow(){
                $0.title = NSLocalizedString("Application_Name", comment: "")
                $0.value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            }
            <<< LabelRow(){
                $0.title = NSLocalizedString("Version", comment: "")
                $0.value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            }
            <<< LabelRow(){
                $0.title = NSLocalizedString("Website", comment: "")
                $0.value = "https://www.borabrasilmobilidade.com.br/"
            }
    }
}
