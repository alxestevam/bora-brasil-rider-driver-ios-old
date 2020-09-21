//
//  MainViewController.swift
//  Rider
//
//  Copyright © 2019 minimalistic apps. All rights reserved.
//

import UIKit
import MapKit

import StatusAlert
import Contacts

class MainViewController: UIViewController, CLLocationManagerDelegate, ServiceRequested {
    
    //MARK: - Properties
    let rider = try! Rider(from: UserDefaultsConfig.user!)
    @IBOutlet weak var map: MKMapView!
    var pointsAnnotations: [MKPointAnnotation] = []
    var arrayDriversMarkers: [MKPointAnnotation] = []
    var locationManager = CLLocationManager()
    var servicesViewController: ServicesParentViewController?
    private var selectedService: Service?
    var pinAnnotation:MKPinAnnotationView = MKPinAnnotationView()
    
    private var searchController: UISearchController!
    @IBOutlet weak var buttonConfirmPickup: ColoredButton!
    @IBOutlet weak var buttonAddDestination: ColoredButton!
    @IBOutlet weak var buttonConfirmFinalDestination: ColoredButton!
    @IBOutlet weak var containerServices: UIView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var buttonFavorites: UIBarButtonItem!
    
    let message = NSLocalizedString("Message", comment: "")
    let allright = NSLocalizedString("Allright", comment: "")
    
