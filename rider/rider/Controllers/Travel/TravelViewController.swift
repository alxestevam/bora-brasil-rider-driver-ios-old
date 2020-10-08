//
//  TravelViewController.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

//MARK: - Imports
import Kingfisher
import UIKit
import MapKit
import MarqueeLabel
import Toast_Swift

class TravelViewController: UIViewController, CouponsViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lblEstimatedArrivalTime: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var buttonCall: ColoredButton!
    @IBOutlet weak var buttonMessage: ColoredButton!
    @IBOutlet weak var buttonCancel: ColoredButton!
    @IBOutlet weak var buttonPay: ColoredButton!
    var onReviewBlock: ((_ object: Any?, _ isReview: Bool) -> Void)? = nil
    private var currentRoute: Route? = nil
    private var groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)] = []

    var pickupMarker = MKPointAnnotation()
    var destinationMarkers: [MKPointAnnotation] = []
    var driverMarker = MKPointAnnotation()
    var timer: Timer!
    @IBOutlet weak var confirmationBarButton: UIBarButtonItem!
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewStatistics: UIView!
    @IBOutlet weak var viewDriver: UIView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblVehicleInfo: UILabel!
    @IBOutlet weak var lblSource: MarqueeLabel!
    @IBOutlet weak var lblDestination: MarqueeLabel!
    @IBOutlet var imgDriverProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onArrived), name: .arrived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceStarted), name: .serviceStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceCanceled), name: .serviceCanceled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onServiceFinished), name: .serviceFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTravelInfoReceived), name: .travelInfoReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.requestRefresh), name: .connectedAfterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageReceived), name: .messageReceived, object: nil)
        
        let notProvided = " - "
        self.lblDriverName.text = "\(Request.shared.driver?.firstName ?? notProvided) \(Request.shared.driver?.lastName ?? notProvided)"
        let carInfo = "\(Request.shared.driver?.car?.title ?? notProvided), \(Request.shared.driver?.carColor ?? notProvided), \(Request.shared.driver?.carPlate ?? notProvided)"
        self.lblVehicleInfo.text = carInfo
        let source = Request.shared.addresses?.first ?? "Não identificado"
        let destination = Request.shared.addresses?.last ?? "Não identificado"
        self.lblSource.text = source.isEmpty ? "Não identificado" : source
        self.lblDestination.text = destination.isEmpty ? "Não identificado" : destination
        self.lblSource.speed = .duration(12.0)
        self.lblDestination.speed = .duration(12.0)
        
        if let driverImage = Request.shared.driver?.media?.address {
            let processor = DownsamplingImageProcessor(size: self.imgDriverProfile.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: self.imgDriverProfile.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + driverImage.replacingOccurrences(of: " ", with: "%20"))
            self.imgDriverProfile.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
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

        tabBar.addTarget(self, action: #selector(selectedTabItem), for: .valueChanged)
        map.layoutMargins = UIEdgeInsets(top: 50, left: 0, bottom: 290, right: 0)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.backgroundView.layer.mask = maskLayer
        driverMarker = MKPointAnnotation()
        map.delegate = self
        self.navigationItem.hidesBackButton = true
        if let canConfirm = Request.shared.service?.canEnableVerificationCode {
            if !canConfirm {
                self.navigationItem.rightBarButtonItem = nil
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
//        if var cost = Request.shared.finalCost {
//            if let coupon = Request.shared.coupon {
//                cost = cost * Double(100 - coupon.discountPercent!) / 100
//                cost = cost - Double(coupon.discountFlat!)
//            }
//            // TODO(): Ajustar código
////            if let service = Request.shared.service, (service.feeEstimationMode == .Dynamic || service.feeEstimationMode == .RangedStrict || service.feeEstimationMode == .Ranged) {
////                self.labelCost.text = "~\(MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!))"
////            } else {
////                self.labelCost.text = MyLocale.formattedCurrency(amount: cost, currency: Request.shared.currency!)
////            }
//        }
        
        self.handleTravelCost()
        self.handleTime()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onEachSecond), userInfo: nil, repeats: true)
    }
    
    private func handleTravelCost() {
        
        let request = Request.shared
        self.lblCost.text = FormatterUtil.shared.stringFromValue(value: request.costBest ?? 0.0, monetaryFormat: true, decimalPrecision: 2)
    }
    
    private func handleTime() {
        
        let request = Request.shared
        if (request.status == .DriverAccepted) {
            let args = request.pickupTime ?? 60/60
            self.lblEstimatedArrivalTime.text = (args < 0 ) ? "Em breve" : String(format: "%2d min", args)
            
        } else if (request.status == .Started) {
            
            let startTimestamp = request.startTimestamp ?? 0
            let recalculatedTravelTime = request.recalculatedTravelTime ?? 0

            if (startTimestamp > 0) {
                let estimatedArrive = startTimestamp + (UInt64)(recalculatedTravelTime * 1000)
                self.lblEstimatedArrivalTime.text = FormatterUtil.shared.miliToDate(mili: estimatedArrive, dateFormatString: "HH:mm")
                
            } else {
                lblEstimatedArrivalTime.text = "Calculando..."
            }
        }
    }
    
    @objc func selectedTabItem(sender: UISegmentedControl) {
        defer {
            self.handleTravelCost()
            self.handleTime()
        }
        
        if sender.selectedSegmentIndex == 1 {
            viewDriver.isHidden = true
            viewStatistics.isHidden = false
        } else {
            viewDriver.isHidden = false
            viewStatistics.isHidden = true
        }
    }
    
    @IBAction func onMessageTapped(_ sender: UIButton) {
        let vc = ChatViewController()
        vc.sender = Request.shared.driver!
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestRefresh()
    }
    
    @objc func onEachSecond() {
//        let now = Date()
//        let etaInterval = Request.shared.startTimestamp != nil ? (Request.shared.startTimestamp! / 1000) + Double(Request.shared.durationBest!) : Request.shared.etaPickup ?? 0 / 1000
//        let etaTime = Date(timeIntervalSince1970: etaInterval)
//        if etaTime <= now {
//            if Request.shared.status == .Arrived {
//                lblCost.text = NSLocalizedString("Arrived", comment: "Driver Arrived text instead of time.")
//            } else {
//                lblCost.text = NSLocalizedString("Soon", comment: "When driver is coming later than expected.")
//            }
//
//        } else {
//            let formatter = DateComponentsFormatter()
//            formatter.allowedUnits = [.minute, .second]
//            formatter.unitsStyle = .short
//            lblCost.text = formatter.string(from: now, to: etaTime)
//        }
    }
    
    @objc private func requestRefresh() {
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                Request.shared = response.request
                self.refreshScreen(driverLocation: response.driverLocation)
                
            case .failure(_):
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    private func refreshScreen(travel: Request = Request.shared, driverLocation: CLLocationCoordinate2D?) {
        
        defer {
            self.handleTravelCost()
            self.handleTime()
        }
        
        switch travel.status! {
        case .RiderCanceled, .DriverCanceled:
            _ =  NSLocalizedString("Success", comment: "")
            let message =  NSLocalizedString("Alert_Service_Canceled", comment: "")
            let actionTitle =  NSLocalizedString("Allright", comment: "")
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { action in
                _ = self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            break
            
        case .DriverAccepted:
            if let points = travel.points {
                pickupMarker.coordinate = points[0]
                map.addAnnotation(pickupMarker)
                if let _location = driverLocation {
                    driverMarker.coordinate = _location
                    map.addAnnotation(driverMarker)
                    map.showAnnotations([pickupMarker, driverMarker], animated: true)
                } else {
                    let region = MKCoordinateRegion(center: points[0], latitudinalMeters: 1000, longitudinalMeters: 1000)
                    map.setRegion(region, animated: true)
                }
                
                let origin = CLLocation.init(latitude: driverMarker.coordinate.latitude,
                    longitude: driverMarker.coordinate.longitude)
                let stops = CLLocation.init(latitude: pickupMarker.coordinate.latitude,
                                            longitude: pickupMarker.coordinate.longitude)
                
                
                RouteBuilder.buildRoute(
                    origin: .location(origin),
                    stops: [.location(stops)],
                    within: nil
                ) { result in
                    
                    switch result {
                    case .success(let route):
                        self.currentRoute = route
                        self.map.groupAndRequestDirections(route: self.currentRoute, groupedRoutes: self.groupedRoutes) { (result) in
                            self.groupedRoutes = result
                        }
                        break
                        
                    case .failure( _):
                        break
                    }
                }
            }
            
            break
            
        case .Arrived:
            DialogBuilder.alertOnSuccess(message: NSLocalizedString("Driver_Arrived", comment: "Alert for driver Arrival"))
            break
            
        case .Started:
            buttonCall.isHidden = true
            buttonMessage.isHidden = true
            buttonCancel.isHidden = true
            map.removeAnnotation(pickupMarker)
            if let points = travel.points {
                for (index, point) in points.enumerated() {
                    if index == 0 {
                        continue;
                    }
                    let p = MKPointAnnotation()
                    p.coordinate = point
                    destinationMarkers.append(p)
                    map.addAnnotation(p)
                }
            }
            if driverLocation != nil || destinationMarkers.count > 1 {
                if(driverLocation != nil) {
                    driverMarker.coordinate = driverLocation!
                    map.addAnnotation(driverMarker)
                    destinationMarkers.append(driverMarker)
                    map.showAnnotations(destinationMarkers, animated: true)
                    destinationMarkers.removeLast()
                } else {
                    map.showAnnotations(destinationMarkers, animated: true)
                }
            } else {
                if let points = travel.points {
                    let region = MKCoordinateRegion(center: points[1], latitudinalMeters: 1000, longitudinalMeters: 1000)
                    map.setRegion(region, animated: true)
                }
            }
            break
            
        case .WaitingForPostPay:
            let vc = Bundle.main.loadNibNamed("WaitingForPayment", owner: self, options: nil)?.first as! WaitingForPaymentViewController
            vc.onChangeBlock = {(_ object: Any?, _ isChange: Bool) -> Void in
                if (isChange) {
                    self.refreshScreen(driverLocation: nil)
                }
            }
            self.present(vc, animated: true)
            break
            
        case .WaitingForReview:
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewTravelViewController") as? ReviewTravelViewController {
                vc.modalPresentationStyle = .overFullScreen
                vc.onChangeBlock = {(_ object: Any?, _ isChange: Bool) -> Void in
                    if (isChange) {
                        if let compl = self.onReviewBlock { compl(nil, true) }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                self.present(vc, animated:true, completion: nil)
            }
            break
            
        case .Finished:
            DialogBuilder.alertOnSuccess(message: NSLocalizedString("Done", comment: ""))
            self.navigationController?.popViewController(animated: true)
            
        default:
            let title =  NSLocalizedString("Error", comment: "")
            let message =  NSLocalizedString("Unknown_Status", comment: "")
            let actionTitle =  NSLocalizedString("Allright", comment: "")
            let alert = UIAlertController(title: title, message: "\(message): \(travel.status!.rawValue)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { action in
                _ = self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
    
    @objc func messageReceived(notification: Notification) {
        let message: ChatMessage = notification.object as! ChatMessage
        
        self.view.hideAllToasts()
        
        // toast presented with multiple options and with a completion closure
        self.view.makeToast(message.content, duration: 3.0, position: .center, title: "Nova mensagem recebida", image: nil, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: UIButton) {
        Cancel().execute() { result in
            switch result {
            case .success(_):
                Request.shared.status = .RiderCanceled
                self.refreshScreen(driverLocation: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    @IBAction func onWalletTapped(_ sender: UIButton) {
//        buttonPay.isHidden = true
//        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Wallet") as? WalletViewController {
//            vc.amount = Request.shared.costAfterCoupon
//            vc.currency = Request.shared.currency
//            self.navigationController!.pushViewController(vc, animated: true)
//        }
    }
    
    @objc func onServiceStarted(_ notification: Notification) {
        Request.shared = notification.object as! Request
        let location = driverMarker.coordinate.latitude != 0 ? driverMarker.coordinate : nil
        refreshScreen(driverLocation: location)
    }
    
    @objc func onArrived(_ notification: Notification) {
        Request.shared = notification.object as! Request
        refreshScreen(driverLocation: nil)
    }
    
    @objc func onServiceCanceled(_ notification: Notification) {
        Request.shared.status = .DriverCanceled
        refreshScreen(driverLocation: nil)
    }
    
    @objc func onServiceFinished(_ notification: Notification) {
        let obj = notification.object as! [Any]
        Request.shared.status = (obj[0] as! Bool) == true ? Request.Status.WaitingForReview : Request.Status.WaitingForPostPay
        refreshScreen(driverLocation: nil)
    }
    
    @objc func onTravelInfoReceived(_ notification: Notification) {
        refreshScreen(driverLocation: (notification.object as! CLLocationCoordinate2D))
    }
    
    @IBAction func onSelectCouponClicked(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CouponsCollectionViewController") as? CouponsCollectionViewController
        {
            vc.selectMode = true
            vc.delegate = self
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func didSelectedCoupon(_ coupon: Coupon) {
        // TODO(): Ajustar código

//        ApplyCoupon(code: coupon.code!).execute() { result in
//            switch result {
//            case .success(let response):

//                DialogBuilder.alertOnSuccess(message: NSLocalizedString("Done", comment: ""))
//                if let service = Request.shared.service, (service.feeEstimationMode == .Dynamic || service.feeEstimationMode == .RangedStrict || service.feeEstimationMode == .Ranged) {
//                    self.labelCost.text = "~\(MyLocale.formattedCurrency(amount: response, currency: Request.shared.currency!))"
//                } else {
//                    self.labelCost.text = MyLocale.formattedCurrency(amount: response, currency: Request.shared.currency!)
//                }
                
//            case .failure(let error):
//                error.showAlert()
//            }
//        }
    }
    
    enum MarkerType: String {
        case pickup = "pickup"
        case dropoff = "dropOff"
        case driver = "driver"
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        let identifier = annotation == pickupMarker ? MarkerType.pickup : (annotation == driverMarker ? MarkerType.driver : MarkerType.dropoff)
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier.rawValue)
            switch(identifier) {
            case .pickup:
                view.glyphImage = UIImage(named: "annotation_glyph_home")
                view.markerTintColor = UIColor(hex: 0x009688)
                break;
                
            case .dropoff:
                view.markerTintColor = UIColor(hex: 0xFFA000)
                break;
                
            default:
                view.glyphImage = UIImage(named: "annotation_glyph_car")
            }
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return self.map.rendererBuilder(mapView, rendererFor: overlay)
    }
    
    @IBAction func onCallTouched(_ sender: UIButton) {
        if let call = Request.shared.driver?.mobileNumber, let url = URL(string: "tel://\(call)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func enableConfirmationClicked(_ sender: UIBarButtonItem) {
        EnableVerification().execute() { result in
            switch result {
            case .success(let response):
                let title = NSLocalizedString("Done", comment: "")
                let localized = NSLocalizedString("Alert_Confirmation", comment: "")
                let alertMessage = String(format: localized, response)
                let message = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
                message.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(message, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
}
