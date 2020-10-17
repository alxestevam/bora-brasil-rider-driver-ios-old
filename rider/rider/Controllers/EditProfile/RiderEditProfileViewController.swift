//
//  EditProfileViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Eureka
import SwiftyAttributes
import ImageRow
import Kingfisher

class RiderEditProfileViewController: FormViewController, VCWithBackButtonHandler {
    
    //MARK: Properties
    var downloading = false
    var rider: Rider!
    var acceptedTerms = false
    lazy var atualMask = TLCustomMaskUtil()
    var shouldBack = true
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        self.title = NSLocalizedString("Profile_Title", comment: "Profile's title")
        
        if !shouldBack {
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            
            guard
                let navigationController = self.navigationController,
                let gradientImage = CAGradientLayer.viewToImageGradient(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
                return
            }
            navigationController.navigationBar.barTintColor = UIColor(patternImage: gradientImage)
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    //MARK: Setup
    private func setupLayout() {
        
        form +++ Section(NSLocalizedString("Images", comment: "Profile's image section header"))
            <<< ImageRow() { row in
                row.tag = "profile_row"
                row.title = NSLocalizedString("Profile_Image", comment: "Profile's image field title")
                row.allowEditor = true
                row.sourceTypes = .All
                row.clearAction = .no
                if let address = rider.media?.address {
                    let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
                    ImageDownloader.default.downloadImage(with: url!, completionHandler:  { result in
                        switch result {
                        case .success(let value):
                            self.downloading = true
                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).value = value.image
                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).reload()
                            self.downloading = false
                        case .failure(let error):
                            print(error)
                        }
                    })
                }
                
            }.cellUpdate { cell, row in
                cell.accessoryView?.layer.cornerRadius = 17
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                
            }.onChange {
                if(!self.downloading) {
                    let data = $0.value?.jpegData(compressionQuality: 0.7)
                    $0.title = NSLocalizedString("Uploading_Wait", comment: "Uploading image state")
                    $0.disabled = true
                    $0.reload()
                    UpdateProfileImage(data: data!).execute() { result in
                        self.form.rowBy(tag: "profile_row")!.title = NSLocalizedString("Profile_Image", comment: "Profile's image field title")
                        self.form.rowBy(tag: "profile_row")!.disabled = false
                        self.form.rowBy(tag: "profile_row")!.reload()
                        switch result {
                        case .success(let response):
                            //                            DialogBuilder.alertOnSuccess(message: NSLocalizedString("Uploading_Successful", comment: "Uploading profile image successful alert message"))
                            self.rider.media = response
                            UserDefaultsConfig.user = try! self.rider.asDictionary()
                            
                        case .failure(let error):
                            error.showAlert()
                        }
                    }
                }
            }
            +++ Section(NSLocalizedString("Basic_Info", comment: "Profile Basic Info section header"))
            <<< PhoneRow(){
                $0.title = NSLocalizedString("Mobile_Number", comment: "Profile Mobile Number field title")
                $0.disabled = true
                $0.value = String(rider.mobileNumber!)
            }
            <<< EmailRow(){
                $0.title = NSLocalizedString("Email", comment: "Profile Email field title")
                $0.value = rider.email
            }.onChange {
                self.rider.email = $0.value
            }
            <<< TextRow(){
                $0.title = NSLocalizedString("Name", comment: "Profile Name field")
                $0.value = rider.firstName
                $0.cell.textField.autocapitalizationType = .words
                $0.placeholder = NSLocalizedString("First_Name", comment: "Profile First Name Field")
            }.onChange {
                self.rider.firstName = $0.value
            }
            <<< TextRow(){
                $0.title = " "
                $0.placeholder = NSLocalizedString("Last_Name", comment: "Profile Last Name field")
                $0.cell.textField.autocapitalizationType = .words
                $0.value = rider.lastName
            }.onChange {
                self.rider.lastName = $0.value
            }
            <<< TextRow(){
                $0.title = NSLocalizedString("Cpf", comment: "CPF field")
                $0.cell.textField.keyboardType = .numberPad
                $0.placeholder = NSLocalizedString("Cpf_Placeholder", comment: "CPF field")
                let formatted = atualMask.formatString(string: self.rider.cpf ?? "")
                $0.value = formatted
                if shouldBack {
                    $0.disabled = true
                }
    
            }.onChange { row in
                row.cell.textField.text = self.atualMask.formatString(string: row.value ?? "")
                let unmasked = self.atualMask.cleanText
                self.rider.cpf = unmasked
            }
            +++ Section(NSLocalizedString("Additional_Info", comment: "Profile's additional Info section"))
            <<< PushRow<String>() {
                $0.title = NSLocalizedString("Gender", comment: "Profile's gender field title")
                $0.selectorTitle = NSLocalizedString("Select_Gender", comment: "Profile's gender field selector title")
                let male = NSLocalizedString("Male", comment: "")
                let female = NSLocalizedString("Female", comment: "")
                let unspecified = NSLocalizedString("Unspecified", comment: "")
                $0.options = [male, female,unspecified]
                $0.value = (rider.gender.isNilOrEmpty || rider.gender == "unknown") ? NSLocalizedString("Unspecified", comment: "") : (rider.gender == "male") ? NSLocalizedString("Male", comment: "") : NSLocalizedString("Female", comment: "")
            }.onChange {
                let value = ($0.value == NSLocalizedString("Male", comment: "")) ? "male" : ($0.value == NSLocalizedString("Female", comment: "")) ? "female" : "unknown"
                self.rider.gender = value
            }
            <<< TextRow(){
                $0.title = NSLocalizedString("Address", comment: "Profile Address field title")
                $0.value = rider.address
            }.onChange {
                self.rider.address = $0.value
            }
            
