//
//  FinishedServiceViewController.swift
//  rider
//
//  Copyright © 2019 minimal. All rights reserved.
//

import UIKit

import Eureka

class FinishedServiceViewController: FormViewController {
    public var travel: Request = Request.shared
    private var score: Int?
    private var review: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("Info", comment: ""))
            <<< LabelRow() { row in
                row.title = NSLocalizedString("Final_Fee", comment: "")
                row.value = MyLocale.formattedCurrency(amount: travel.costAfterCoupon!, currency: travel.currency!)
            }
            /*<<< PushRow<String>() {
            $0.title = NSLocalizedString("Payment Method", comment: "Payment Method")
            $0.selectorTitle = NSLocalizedString("Select Your preffered payment Method", comment: "Title of paymnet method selection in finish travel.")
            $0.options = ["Braintree","Cash","Stripe"]
            }//.onChange {  }
            <<< ButtonRow() {
                $0.title = "Pay"
                $0.onCellSelection() { cell, row in
                    
                }
            }*/
            +++ Section(NSLocalizedString("Review", comment: "")) { $0.tag = "review" }
            <<< SegmentedRow<String>("score") {
                $0.options = ["1", "2", "3", "4", "5"]
                $0.title = NSLocalizedString("Score", comment: "")
                }.onChange { row in
                    self.score = Int(row.value!)!
                }
            <<< TextRow() { row in
                row.title = NSLocalizedString("Your_Review", comment: "")
                row.placeholder = "\(NSLocalizedString("Enter_Review", comment: ""))..."
                row.onChange() { row in
                    self.review = row.value
                }
        }
            <<< ButtonRow() { row in
                row.title = NSLocalizedString("Save", comment: "")
                row.onCellSelection() { cell, row in
                    guard let _score = self.score else {
                        let title = NSLocalizedString("Error", comment: "")
                        let message = NSLocalizedString("Alert_Select_Score", comment: "")
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return;
                    }
                    ReviewDriver(review: Review(score: _score * 20, review: self.review ?? "")).execute() { result in
                        switch result {
                        case .success(_):
                            DialogBuilder.alertOnSuccess(message: NSLocalizedString("Review_Sent", comment: ""))
                            Request.shared.status = .Finished
                            self.navigationController?.popViewController(animated: true)
                            
                        case .failure(let error):
                            error.showAlert()
                        }
                    }
                }
        }
        
    }
}
