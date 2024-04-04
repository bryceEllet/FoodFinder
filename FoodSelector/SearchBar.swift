//
//  SearchBar.swift
//  FoodSelector
//
//  Created by there#2 on 3/22/24.
//

import Foundation
import UIKit

extension HalfVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredVenues = []
        if searchText == "" {
            filteredVenues = venues
            venueInfo()
        }
        
        for venue in venues {
            let name = venue.name!.lowercased()
            if name.contains(searchText.lowercased()) {
                filteredVenues.append(venue)
            }
        }
        venueInfo()
        self.venuesTableView.reloadData()
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