    private var originalPullUpControllerViewSize: CGSize = .zero
    private func makePaymentMethodControllerIfNeeded() -> SelectPaymentMethodViewController {
        let currentPullUpController = children
            .filter({ $0 is SelectPaymentMethodViewController })
            .first as? SelectPaymentMethodViewController
        let pullUpController: SelectPaymentMethodViewController = currentPullUpController ?? storyboard?.instantiateViewController(withIdentifier: "SelectPaymentMethodViewController") as! SelectPaymentMethodViewController
        pullUpController.delegate = self
        pullUpController.initialState = .expanded
        if originalPullUpControllerViewSize == .zero {
            originalPullUpControllerViewSize = pullUpController.view.bounds.size
        }
        
        return pullUpController
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        buttonAddDestination.isHidden = true
        buttonConfirmFinalDestination.isHidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        map.delegate = self
        pinAnnotation.frame = CGRect(x: (self.view.frame.width / 2) - 8, y: self.view.frame.height / 2 - 8, width: 32, height: 39)
        pinAnnotation.pinTintColor = UIApplication.shared.keyWindow?.tintColor
        map.addSubview(pinAnnotation)
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SuggestionsTableTableViewController") as! SuggestionsTableTableViewController
        locationSearchTable.callback = self
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
        GetCurrentRequestInfo().execute() { result in
            switch result {
            case .success(let response):
                Request.shared = response.request
                if response.request.status == .Booked || response.request.status == .Requested || response.request.status == .Found {
                    self.performSegue(withIdentifier: "startLooking", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "startTravel", sender: nil)
                }
                
            case .failure(_):
                break
            }
        }
        
        // Verifica se dados estão incompletos para ir para edição de dados
        guard let media = rider.media else {
            self.presentProfileEditController()
            return
        }
        
        if (media.address.isNilOrEmpty || rider.cpf.isNilOrEmpty || rider.email.isNilOrEmpty || rider.firstName.isNilOrEmpty || rider.lastName.isNilOrEmpty) {
            self.presentProfileEditController()
        }
        
        guard
            let navigationController = self.navigationController,
            let gradientImage = CAGradientLayer.viewToImageGradient(on: navigationController.navigationBar)
        else {
            print("Error creating gradient color!")
            return
        }
        
        configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor(patternImage: gradientImage), tintColor: .white, title: "Bora Brasil", preferredLargeTitle: false)
    }
    
    private func addPullUpController(animated: Bool) {
        let pullUpController = makePaymentMethodControllerIfNeeded()
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: animated)
    }
    
    private func setupLayout() {
    
    }
    
    func goBackFromServiceSelection() {
        LoadingOverlay.shared.hideOverlayView()
        leftBarButton.image = UIImage(named: "menu")
        map.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        map.removeAnnotations(pointsAnnotations)
        pointsAnnotations.removeAll()
        buttonAddDestination.isHidden = true
        buttonConfirmFinalDestination.isHidden = true
        buttonConfirmPickup.isHidden = false
        buttonFavorites.isEnabled = true
        self.containerServices.isHidden = true
        self.pinAnnotation.isHidden = false
        map.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ServicesParentViewController,
           segue.identifier == "segueServices" {
            self.servicesViewController = vc
            vc.callback = self
        }
        if let vc = segue.destination as? LookingViewController, segue.identifier == "startLooking" {
            vc.delegate = self
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let position = manager.location else {
            let messageAlert = NSLocalizedString("Alert_Error_Get_Current_Location", comment: "")
            let alert = UIAlertController(title: message, message: messageAlert, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: allright, style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let region = MKCoordinateRegion(center: position.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
    }
    
    @IBAction func onMenuClicked(_ sender: UIBarButtonItem) {
        if(pointsAnnotations.count == 0) {
            NotificationCenter.default.post(name: .menuClicked, object: nil)
            return
        }
        if(!pinAnnotation.isHidden) {
            map.removeAnnotation(pointsAnnotations.last!)
            pointsAnnotations.removeLast()
            buttonConfirmPickup.isHidden = (pointsAnnotations.count != 0)
            buttonConfirmFinalDestination.isHidden = (pointsAnnotations.count == 0 || AppDelegate.singlePointMode)
            //buttonAddDestination.isHidden = (pointsAnnotations.count > (AppDelegate.maximumDestinations - 1) || AppDelegate.singlePointMode || pointsAnnotations.count == 0)
            leftBarButton.image = (pointsAnnotations.count == 0 ? UIImage(named: "menu") : UIImage(named: "back"))
            return
        }
        goBackFromServiceSelection()
    }
    
    @IBAction func onFavoritesClicked(_ sender: UIBarButtonItem) {
        GetAddresses().execute() { result in
            switch result {
            case .success(let response):
                if(response.count < 1) {
                    let messageAlert = NSLocalizedString("No_Favorite_Address_Found", comment: "")
                    let alert = UIAlertController(title: self.message, message: messageAlert, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: self.allright, style: .default) { action in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                    return
                }
                Address.lastDownloaded = response
                let vc = UIViewController()
                vc.preferredContentSize = CGSize(width: 250,height: 150)
                let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
                pickerView.delegate = self
                pickerView.dataSource = self
                vc.view.addSubview(pickerView)
                let dlg = UIAlertController(title: NSLocalizedString("Favorite_Addresses", comment: "Favorites Picker Title"), message: NSLocalizedString("Choose_Location", comment: "Favorites Picker Description"), preferredStyle: .alert)
                dlg.setValue(vc, forKey: "contentViewController")
                dlg.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default){ action in
                    self.map.setCenter(response[pickerView.selectedRow(inComponent: 0)].location!, animated: true)
                })
                dlg.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                self.present(dlg, animated: true)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func RideNowSelected(service: Service, payType: String) {
        let locs = pointsAnnotations.map() { annotation in
            return LocationWithName(loc: annotation.coordinate, add: annotation.title!)
        }
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        // TODO(): Fazer calculo de duração e dist^ancia
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: service.id!, quantity: 1)], intervalMinutes: 0, paymentType: payType, estimatedTravelTime: 60/60, estimatedTravelDistance: 1)).execute() { result in
            switch result {
            case .success(_):
                self.performSegue(withIdentifier: "startLooking", sender: nil)
                self.goBackFromServiceSelection()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func RideLaterSelected(service: Service, minutesFromNow: Int) {
        let locs = pointsAnnotations.map() { annotation in
            return LocationWithName(loc: annotation.coordinate, add: annotation.title!)
        }
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: 1, quantity: 1)], intervalMinutes: minutesFromNow, paymentType: "", estimatedTravelTime: 60/60, estimatedTravelDistance: 1)).execute() { result in
            switch result {
            case .success(_):
                self.performSegue(withIdentifier: "startLooking", sender: nil)
                self.goBackFromServiceSelection()
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    func selectPaymentMethod(service: Service) {
        self.containerServices.isHidden = true
        self.selectedService = service
        addPullUpController(animated: true)
    }
    
    @IBAction func onButtonConfirmPickupTouched(_ sender: ColoredButton) {
        leftBarButton.image = UIImage(named: "back")
        AddDestination()
        if (AppDelegate.singlePointMode) {
            calculateFare()
        }
        
    }
    
    @IBAction func onButtonAddDestinationTouched(_ sender: Any) {
        AddDestination()
    }
    
    @IBAction func onButtonFinalDestinationTouched(_ sender: Any) {
        AddDestination()
        calculateFare()
    }
    
    func AddDestination() {
        let ann = MKPointAnnotation()
        ann.coordinate = map.camera.centerCoordinate
        ann.title = (self.navigationItem.searchController?.searchBar.text)!
        pointsAnnotations.append(ann)
        map.addAnnotation(ann)
        let cameraTarget = CLLocationCoordinate2D(latitude: map.camera.centerCoordinate.latitude + 0.0015, longitude: map.camera.centerCoordinate.longitude)
        map.setCenter(cameraTarget, animated: true)
        if(!AppDelegate.singlePointMode) {
            buttonConfirmPickup.isHidden = true
            buttonConfirmFinalDestination.isHidden = false
            //buttonAddDestination.isHidden = (pointsAnnotations.count > (AppDelegate.maximumDestinations - 1))
        }
    }
    
    func calculateFare() {
        LoadingOverlay.shared.showOverlay(view: self.view)
        buttonFavorites.isEnabled = false
        self.pinAnnotation.isHidden = true
        map.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 305, right: 0)
        map.showAnnotations(pointsAnnotations, animated: true)
        map.isUserInteractionEnabled = false
        let locs = pointsAnnotations.map() { return $0.coordinate }
        CalculateFare(locations: locs).execute() { result in
            LoadingOverlay.shared.hideOverlayView()
            switch result {
            case .success(let response):
                self.servicesViewController?.calculateFareResult = response
                self.containerServices.isHidden = false
                self.servicesViewController?.reload()
                
            case .failure(let error):
                self.goBackFromServiceSelection()
                error.showAlert()
            }
        }
    }
    
    func getAddressForLatLng(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                let formatter = CNPostalAddressFormatter()
                let addressString = formatter.string(from: firstLocation!.postalAddress!)
                self.navigationItem.searchController?.searchBar.text = addressString
                self.buttonConfirmPickup.isEnabled = true
                self.buttonAddDestination.isEnabled = true
                self.buttonConfirmFinalDestination.isEnabled = true
            }
        }
    }
    
    //MARK: Action
    private func presentProfileEditController() {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfile") as? RiderEditProfileViewController {
            let navController = UINavigationController(rootViewController: vc)
            vc.modalPresentationStyle = .fullScreen
            navController.modalPresentationStyle = .fullScreen
            vc.shouldBack = false
            self.present(navController, animated:true, completion: nil)
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
    }
}

