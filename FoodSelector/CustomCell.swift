//
//  CustomCell.swift
//  FoodSelector
//
//  Created by Bryce Ellet on 2/13/24.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueOpenLabel: UILabel!
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingNumberLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parentView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