            +++ Section(" ")
            <<< SwitchRow().cellSetup { cell, row in
                cell.height = {100}
                cell.textLabel?.numberOfLines = {0}()
                cell.switchControl.onTintColor = Color.orange.rgb_255_152_0
                row.value = self.acceptedTerms
            }.cellUpdate { cell, row in
                
                let attributedString = NSMutableAttributedString(string: NSLocalizedString("Terms", comment: "Profile Address field title"))
                let range = NSRange(location: 14, length: 34)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.orange.rgb_255_152_0, range: range)
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: range)
                
                cell.textLabel?.attributedText = attributedString
                cell.textLabel?.isUserInteractionEnabled = true
                
                // Create and add the Gesture Recognizer
                let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.openUrl(_:)))
                cell.textLabel?.addGestureRecognizer(guestureRecognizer)
                
            }.onChange {
                self.acceptedTerms = $0.value ?? false
            }
    }
    
    private func setupData() {
        rider = try! Rider(from: UserDefaultsConfig.user!)
        self.acceptedTerms = self.firstTime()
        atualMask.formattingPattern = "$$$.$$$.$$$-$$"
    }
    
    //MARK: Actions
    @IBAction func onSaveProfileClicked(_ sender: Any) {
        if validateData() {
            
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
            UpdateProfile(user: self.rider).execute() { result in
                defer { LoadingOverlay.shared.hideOverlayView() }

                switch result {
                case .success(_):
                    if self.shouldBack {
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    UserDefaultsConfig.user = try! self.rider.asDictionary()
                    
                case .failure(let error):
                    error.showAlert()
                }
            }
        }
    }
    
    @IBAction func openUrl(_ sender: Any) {
        if let url = URL(string: "https://meubbmu.com.br/static/media/BBMU_Termos_Condicoes.a4306ad8.pdf") {            
            UIApplication.shared.open(url)
        }
    }
    
    
    //MARK: Validate
    private func validateData() -> Bool {
        
        guard rider.media != nil else {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_Image", comment: "Profile Image error"))
            return false
        }
        
        let email = rider.email
        if email.isNilOrEmpty || !ValidatorUtil.shared.isEmailValid(email!) {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_Email", comment: "Profile Email error"))
            return false
        }
        
        if rider.firstName.isNilOrEmpty {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_First_Name", comment: "Profile First Name error"))
            return false
        }
        
        if rider.lastName.isNilOrEmpty {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_Last_Name", comment: "Profile Last Name error"))
            return false
        }
        
        let cpf = rider.cpf
        if cpf.isNilOrEmpty || !ValidatorUtil.shared.isCpfValid(cpf!) {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_Cpf", comment: "Profile CPF error"))
            return false
        }
        
        if !acceptedTerms {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Profile_Terms", comment: "Profile Terms error"))
            return false
        }
        
        return true
    }
    
    
    //MARK: VCWithBackButtonHandler
    public func shouldPopOnBackButton() -> Bool {
        if !shouldBack {
            DialogBuilder.alertOnError(message: NSLocalizedString("Error_Must_Edit", comment: "Must Edit error"))
        }
        
        return shouldBack
    }
    
    private func firstTime() -> Bool {

        guard let media = rider.media else {
            return false
        }
        
        if (media.address.isNilOrEmpty || rider.cpf.isNilOrEmpty || rider.email.isNilOrEmpty || rider.firstName.isNilOrEmpty || rider.lastName.isNilOrEmpty) {
            return false
        }
        
        return true
    }
}



