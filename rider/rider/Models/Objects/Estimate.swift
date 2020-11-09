import Foundation

struct EstimateModel: Codable {
    var prices: Array<Prices>

    init(prices: Array<Prices>) {
        self.prices = prices
    }
}

struct Prices: Codable {
    var localized_display_name: String
    var product_id: String?
    var estimate: String?
    var low_estimate: Double?
    var high_estimate: Double?
    var duration: Int?
    var distance: Double?
    
    init(localized_display_name: String,
         product_id: String,
         estimate: String,
         low_estimate: Double,
         high_estimate: Double,
         duration: Int,
         distance: Double
         ) {
        self.localized_display_name = localized_display_name
        self.product_id = product_id
        self.estimate = estimate
        self.low_estimate = low_estimate
        self.high_estimate = high_estimate
        self.duration = duration
        self.distance = distance
    }
}
