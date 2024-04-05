//
//  FetchBusinessData.swift
//  FoodSelector
//
//  Created by Bryce Ellet on 2/12/24.
//

import Foundation
import CoreLocation
import UIKit

extension HalfVC {
    
    func retrieveVenues(latitude: Double, longitude: Double, category: String, limit: Int, sortBy: String, locale: String, completionHandler: @escaping ([Venue]?, Error?) -> Void) {
        // MARK: Retrieve venues from Yelp API
        let apikey = "DFgIg3cSyr9SyobRBunDG8Yyfj9H2rVuZFkNYbn8CYoAsDz3rvsAGBxTuquB1AwKwF3iYyUjQuXgOwMUcPSChovjgplkzyBBUNG9rAf4MNFV1GVtxAZAA_HxBUzKZXYx"
        
        /// create URL
        let baseURL = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&locale=\(locale)"
        let url = URL(string: baseURL)
        
        /// calling request
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        /// Initialize session and task
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            if data != nil {
                do {
                    /// Read data as JSON
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])

                    /// Main dictionary
                    guard let resp = json as? NSDictionary else { return }
                    
                    /// Businesses
                    guard let businesses = resp.value(forKey: "businesses") as? [NSDictionary] else { return }
                    var venuesList: [Venue] = []
                    
                    /// Accessing each business
                    for business in businesses {
                        var venue = Venue()
                        
                        venue.id = business.value(forKey: "id") as? String
                        venue.name = business.value(forKey: "name") as? String
                        venue.rating = business.value(forKey: "rating") as? Float
                        venue.phone = business.value(forKey: "phone") as? String
                        venue.distance = business.value(forKey: "distance") as? Double
                        venue.reviews = business.value(forKey: "review_count") as? Int
                        venue.address = business.value(forKeyPath: "location.address1") as? String
                        venue.imagePath = business.value(forKeyPath: "image_url") as? String
                        venue.city = business.value(forKeyPath: "location.city") as? String
                        venue.country = business.value(forKeyPath: "location.country") as? String
                        venue.longitude = business.value(forKeyPath: "coordinates.longitude") as? Double
                        venue.latitude = business.value(forKeyPath: "coordinates.latitude") as? Double
                        
                        // ---Rating---
                        if venue.rating == nil {
                            if venue.phone == "$$$$" {
                                venue.rating = 4
                            } else {
                                venue.rating = Float.random(in: 2.5...3.9)
                            }
                        }
                        
                        // ---Distance---
                        let userLocation = (latitude: self.CPLatitude, longitude: self.CPLongitude)
                        let restaurantLocation = (latitude: venue.latitude!, longitude: venue.longitude!)
                        
                        let distance = getDistanceFromUserToRestaurant(userLocation: userLocation, restaurantLocation: restaurantLocation)
                        if self.miles {
                            let distanceInMiles = distance * 0.621371 // 1 kilometer = 0.621371 miles
                            venue.distance = distanceInMiles
                        } else {
                            venue.distance = distance
                        }
                        
                        venuesList.append(venue)
                    }
                    completionHandler(venuesList, nil)
                } catch {
                    print("Caught error")
                }
            } else {
                // no internet connection
                print("bad connection")
            }
        }.resume()
    }
}

func getDistanceFromUserToRestaurant(userLocation: (latitude: Double, longitude: Double), restaurantLocation: (latitude: Double, longitude: Double)) -> Double {
    let userLatitude = userLocation.latitude
    let userLongitude = userLocation.longitude
    let restaurantLatitude = restaurantLocation.latitude
    let restaurantLongitude = restaurantLocation.longitude

    let earthRadius: Double = 6371 // Earth radius in kilometers

    let dLat = (restaurantLatitude - userLatitude).degreesToRadians
    let dLon = (restaurantLongitude - userLongitude).degreesToRadians

    let a = sin(dLat / 2) * sin(dLat / 2) +
            sin(dLon / 2) * sin(dLon / 2) * cos(userLatitude.degreesToRadians) * cos(restaurantLatitude.degreesToRadians)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return earthRadius * c
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
}