extension MainViewController: MapSearchDelegate {
    func placeMarkSelected(placemark: MKPlacemark) {
        dismiss(animated: true, completion: {
            self.map.setCenter(placemark.coordinate, animated: true)
        })
    }
}

extension MainViewController: MKMapViewDelegate {
    enum MarkerType: String {
        case pickup = "pickup"
        case dropoff = "dropOff"
        case driver = "driver"
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        buttonConfirmPickup.isEnabled = false
        buttonAddDestination.isEnabled = false
        buttonConfirmFinalDestination.isEnabled = false
        /*if(pinAnnotation.dragState == .none) {
         pinAnnotation.dragState = .dragging
         pinAnnotation.setDragState(.starting, animated: true)
         }*/
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        let identifier: MarkerType
        if(pointsAnnotations.contains(annotation)) {
            identifier = MarkerType.dropoff
        } else {
            identifier = MarkerType.driver
        }
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
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if containerServices.isHidden == false { return }
        /*if(pinAnnotation.dragState == .dragging) {
         //pinAnnotation.dragState = .none
         pinAnnotation.setDragState(.ending, animated: false)
         print("End status called")
         }*/
        getAddressForLatLng(location: mapView.camera.centerCoordinate)
        GetDriversLocations(location: mapView.camera.centerCoordinate).execute() { result in
            switch result {
            case .success(let response):
                for driverMarker in self.arrayDriversMarkers {
                    self.map.removeAnnotation(driverMarker)
                }
                self.arrayDriversMarkers.removeAll()
                for location in response {
                    let marker = MKPointAnnotation()
                    marker.coordinate = location
                    //marker.title = "Driver"
                    self.arrayDriversMarkers.append(marker)
                    self.map.addAnnotation(marker)
                }
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Address.lastDownloaded.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Address.lastDownloaded[row].title
    }
}


//MARK: - LookingDelegate
extension MainViewController: LookingDelegate {
    func cancel() {
        
    }
    
    func found() {
        self.performSegue(withIdentifier: "startTravel", sender: nil)
    }
}


//MARK: - SelectPaymentMethodViewControllerDelegate
extension MainViewController: SelectPaymentMethodViewControllerDelegate {
    
    func paymentCardSelected(_ card: GetCardDetailResult) {
        if let s = selectedService {
            RideNowSelected(service: s, payType: "credit")
        }
    }
    
    func paymentMoneySelected() {
        if let s = selectedService {
            RideNowSelected(service: s, payType: "cash")
        }
    }
}

