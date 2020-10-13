//
//  TravelTableViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit


class TripHistoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: Properties
    let cellIdentifier = "TripHistoryCollectionViewCell"
    
    var travels = [Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibCell = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView?.register(nibCell, forCellWithReuseIdentifier: cellIdentifier)
        self.refreshList(self)
    }

    @IBAction func refreshList(_ sender: Any) {
        GetRequestHistory().execute() { result in
            switch result {
            case .success(let response):
                self.travels = response
                self.collectionView?.reloadData()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 150
        return CGSize(width: collectionView.bounds.size.width - 16, height: CGFloat(kWhateverHeightYouWant))
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let complaint = UIAction(title: NSLocalizedString("Title_Write_Complaint", comment: ""), image: UIImage(systemName: "square.and.pencil")) { action in
                let title = NSLocalizedString("Complaint", comment: "")
                let message = NSLocalizedString("Message_Write_Complaint", comment: "")
                let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
                dialog.addTextField() { textField in
                    let title = NSLocalizedString("Title", comment: "")
                    textField.placeholder = "\(title)..."
                }
                dialog.addTextField() { textField in
                    let content = NSLocalizedString("Content", comment: "")
                    textField.placeholder = "\(content)..."
                }
                dialog.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Message OK button"), style: .default) { action in
                    WriteComplaint(requestId: self.travels[indexPath.row].id!, subject: dialog.textFields![0].text!, content: dialog.textFields![1].text!).execute() { result in
                        switch result {
                        case .success(_):
                            DialogBuilder.alertOnSuccess(message: NSLocalizedString("Complaint_Sent", comment: ""))
                            
                        case .failure(let error):
                            error.showAlert()
                        }
                    }
                })
                dialog.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Message Cancel Button"), style: .cancel))
                self.present(dialog, animated: true)
            }

            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let hide = UIAction(title: NSLocalizedString("Hide_Item", comment: ""), image: UIImage(systemName: "eye.slash"), attributes: .destructive) { action in
                HideHistoryItem(requestId: self.travels[indexPath.row].id!).execute() { result in
                    switch result {
                    case .success(_):
                        self.refreshList(self)
                        
                    case .failure(let error):
                        error.showAlert()
                    }
                }
            }
            var buttons = [complaint]
            if SocketNetworkDispatcher.instance.userType == .Rider {
                buttons.append(hide)
            }
            // The "title" will show up as an action for opening this menu
            //let edit = UIMenu(title: "Write Complaint", children: [complaint])

            // Create our menu with both the edit menu and the share action
            return UIMenu(title: "Options", children: buttons)
        })
    }
    
    override func numberOfSections(in tableView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return travels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TripHistoryCollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of TripHistoryTableCell.")
        }
        let travel = travels[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        cell.pickupLabel.text = travel.addresses?.first
        if travel.addresses?.count ?? 0 > 1 {
            cell.destinationLabel.text = travel.addresses?.last
        }
        if let startTimestamp = travel.startTimestamp {
            cell.startTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp / 1000)))
        }
        if let finishTimestamp = travel.finishTimestamp {
            cell.finishTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(finishTimestamp / 1000)))
        }
        cell.textCost.text = MyLocale.formattedCurrency(amount: travel.costAfterCoupon ?? 0, currency: travel.currency!)
        
        if let text = travel.status?.rawValue {
            let textStatus = self.toPtBrStatus(text)
            cell.textStatus.text = textStatus
            
        } else {
            cell.textStatus.text = "Não identificado"
        }
        
        return cell
    }
    
    private func toPtBrStatus(_ uSEnStatus: String) -> String {
        
        switch uSEnStatus {

        case "Requested":
            return "Corrida solicitada"
        case "NotFound":
            return "Não encontrada"

        case "NoCloseFound":
            return "Aguardando encerramento"

        case "Found", "DriverAccepted", "WaitingForPrePay", "Arrived", "Started", "WaitingForPostPay", "Booked":
            return "Em andamento"

        case "DriverCanceled":
            return "Cancelada pelo motorista"

        case "RiderCanceled":
            return "Cancelada por você"
            
            
        case "WaitingForReview":
            return "Aguardando revisão"

        case "Finished":
            return "Finalizada"

        case "Expired":
            return "Expirada"
        
        default:
            return "Não identificado"
        }
    }
}

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}

extension Sequence {
    func splitBefore(
        separator isSeparator: (Iterator.Element) throws -> Bool
    ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []

        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
        }
        result.append(AnySequence(subSequence))
        return result
    }
}
