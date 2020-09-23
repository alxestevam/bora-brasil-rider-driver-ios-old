//
//  MKMapView+Util.swift
//  rider
//
//  Created by Victor Baleeiro on 23/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    // MARK: - Helpers
    func rendererBuilder(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = Color.orange.rgb_236_106_53
        renderer.lineWidth = 3
        
        return renderer
    }
    
    func groupAndRequestDirections(route: Route?, groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)], completion: @escaping ([(startItem: MKMapItem, endItem: MKMapItem)])->()) {
        
        guard let firstStop = route?.stops.first else {
            completion(groupedRoutes)
            return
        }
        
        guard let validRoute = route else {
            completion(groupedRoutes)
            return
        }
        
        var newGroupedRoutes = groupedRoutes
        newGroupedRoutes.append((validRoute.origin, firstStop))
        
        if validRoute.stops.count == 2 {
            let secondStop = validRoute.stops[1]
            
            newGroupedRoutes.append((firstStop, secondStop))
            newGroupedRoutes.append((secondStop, validRoute.origin))
        }
        
        fetchNextRoute(groupedRoutes: newGroupedRoutes) { (result) -> () in
            completion(result)
        }
    }
    
    private func fetchNextRoute(groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)], completion: @escaping ([(startItem: MKMapItem, endItem: MKMapItem)])->()) {
        guard !groupedRoutes.isEmpty else {
            completion(groupedRoutes)
            return
        }
        
        var newGroupedRoutes = groupedRoutes
        let nextGroup = newGroupedRoutes.removeFirst()
        let request = MKDirections.Request()
        
        request.source = nextGroup.startItem
        request.destination = nextGroup.endItem
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            defer {
                completion(newGroupedRoutes)
            }
            
            guard let mapRoute = response?.routes.first else {
                print("No route")
                return
            }
            
            self.updateView(with: mapRoute)
            //self.fetchNextRoute(groupedRoutes: &groupedRoutes)
        }
    }
    
    func removeRoute() {
        // Remove route
        for ov in self.overlays {
            self.removeOverlay(ov)
        }
    }
    
    private func updateView(with mapRoute: MKRoute) {
        let padding: CGFloat = 8
        self.addOverlay(mapRoute.polyline)
        setVisibleMapRect(
            self.visibleMapRect.union(
                mapRoute.polyline.boundingMapRect
            ),
            edgePadding: UIEdgeInsets(
                top: 0,
                left: padding,
                bottom: padding,
                right: padding
            ),
            animated: true
        )
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        return (degree >= 0) ? degree : (360 + degree)
    }
}
