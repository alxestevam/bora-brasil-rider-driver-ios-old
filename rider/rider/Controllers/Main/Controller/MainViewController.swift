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
    private var stateCurrent = "SP"
    var pointsAnnotations: [MKPointAnnotation] = []
    var arrayDriversMarkers: [MKPointAnnotation] = []
    let estimateViewModel = EstimateViewModel()
    var locationManager = CLLocationManager()
    var servicesViewController: ServicesParentViewController?
    private var selectedService: Service?
    var pinAnnotation:MKPinAnnotationView = MKPinAnnotationView()
    private var currentRoute: Route? = nil
    private var groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)] = []
    private var searchController: UISearchController!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var buttonConfirmPickup: ColoredButton!
    @IBOutlet weak var buttonAddDestination: ColoredButton!
    @IBOutlet weak var buttonConfirmFinalDestination: ColoredButton!
    @IBOutlet weak var containerServices: UIView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var buttonFavorites: UIBarButtonItem!
    var resultsViewController: GMSAutocompleteResultsViewController?
    let message = NSLocalizedString("Message", comment: "")
    let allright = NSLocalizedString("Allright", comment: "")
    var directionsResponse: DirectionsResponse? = nil
    var selectedPlaceId: String? = nil
    var searchingPlaces: Bool = false
    
    private var originalPullUpControllerViewSize: CGSize = .zero
    private func makePaymentMethodControllerIfNeeded() -> SelectPaymentMethodViewControllerV2 {
        let currentPullUpController = children
            .filter({ $0 is SelectPaymentMethodViewControllerV2 })
            .first as? SelectPaymentMethodViewControllerV2
        let pullUpController: SelectPaymentMethodViewControllerV2 = currentPullUpController ?? storyboard?.instantiateViewController(withIdentifier: "SelectPaymentMethodViewControllerV2") as! SelectPaymentMethodViewControllerV2
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
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
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        if #available(iOS 13.0, *) {
            searchController?.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Buscar", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
            
        } else {
            
            // Fallback on earlier versions
            searchController.searchBar.setPlaceholderTextColorTo(color: UIColor.white.withAlphaComponent(0.5))
            if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                textField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                let backgroundView = textField.subviews.first
                backgroundView?.layer.cornerRadius = 8
                backgroundView?.layer.masksToBounds = true
                textField.setClearButton(color: .white)
            }
        }
        
        searchController.searchBar.setMagnifyingGlassColorTo(color: .white)
        searchController.searchBar.setClearButtonColorTo(color: .white)
        searchController.searchBar.delegate = self
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
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
    }
    
    func addMapTrackingButton(){
        map.showsUserLocation = true
        
        let button = MKUserTrackingButton(mapView: map)
        button.layer.backgroundColor = Color.orange.rgb_236_106_53.cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        self.view.addSubview(button)
        
        let scale = MKScaleView(mapView: map)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.topbarHeight),
                                     button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -6),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
    }
    
    private func addPullUpController(animated: Bool) {
        let pullUpController = makePaymentMethodControllerIfNeeded()
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: animated)
    }
    
    private func setupLayout() {
        self.addMapTrackingButton()
        guard
            let navigationController = self.navigationController,
            let gradientImage = CAGradientLayer.viewToImageGradient(on: navigationController.navigationBar)
        else {
            print("Error creating gradient color!")
            return
        }
        
        configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor(patternImage: gradientImage), tintColor: .white, title: "Bora Brasil", preferredLargeTitle: false)
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
        else if let vc = segue.destination as? LookingViewController, segue.identifier == "startLooking" {
            vc.delegate = self
        }
        else if let vc = segue.destination as? TravelViewController, segue.identifier == "startTravel" {
            vc.onReviewBlock = {(_ object: Any?, _ isReview: Bool) -> Void in
                if (isReview) {
                    self.map.removeRoute()
                }
            }
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
        
        // Remove route
        self.map.removeRoute()
        
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
        
        var estimatedTravelDistance: Int = 100000
        var estimatedTravelTime: Int = 30
        
        if let leg = self.directionsResponse!.routes.first?.legs.first {
            estimatedTravelDistance = leg.distance.value
            estimatedTravelTime = leg.duration.value/60
        }
        
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: service.id!, quantity: 1)], intervalMinutes: 0, paymentType: payType, estimatedTravelTime: estimatedTravelTime, estimatedTravelDistance: estimatedTravelDistance, priceEstimate: service.priceEstimate ?? 0.0)).execute() { result in
            switch result {
            case .success(_):
                self.performSegue(withIdentifier: "startLooking", sender: nil)
                self.goBackFromServiceSelection()
                
            case .failure(let error):
                if error.status == .DriversUnavailable {
                    let popup = DialogBuilder.getDialogForMessage(title: "Desculpa", message: "No momento não temos nenhum motorista disponível na sua região", buttonTitle: "OK", completion: nil)
                    self.present(popup, animated: true, completion: nil)
                    return
                }
                
                error.showAlert()
            }
        }
    }
    
    func RideLaterSelected(service: Service, minutesFromNow: Int) {
        let locs = pointsAnnotations.map() { annotation in
            return LocationWithName(loc: annotation.coordinate, add: annotation.title!)
        }
        
        var estimatedTravelDistance: Int = 100000
        var estimatedTravelTime: Int = 30
        
        if let leg = self.directionsResponse!.routes.first?.legs.first {
            estimatedTravelDistance = leg.distance.value
            estimatedTravelTime = leg.duration.value/60
        }
        
        RequestService(obj: RequestDTO(locations: locs, services: [OrderedService(serviceId: 1, quantity: 1)], intervalMinutes: minutesFromNow, paymentType: "", estimatedTravelTime: estimatedTravelTime, estimatedTravelDistance: estimatedTravelDistance, priceEstimate: service.priceEstimate ?? 0.0)).execute() { result in
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

        if let app = UIApplication.shared.delegate as? AppDelegate, let view = app.window {
            LoadingOverlay.shared.showOverlay(view: view)
        }
        
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
        
        let locs = pointsAnnotations.map() { return $0.coordinate }
        let origin = CLLocation.init(latitude: CLLocationDegrees.init(locs.first?.latitude ?? 0.0),
                                     longitude: CLLocationDegrees.init(locs.first?.longitude ?? 0.0))
        let stops = CLLocation.init(latitude: CLLocationDegrees.init(locs.last?.latitude ?? 0.0),
                                    longitude: CLLocationDegrees.init(locs.last?.longitude ?? 0.0))
        
        
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
    
    func AddDestination() {
        let ann = MKPointAnnotation()
        ann.coordinate = map.camera.centerCoordinate
        ann.title = searchController.searchBar.text ?? ""
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
        map.isUserInteractionEnabled = true
        let locs = pointsAnnotations.map() { return $0.coordinate }
        
        let apiKey = "AIzaSyCF3ycW_tYscKuEIcAKel7k6BXBjKC34SM"
        let firstLatitude =  String(locs.first?.latitude ?? 0.0)
        let firstLongitude = String(locs.first?.longitude ?? 0.0)
        let secondLatitude =  String(locs[1].latitude)
        let secondLongitude = String(locs[1].longitude)
        let directionRequest = "origin=\(firstLatitude),\(firstLongitude)&destination=\(secondLatitude),\(secondLongitude)"
        
        let compl = "?region=br&\(directionRequest)&key=\(apiKey)"
        let url = "https://maps.googleapis.com/maps/api/directions/json\(compl)"
        
        EasyRequest<DirectionsResponse>.get(self, path: "geocoded_waypoints", url: url) { (directions) in
   
            self.directionsResponse = directions
            var estimatedTravelDistance: Int = 100000
            var estimatedTravelTime: Int = 30
            var points: String? = nil
            
            if let leg = self.directionsResponse!.routes.first?.legs.first, let route = self.directionsResponse!.routes.first {
                estimatedTravelDistance = leg.distance.value
                estimatedTravelTime = leg.duration.value/60
                points = route.overviewPolyline.points
            }
            
            DispatchQueue.main.async() {
                
                self.estimateViewModel.getEstimate(initLat: firstLatitude, initLong: firstLongitude, endLat: secondLatitude, endLong: secondLongitude, completion: { (estimate) -> Void in
                    
                    CalculateFare(uf: self.stateCurrent, locations: locs, estimatedTravelDistance: estimatedTravelDistance, estimatedTravelTime: estimatedTravelTime, points: points).execute() { result in
                        
                        LoadingOverlay.shared.hideOverlayView()
                        
                        switch result {
                        case .success(let response):
                            self.servicesViewController?.calculateFareResult = response
                            self.servicesViewController?.estimate = estimate
                            self.containerServices.isHidden = false
                            self.servicesViewController?.reload()
                        case .failure(let error):
                            self.goBackFromServiceSelection()
                            error.showAlert()
                        }
                    }
                })
            }
        }
    }
    
    func getAddressForLatLng(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if let placeID = selectedPlaceId {
            let placesClient = GMSPlacesClient.shared()
            selectedPlaceId = nil
            placesClient.lookUpPlaceID(placeID) { (place, error) in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                guard let place = place else {
                    return
                }
                
                if (!self.searchingPlaces) { self.searchController.searchBar.text = place.formattedAddress }
                self.buttonConfirmPickup.isEnabled = true
                self.buttonAddDestination.isEnabled = true
                self.buttonConfirmFinalDestination.isEnabled = true
            }
            
        } else {
            geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    let formatter = CNPostalAddressFormatter()
                    let addressString = formatter.string(from: firstLocation!.postalAddress!)
                    self.stateCurrent = firstLocation?.administrativeArea ?? "SP"
                    if (!self.searchingPlaces) { self.searchController.searchBar.text = addressString }
                    self.buttonConfirmPickup.isEnabled = true
                    self.buttonAddDestination.isEnabled = true
                    self.buttonConfirmFinalDestination.isEnabled = true
                }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return self.map.rendererBuilder(mapView, rendererFor: overlay)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.resignFirstResponder()
        print("searchBarCancelButtonClicked")
        searchingPlaces = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.setShowsCancelButton(true, animated: true)
        print("searchBarTextDidBeginEditing")
        searchingPlaces = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.setShowsCancelButton(false, animated: true)
        print("searchBarTextDidEndEditing")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.resignFirstResponder()
        //dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        
        print("searchBarSearchButtonClicked")
    }
    
    @objc func keyboardWillAppear() {
        //Do something here
    }
    
    @objc func keyboardWillDisappear() {
        //Do something here
        searchingPlaces = false
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
        var oldCoordinate = annotation.coordinate
        let newCoordinate = annotation.coordinate
        if(pointsAnnotations.contains(annotation)) {
            identifier = MarkerType.dropoff
        } else {
            identifier = MarkerType.driver
            
        }
        
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) as? MKMarkerAnnotationView {
            oldCoordinate = dequeuedView.annotation?.coordinate ?? annotation.coordinate
            dequeuedView.annotation = annotation
            view = dequeuedView
            
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier.rawValue)
        }
        
        switch(identifier) {
        case .pickup:
            view.glyphImage = UIImage(named: "annotation_glyph_home")
            view.markerTintColor = UIColor(hex: 0x009688)
            break;
            
        case .dropoff:
            view.markerTintColor = UIColor(hex: 0xFFA000)
            break;
            
        case .driver:
            view.image = UIImage(named: "car")
            view.glyphImage = nil
            view.glyphTintColor = .clear
            view.tintColor = .clear
            view.markerTintColor = .clear
            
            view.transform = (view.transform.rotated(by: CGFloat(self.map.getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate))
            ))
            break
        //            default:
        //                view.glyphImage = UIImage(named: "annotation_glyph_car")
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
extension MainViewController: SelectPaymentMethodViewControllerV2Delegate {
    
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
    
    func cardsLoaded() {
        LoadingOverlay.shared.hideOverlayView()
    }
}


extension MainViewController: EasyRequestDelegate {
    
    func onError() {
        DispatchQueue.main.async() {
            LoadingOverlay.shared.hideOverlayView()
            let popup = DialogBuilder.getDialogForMessage(message: "Ocorreu um erro ao tentar buscar os dados. Por favor, tente novamente.", completion: nil)
            self.present(popup, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */
    
    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.statusBarFrame.size.height +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
}

extension UISearchBar {
    
    func setMagnifyingGlassColorTo(color: UIColor) {
        // Search Icon
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
    
    func setClearButtonColorTo(color: UIColor) {
        // Clear Button
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let crossIconView = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossIconView?.tintColor = color
    }
    
    func setPlaceholderTextColorTo(color: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}


//MARK: - GMSAutocompleteViewControllerDelegate
// Handle the user's selection.
extension MainViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name ?? "")")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(place.attributions ?? NSAttributedString(string: ""))")
        selectedPlaceId = place.placeID
        searchController.searchBar.text = place.formattedAddress
        searchingPlaces = false
        self.coordinateSelected(place.coordinate)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
    
    func coordinateSelected(_ cLLocationCoordinate2D: CLLocationCoordinate2D) {
        self.map.setCenter(cLLocationCoordinate2D, animated: true)
    }
}
