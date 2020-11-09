import Foundation
import Alamofire

class EstimateViewModel {
    
    func getEstimate(initLat: String, initLong: String, endLat: String, endLong: String,
                     completion: @escaping (EstimateModel) -> ()) {
        
        let estimate = EstimateModel(prices: [Prices(localized_display_name: "localized",
                                                     product_id: "id",
                                                     estimate: "0.0",
                                                     low_estimate: 0.0,
                                                     high_estimate: 0.0,
                                                     duration: 0,
                                                     distance: 0.0)
        ])
        
        let parameters: Parameters = [
             "startLat": initLat,
             "startLng": initLong,
             "endLat": endLat,
             "endLng": endLong
        ]
        
        AF.request(Config.baseEstimate + "Estimate_Uber",
                   parameters: parameters)
            .responseJSON{ response in
                
                guard let data = response.data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let estimates = try decoder.decode(EstimateModel.self, from: data)
                    
                    completion(estimates)
                    
                } catch {
                    completion(estimate)
                }
                
            }
    }
}
