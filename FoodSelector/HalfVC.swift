//
//  HalfVC.swift
//  FoodSelector
//
//  Created by Bryce Ellet on 2/7/24.
//

import UIKit
import CoreLocation

class HalfVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    // TODO: make it faster/smoother
    // TODO: get rid of open button
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var venuesTableView: UITableView!
    
    // Category buttons
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var ratingsButton: UIButton!
    
    // Category button functions
    @IBAction func distanceButtonPressed(_ sender: UIButton) {
        if cat != 0 { // so didSet only runs if needed (smoother app)
            cat = 0
            filterList(filter: "Distance")
        }
    }
    @IBAction func popularButtonPressed(_ sender: UIButton) {
        if cat != 1 { // so didSet only runs if needed (smoother app)
            cat = 1
            filterList(filter: "Popular")
        }
    }
    @IBAction func priceButtonPressed(_ sender: UIButton) {
        if cat != 2 { // so didSet only runs if needed (smoother app)
            cat = 2
            filterList(filter: "Ratings")
        }
    }
    @IBAction func ratingsButtonPressed(_ sender: UIButton) {
        if cat != 3 { // so didSet only runs if needed (smoother app)
            cat = 3
            filterList(filter: "A-Z")
        }
    }
    
    @IBOutlet weak var venueSearchBar: UISearchBar!
    
    var CPLatitude: Double = 43.57843
    var CPLongitude: Double = -83.75894
    
    var venues: [Venue] = [] // list of all the venues
    var filteredVenues: [Venue] = [] // filtered list of all venues (used to display venues)
    
    // --Used to pass information to the InfoVC--
    var venueNames: [String] = []
    var venueLocations: [CLLocation] = []
    var venueRatings: [Float] = []
    var venueReviewAmounts: [Int] = []
    var venuePrices: [String] = []
    var venueAddresses: [String] = []
    var venueDistance: [Double] = []
    var venueImagePaths: [String] = []
    var venueIds: [String] = []
    
    var ratings: [Float] = [0, 0.5, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
    var grayColor = UIColor(red: 0.59607843, green: 0.82745098, blue: 0.75686275, alpha: 1) // dark green ish button
    var orangeColor = UIColor(red: 0.99607843, green: 0.49803922, blue: 0.42745098, alpha: 1) // orange button
    var loaded = false
    var cat = 0 { // category - how the table view if filtered
        didSet {
            switch cat { // changes apperance of buttons
            case 1:
                distanceButton.tintColor = grayColor
                popularButton.tintColor = orangeColor
                priceButton.tintColor = grayColor
                ratingsButton.tintColor = grayColor
            case 2:
                distanceButton.tintColor = grayColor
                popularButton.tintColor = grayColor
                priceButton.tintColor = orangeColor
                ratingsButton.tintColor = grayColor
            case 3:
                distanceButton.tintColor = grayColor
                popularButton.tintColor = grayColor
                priceButton.tintColor = grayColor
                ratingsButton.tintColor = orangeColor
            default:
                distanceButton.tintColor = orangeColor
                popularButton.tintColor = grayColor
                priceButton.tintColor = grayColor
                ratingsButton.tintColor = grayColor
            }
        }
    }
    var miles = false
    var country = "" {
        didSet {
            if country == "US" || country == "LR" || country == "MM" {
                miles = true
            } else {
                miles = false
            }
        }
    }
    var city = "" {
        didSet {
            cityLabel.text = city
        }
    }
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        venuesTableView.layer.cornerRadius = 20
        venuesTableView.separatorStyle = .singleLine
        
        cat = 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            
            if !loaded {
                loaded = true
                CPLongitude = location.coordinate.longitude
                CPLatitude = location.coordinate.latitude
                
                retrieveVenues(latitude: CPLatitude, longitude: CPLongitude, category: "restraunt", limit: 50, sortBy: "distance", locale: "en_US") { (response, error) in
                    if let response = response {
                        self.venues = response
                        self.filteredVenues = self.venues
                        DispatchQueue.main.async {
                            self.venuesTableView.reloadData()
                            self.venueInfo()
                            for venue in self.filteredVenues {
                                self.city = venue.city!
                                self.country = venue.country!
                            }
                            self.filterList(filter: "Distance")
                        }
                    }
                }
            }
        }
    }
    
    func venueInfo() {
        var count = 0
        for venue in filteredVenues {
            let location = CLLocation(latitude: venue.latitude!, longitude: venue.longitude!)
            if venueNames.count > count {
                venueNames[count] = venue.name!
                venueLocations[count] = location
                venueRatings[count] = venue.rating!
                venueReviewAmounts[count] = venue.reviews!
                venuePrices[count] = venue.phone!
                venueImagePaths[count] = venue.imagePath!
                venueDistance[count] = venue.distance!
                venueAddresses[count] = venue.address!
                venueIds[count] = venue.id!
            } else {
                venueNames.append(venue.name!)
                venueLocations.append(location)
                venueRatings.append(venue.rating!)
                venueReviewAmounts.append(venue.reviews!)
                venuePrices.append(venue.phone!)
                venueImagePaths.append(venue.imagePath!)
                venueDistance.append(venue.distance!)
                venueAddresses.append(venue.address!)
                venueIds.append(venue.id!)
            }
            count += 1
        }
    }
    
    func filterList(filter: String) {
        if filter == "Distance" {
            var error = 0
            repeat {
                error = 0
                var count = 0
                for venue in filteredVenues {
                    if count < filteredVenues.count-1 {
                        if venue.distance! > filteredVenues[count + 1].distance! {
                            let element = filteredVenues.remove(at: count)
                            filteredVenues.insert(element, at: count + 1)
                            error += 1
                        }
                        count += 1
                    }
                }
                venues = filteredVenues
            } while error > 0
        } else if filter == "Popular" {
            var error = 0
            repeat {
                error = 0
                var count = 0
                for venue in filteredVenues {
                    if count < filteredVenues.count-1 {
                        if venue.rating! < filteredVenues[count + 1].rating! {
                            let element = filteredVenues.remove(at: count)
                            filteredVenues.insert(element, at: count + 1)
                            error += 1
                        }
                        count += 1
                    }
                }
                venues = filteredVenues
            } while error > 0
        } else if filter == "A-Z" {
            var count = 0
            var error = 0
            repeat {
                error = 0
                var count = 0
                for venue in filteredVenues {
                    if count < filteredVenues.count-1 {
                        if venue.name! > filteredVenues[count + 1].name! {
                            let element = filteredVenues.remove(at: count)
                            filteredVenues.insert(element, at: count + 1)
                            error += 1
                        }
                        count += 1
                    }
                }
                venues = filteredVenues
            } while error > 0
        } else { // filter == Ratings
            var error = 0
            repeat {
                error = 0
                var count = 0
                for venue in filteredVenues {
                    if count < filteredVenues.count-1 {
                        if venue.reviews! < filteredVenues[count + 1].reviews! {
                            let element = filteredVenues.remove(at: count)
                            filteredVenues.insert(element, at: count + 1)
                            error += 1
                        }
                        count += 1
                    }
                }
                venues = filteredVenues
            } while error > 0
        }
//        venues = filteredVenues // keeps base array updated
        venuesTableView.reloadData()
        venueInfo()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        let venue = filteredVenues[indexPath.row]
            
        cell.venueNameLabel!.text = venue.name
        cell.venueOpenLabel!.text = venue.address
        
        // rating image
        var imagePath = "Review_Ribbon_small_16_"
        var answer: Float = 5
        var venueRating: Float = 0
        
        for number in ratings {
            if number < venue.rating! {
                if answer > (venue.rating! - number) {
                    answer = venue.rating! - number
                    venueRating = number
                }
            } else {
                if answer > (number - venue.rating!) {
                    answer = number - venue.rating!
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
        cell.ratingImage.image = UIImage(named: "\(imagePath)")
        
        // venue image
        if venue.imagePath != "" {
            let url = URL(string: venue.imagePath!)
            if let data = try? Data(contentsOf: url!){
                if let image = UIImage(data:data){
                    DispatchQueue.main.async{
                        cell.venueImage.image = image
                    }
                }
            }
        } else {
            cell.venueImage.image = UIImage(named: "yelp_burst")
        }
        
        // distance
        if self.miles {
            cell.distanceLabel.text = String(format: "%.2f mi", venue.distance ?? "0.0")
        } else {
            cell.distanceLabel.text = String(format: "%.2f km", venue.distance ?? "0.0")
        }
        
        // number of ratings
        if venue.reviews ?? 1 > 1 {
            cell.ratingNumberLabel.text = "\(venue.reviews ?? 1) reviews"
        } else {
            cell.ratingNumberLabel.text = "\(venue.reviews ?? 1) review"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVenues.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform the segue programmatically
        performSegue(withIdentifier: "VenueSegue", sender: indexPath)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VenueSegue" {
            if let indexPath = sender as? IndexPath {
                // Pass data to the destination view controller, if needed
                let infoVC = segue.destination as! InfoVC
                infoVC.venueName = venueNames[indexPath.row]
                infoVC.venueLocation = venueLocations[indexPath.row]
                infoVC.venueRating = venueRatings[indexPath.row]
                infoVC.venueReviewAmount = venueReviewAmounts[indexPath.row]
                infoVC.venuePrice = venuePrices[indexPath.row]
                infoVC.venueImagePath = venueImagePaths[indexPath.row]
                infoVC.venueDistance = venueDistance[indexPath.row]
                infoVC.venueAddress = venueAddresses[indexPath.row]
                infoVC.venueId = venueIds[indexPath.row]
                infoVC.venueMiles = miles
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
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
