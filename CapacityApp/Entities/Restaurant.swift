//
//  Restaurants.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 10/5/20.
//

import MapKit
import UIKit

class Restaurant: NSObject, Codable {
    var title: String
    var latitude: Double
    var longitude: Double
    var address: String
    var rating: Double
    init(title: String, latitude: Double,longitude: Double, address: String, rating: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.rating = rating
        super.init()
    }
}

class RestaurantAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var restaurant : Restaurant
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.title = restaurant.title
        self.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
    }
}
