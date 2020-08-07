//
//  EditProfileViewController.swift
//  Driver
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

import Kingfisher

class EditProfileViewController: FormViewController {
    lazy var driver = try! Driver(from: UserDefaultsConfig.user!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.refreshScreeen), name: .connectedAfterForeground, object: nil)
        form
            +++ Section(NSLocalizedString("Status", comment: "Profile's status section header"))
            <<< LabelRow() {
                $0.title = NSLocalizedString("Note", comment: "")
                $0.disabled = true
                $0.value = driver.status!.rawValue
            }
            <<< LabelRow() {
                $0.title = NSLocalizedString("Status", comment: "")
                $0.disabled = true
                $0.value = driver.documentsNote
            }
            +++ Section(NSLocalizedString("Images", comment: "Profile's image section header"))
            <<< ImageRow() {
                $0.tag = "profile_row"
                $0.title = NSLocalizedString("Profile_Image", comment: "Profile's image field title")
                $0.clearAction = .no
                if let address = driver.media?.address {
                    let url = URL(string: Config.Backend + address.replacingOccurrences(of: " ", with: "%20"))
                    ImageDownloader.default.downloadImage(with: url!) { result in
                        switch result {
                        case .success(let value):
                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).value = value.image
                            (self.form.rowBy(tag: "profile_row")! as! ImageRow).reload()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                $0.onChange {
                    self.uploadMedia(type: "driver image", dataImage: ($0.value?.jpegData(compressionQuality: 1))!) {
                        
                    }
                }
            }
            .cellUpdate { cell, row in
                cell.accessoryView?.layer.cornerRadius = 17
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            }
            +++ Section(NSLocalizedString("Personal_Info", comment: "Profile Personal Info section header"))
            <<< PhoneRow() {
                $0.title = NSLocalizedString("Mobile_Number", comment: "Profile Mobile Number field title")
                $0.disabled = true
                $0.value = "\(driver.mobileNumber ?? 0)"
            }
            <<< EmailRow() {
                $0.title = NSLocalizedString("Email", comment: "Profile Email field title")
                $0.value = driver.email
            }
            <<< TextRow() {
                $0.title = NSLocalizedString("Name", comment: "Profile Name field")
                $0.value = driver.firstName
                $0.placeholder = NSLocalizedString("First_Name", comment: "Profile First Name Field")
            }.onChange {
                self.driver.firstName = $0.value
            }
            <<< TextRow() {
                $0.title = " "
                $0.placeholder = NSLocalizedString("Last_Name", comment: "Profile Last Name field")
                $0.value = driver.lastName
            }.onChange {
                self.driver.lastName = $0.value
            }
            <<< PushRow<String>() {
                $0.title = NSLocalizedString("Gender", comment: "Profile's gender field title")
                $0.selectorTitle = NSLocalizedString("Select_Gender", comment: "Profile's gender field selector title")
                let male = NSLocalizedString("Male", comment: "")
                let female = NSLocalizedString("Female", comment: "")
                let unspecified = NSLocalizedString("Unspecified", comment: "")
                $0.options = [male, female,unspecified]
                $0.value = driver.gender    // initially selected
            }.onChange { self.driver.gender = $0.value! as String }
            <<< TextRow() {
                $0.title = NSLocalizedString("Address", comment: "Profile Address field title")
                $0.value = driver.address
            }.onChange { self.driver.address = $0.value }
            <<< TextRow() {
                $0.title = NSLocalizedString("Bank_Account_Number", comment: "Profile Bank account field title")
                $0.value = driver.accountNumber
                $0.onChange() { self.driver.accountNumber = $0.value }
            }
            <<< TextRow() {
                $0.title = NSLocalizedString("Car_Plate", comment: "Profile Car plate field title")
                $0.value = driver.carPlate
                $0.onChange() { self.driver.carPlate = $0.value }
            }
            <<< TextRow(){
                $0.title = NSLocalizedString("Certificate_Number", comment: "Profile Certificate Number field title")
                $0.value = driver.certificateNumber
                $0.onChange() { row in
                    self.driver.certificateNumber = row.value
                }
            }
            
            +++ Section(header: NSLocalizedString("Services", comment: "Profile's Services Info section"), footer: NSLocalizedString("Select_Services", comment: "Profile's Services Footer"))
            <<< MultipleSelectorRow<Service>() {
                $0.title = NSLocalizedString("Services", comment: "")
                $0.options = try! [Service](from: UserDefaultsConfig.services!)
                $0.onChange {
                    self.driver.services = Array($0.value!)
                }
            }
            +++ Section(header: NSLocalizedString("Documents", comment: "Profile's Documents Info section"), footer: NSLocalizedString("After_Approval", comment: "Profile's Documents Footer"))
            <<< ImageRow() {
                $0.title = "ID"
                $0.onChange {
                    self.uploadMedia(type: "document", dataImage: ($0.value?.jpegData(compressionQuality: 1))!) {
                        
                    }
                }
            }
            <<< ImageRow() {
                $0.title = NSLocalizedString("Driver_License", comment: "")
                $0.onChange {
                    self.uploadMedia(type: "document", dataImage: ($0.value?.jpegData(compressionQuality: 1))!) {
                        
                    }
                }
            }
            <<< ImageRow() {
                $0.title = NSLocalizedString("Picture_of_Vehicle", comment: "")
                $0.onChange {
                    self.uploadMedia(type: "document", dataImage: ($0.value?.jpegData(compressionQuality: 1))!) {
                        
                    }
                }
        }
    }
    
    @IBAction func onSaveButtonClicked(_ sender: UIBarButtonItem) {
        Register(jwtToken: UserDefaultsConfig.jwtToken!, driver: driver).execute() { result in
            switch result {
            case .success(_):
                let dialog = DialogBuilder.getDialogForMessage(message: NSLocalizedString("Registration_Successful", comment: "Registration successful")) { result in
                    self.dismiss(animated: true, completion: nil)
                }
                self.present(dialog, animated: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func uploadMedia(type: String, dataImage: Data, completionHandler: @escaping (() -> Void)) {
        let url = URL(string: "\(Config.Backend)driver/upload")!
        var request = URLRequest(url: url)
        request.setValue(driver.mobileNumber!.description, forHTTPHeaderField: "number")
        request.setValue(type, forHTTPHeaderField: "type")
        request.httpMethod = "POST"
        let boundary:String = "Boundary-\(UUID().uuidString)"
        request.timeoutInterval = 60
        request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=----\(boundary)"]
        var data: Data = Data()
        data.append("------\(boundary)\r\n")
        //Here you have to change the Content-Type
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"d.png\"\r\n")
        data.append("Content-Type: application/YourType\r\n\r\n")
        data.append(dataImage)
        data.append("\r\n")
        data.append("------\(boundary)--")
        
        request.httpBody = data
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    completionHandler()
                }
            }).resume()
        }
    }
    
    @objc func refreshScreeen() {
        GetRegisterInfo(jwtToken: UserDefaultsConfig.jwtToken!).execute() { result in
            switch result {
            case .success(let response):
                UserDefaultsConfig.user = try! response.driver.asDictionary()
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
extension Data{
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
