//
//  ServicesViewController.swift
//
//  Copyright © 2018 Minimalistic Apps. All rights reserved.
//

import UIKit

class ServicesParentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    public var calculateFareResult: CalculateFareResult!
    public var estimate: EstimateModel!
    public var discountUF: Double!
    public var callback: ServiceRequested?
    private var selectedCategory: ServiceCategory?
    private var selectedService: Service?
    
    @IBOutlet weak var buttonRideNow: ColoredButton!
    @IBOutlet weak var buttonRideLater: ColoredButton!
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var collectionServices: UICollectionView!
    @IBOutlet weak var viewBlur: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        self.collectionServices.dataSource = self
        self.collectionServices.delegate = self
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewBlur.addSubview(blurEffectView)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.view.layer.mask = maskLayer
        
        buttonRideLater.isHidden = true
        let title = "SOLICITE AGORA"
        buttonRideNow.setTitle(title, for: .normal)
        self.setupButton(button: self.buttonRideNow, isEnable: false)
    }
    
    private func setupButton(button: ColoredButton, isEnable: Bool) {
        button.backgroundColor = (isEnable) ? Color.orange.rgb_255_152_0 : Color.gray.rgb_240_240_240
        button.setTitleColor((isEnable) ? .white : .gray, for: .normal)
        button.setTitleColor((isEnable) ? .white : .gray, for: .selected)
        button.isEnabled = isEnable
    }
    
    public func reload() {
        let segments = calculateFareResult.categories.map() { x in return x.title }
        self.tabBar.removeAllSegments()
        for (index, value) in segments.enumerated() {
            self.tabBar.insertSegment(withTitle: value, at: index, animated: false)
        }
        self.tabBar.selectedSegmentIndex = 0
        self.tabChanged(sender: self.tabBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cat = self.selectedCategory else {
            return 0
        }
        return cat.services.count
    }
    
    @objc func tabChanged(sender: UISegmentedControl) {
        self.selectedCategory = self.calculateFareResult.categories[sender.selectedSegmentIndex]
        
        self.collectionServices.reloadData()
        for indexPath in self.collectionServices.indexPathsForVisibleItems {
            self.collectionServices.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! ServicesListCell
        
        cell.initialize(discountUF: Double(calculateFareResult.discountUF) ?? 0.0, estimate: estimate, service: (selectedCategory?.services[indexPath.row])!, fareResult: calculateFareResult.fareResult, feeEstimationMode: calculateFareResult.feeEstimationMode, currency: calculateFareResult.currency)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        selectedService = (selectedCategory?.services[indexPath.row])!
        buttonRideNow.isEnabled = true
        buttonRideLater.isEnabled = true
        buttonRideLater.isHidden = true
        let localized = NSLocalizedString("Request_Service", comment: "")
        let title = String(format: localized, selectedService!.title ?? "")
        buttonRideNow.setTitle(title, for: .normal)
        
        self.setupButton(button: self.buttonRideNow, isEnable: true)
    }
    
    @IBAction func onSelectServiceClicked(_ sender: UIButton) {
        
        if let d = callback {
            if let s = selectedService {
                d.selectPaymentMethod(service: s)
            }
        }
    }
    
    @IBAction func onBookLaterClicked(_ sender: ColoredButton) {
        // TODO(): Ajustar código
        
        //        DatePickerDialog().show(NSLocalizedString("Select_Time", comment: "Select Time dialog title"), doneButtonTitle: NSLocalizedString("Done", comment: ""), cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), datePickerMode: selectedService?.bookingMode == .Time ? .time : .dateAndTime) {
        //            (date) -> Void in
        //            if(self.selectedService?.bookingMode == .DateTimeAbosoluteHour && Calendar.current.component(.minute, from: date!) != 0) {
        //                DialogBuilder.alertOnError(message: NSLocalizedString("Absolute_Hours_Acceptable", comment: "Absolute Hour Message Description"))
        //                return
        //            }
        //            if let dt = date, let d = self.callback {
        //
        //                let seconds = dt.timeIntervalSince(Date())
        //                if seconds < 30 {
        //                    let message = UIAlertController(title: NSLocalizedString("Problem", comment: ""), message: NSLocalizedString("Alert_Error_Passed_Time", comment: ""), preferredStyle: .alert)
        //                    message.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //                    self.parent!.present(message, animated: true, completion: nil)
        //                    return
        //                }
        //                d.RideLaterSelected(service: self.selectedService!, minutesFromNow: Int(seconds / 60))
        //
        //            }
        //        }
    }
}

protocol ServiceRequested {
    func RideNowSelected(service: Service, payType: String)
    func RideLaterSelected(service: Service, minutesFromNow: Int)
    func selectPaymentMethod(service: Service)
}
