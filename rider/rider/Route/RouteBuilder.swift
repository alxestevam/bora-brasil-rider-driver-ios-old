/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MapKit

enum RouteBuilder {
  enum Segment {
    case text(String)
    case location(CLLocation)
  }

  enum RouteError: Error {
    case invalidSegment(String)
  }

  typealias PlaceCompletionBlock = (MKPlacemark?) -> Void
  typealias RouteCompletionBlock = (Result<Route, RouteError>) -> Void

  private static let routeQueue = DispatchQueue(label: "br.com.borabrasil.passageiro.route-builder")

  static func buildRoute(origin: Segment, stops: [Segment], within region: MKCoordinateRegion?, completion: @escaping RouteCompletionBlock) {
    routeQueue.async {
      let group = DispatchGroup()

      var originItem: MKMapItem?
      group.enter()
      requestPlace(for: origin, within: region) { place in
        if let requestedPlace = place {
          originItem = MKMapItem(placemark: requestedPlace)
        }

        group.leave()
      }

      var stopItems = [MKMapItem](repeating: .init(), count: stops.count)
      for (index, stop) in stops.enumerated() {
        group.enter()
        requestPlace(for: stop, within: region) { place in
          if let requestedPlace = place {
            stopItems[index] = MKMapItem(placemark: requestedPlace)
          }

          group.leave()
        }
      }

      group.notify(queue: .main) {
        if let originMapItem = originItem, !stopItems.isEmpty {
          let route = Route(origin: originMapItem, stops: stopItems)
          completion(.success(route))
        } else {
          let reason = originItem == nil ? "the origin address" : "one or more of the stops"
          completion(.failure(.invalidSegment(reason)))
        }
      }
    }
  }

  private static func requestPlace(for segment: Segment, within region: MKCoordinateRegion?, completion: @escaping PlaceCompletionBlock) {
    if case .text(let value) = segment, let nearbyRegion = region {
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = value
      request.region = nearbyRegion

      MKLocalSearch(request: request).start { response, _ in
        let place: MKPlacemark?

        if let firstItem = response?.mapItems.first {
          place = firstItem.placemark
        } else {
          place = nil
        }

        completion(place)
      }
    } else {
      CLGeocoder().geocodeSegment(segment) { places, _ in
        let place: MKPlacemark?

        if let firstPlace = places?.first {
          place = MKPlacemark(placemark: firstPlace)
        } else {
          place = nil
        }

        completion(place)
      }
    }
  }
}

private extension CLGeocoder {
  func geocodeSegment(_ segment: RouteBuilder.Segment, completionHandler: @escaping CLGeocodeCompletionHandler) {
    switch segment {
    case .text(let value):
      geocodeAddressString(value, completionHandler: completionHandler)

    case .location(let value):
      reverseGeocodeLocation(value, completionHandler: completionHandler)
    }
  }
}
