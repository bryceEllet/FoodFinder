//
//  InfoVC.swift
//  FoodSelector
//
//  Created by Bryce Ellet on 3/6/24.
//

import UIKit
import MapKit
import CoreLocation

class InfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var venueRatingImage: UIImageView!
    @IBOutlet weak var venueReviewLabel: UILabel!
    @IBOutlet weak var venuePriceLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var venueClosedLabel: UILabel!
    
    var venueName: String?
    var venueLocation: CLLocation?
    var venueRating: Float?
    var venueReviewAmount: Int?
    var venuePrice: String?
    var venueAddress: String?
    var venueDistance: Double?
    var venueImagePath: String?
    var venueId: String?
    var country: String?
    var venueMiles: Bool?
    
    var isHidden: Bool = false
    var ratings: [Float] = [0, 0.5, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
    var reviews: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.layer.cornerRadius = 20
        reviewTableView.separatorStyle = .singleLine
        
        // Add gesture recognizer to the movableView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        mainView.addGestureRecognizer(tapGesture)
        
        mainView.layer.cornerRadius = 50
        mapView.showsUserLocation = true
        
        if let name = venueName {
            venueNameLabel.text = name
        }
        if let location = venueLocation {
            render(location)
        }
        if let rating = venueRating {
            venueRatingImage.image = UIImage(named: getRatingImagePath(rating: rating))
        }
        if let reviewAmount = venueReviewAmount {
            if reviewAmount > 1 {
                venueReviewLabel.text = "\(reviewAmount) reviews"
            } else {
                venueReviewLabel.text = "\(reviewAmount) review"
            }
        }
        if let phone = venuePrice {
            venuePriceLabel.text = formatPhoneNumber(phone)
        }
        if let address = venueAddress {
            venueAddressLabel.text = address
        }
        if let distance = venueDistance {
            if let miles = venueMiles {
                if miles {
                    venueClosedLabel.text = String(format: "%.2f mi", distance)
                } else {
                    venueClosedLabel.text = String(format: "%.2f km", distance)
                }
            }
        }
        if let imagePath = venueImagePath {
            if imagePath != "" {
                let imageUrl = URL(string: imagePath)!
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        // Update UI with the downloaded image on the main thread
                        DispatchQueue.main.async {
                            self.venueImage.image = image
                        }
                    } else {
                        // Handle errors
                        print("Error downloading image: \(error?.localizedDescription ?? "Unknown Error")")
                    }
                }.resume()
            } else {
                self.venueImage.image = UIImage(named: "yelp_burst")
            }
        }
        if let id = venueId {
            getReviewsForBusiness(withId: id, completionHandler: { (response, error) in
                if let response = response {
                    self.reviews = response
                    DispatchQueue.main.async {
                        self.reviewTableView.reloadData()
                    }
                }
            })
            
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    // Method to handle tap gesture
    @objc func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: { [unowned self] in
            if !isHidden {
                mainView.transform = CGAffineTransform(translationX: 0, y: view.frame.height/3)
            } else {
                mainView.transform = CGAffineTransform.identity
            }
            isHidden = !isHidden
        })
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        
        cell.reviewText.text = review.text
        cell.reviewRatingLabel.text = "\(review.rating!)"
        cell.reviewRatingImage.image = UIImage(named: getRatingImagePath(rating: review.rating!))
        return cell
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        // Remove non-numeric characters from the phone number
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Check if the cleaned phone number is empty
        guard !cleanedPhoneNumber.isEmpty else {
            return "Not Available"
        }

        // Format the phone number into the desired format
        var formattedPhoneNumber = ""
        if cleanedPhoneNumber.count == 11 {
            // Format for 10-digit phone numbers (e.g., US phone numbers)
            formattedPhoneNumber = "(\(cleanedPhoneNumber.dropFirst(1).prefix(3)))\(cleanedPhoneNumber.dropFirst(4).prefix(3))-\(cleanedPhoneNumber.dropFirst(7))"
        } else {
            // Format for other phone number lengths
            formattedPhoneNumber = cleanedPhoneNumber
        }
        print("\n\n\(formattedPhoneNumber)\n\n")
        return formattedPhoneNumber
    }
    
    func getRatingImagePath(rating: Float) -> String{
        var imagePath = "Review_Ribbon_small_16_"
        var answer: Float = 5
        var venueRating: Float = 0
        
        for number in ratings {
            if number < rating {
                if answer > (rating - number) {
                    answer = rating - number
                    venueRating = number
                }
            } else {
                if answer > (number - rating) {
                    answer = number - rating
                    venueRating = number
                }
            }
        }
        switch venueRating {
        case 0.5:
            imagePath += "half"
        case 1.5:
            imagePath += "2_1_half"
        case 2:
            imagePath += "2"
        case 2.5:
            imagePath += "2_half"
        case 3:
            imagePath += "3"
        case 3.5:
            imagePath += "3_half"
        case 4:
            imagePath += "4"
        case 4.5:
            imagePath += "4_half"
        case 5:
            imagePath += "5"
        default:
            imagePath += "0"
        }
        
        return imagePath
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
