//
//  FetchBusinessReviews.swift
//  FoodSelector
//
//  Created by Bryce Ellet on 3/14/24.
//

import Foundation

extension InfoVC {

    func getReviewsForBusiness(withId businessId: String, completionHandler: @escaping ([Review]?, Error?) -> Void) {
        let apiKey = "DFgIg3cSyr9SyobRBunDG8Yyfj9H2rVuZFkNYbn8CYoAsDz3rvsAGBxTuquB1AwKwF3iYyUjQuXgOwMUcPSChovjgplkzyBBUNG9rAf4MNFV1GVtxAZAA_HxBUzKZXYx"
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(businessId)/reviews")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Error: Unable to parse JSON")
                    return
                }
                var reviewList: [Review] = []

                if let reviews = json["reviews"] as? [[String: Any]] {
                    for comment in reviews {
                        var review = Review()
                        
                        review.text = comment["text"] as? String
                        review.rating = comment["rating"] as? Float
                        
                        if review.text != nil && review.rating != nil {
                            reviewList.append(review)
                        }
                    }
                    completionHandler(reviewList, nil)
                } else {
                    print("No reviews found for the business")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    // Example usage
//    getReviewsForBusiness(withId: "BUSINESS_ID_HERE")

}
