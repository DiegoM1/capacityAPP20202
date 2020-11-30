//
//  GoogleClientRequest.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 11/10/20.
//

import Foundation
import CoreLocation

protocol GoogleClientRequest {

    var googlePlacesKey : String { get set }
    func getGooglePlacesData(forKeyword keyword: String, location: CLLocation,withinMeters radius: Int, using completionHandler: @escaping (GooglePlacesResponse) -> ())
    
}

class GoogleClient: GoogleClientRequest {
    
    //URL Session
    let session = URLSession(configuration: .default)
    
    //Google Places Key
    var googlePlacesKey: String = "AIzaSyB5yBdpwES8Pr3hDA3ZNkq0b7TrjT-UzGk"
    
    //async call to make a request to google for JSON
    func getGooglePlacesData(forKeyword keyword: String, location: CLLocation,withinMeters radius: Int, using completionHandler: @escaping (GooglePlacesResponse) -> ())  {
        
        let url = googlePlacesDataURL(forKey: googlePlacesKey, location: location, keyword: keyword)
        let task = session.dataTask(with: url) { (responseData, _, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = responseData,
                let response = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data) else {
                completionHandler(GooglePlacesResponse(results:[]))
                    return
                }
                completionHandler(response)
            }
            task.resume()
    }
    
    // create the URL to request a JSON from Google
    func googlePlacesDataURL(forKey apiKey: String, location: CLLocation, keyword: String) -> URL {
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        let locationString = "location=" + String(location.coordinate.latitude) + "," + String(location.coordinate.longitude)
        let rankby = "rankby=distance"
        let keywrd = "keyword=" + keyword
        let key = "key=" + apiKey
        
        
        return URL(string: baseURL + locationString + "&" + rankby + "&" + keywrd + "&" + key)!
    }
    
}

