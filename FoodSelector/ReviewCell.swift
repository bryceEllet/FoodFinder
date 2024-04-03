//
//  ReviewCell.swift
//  FoodSelector
//
//  Created by there#2 on 3/14/24.
//

import UIKit

class ReviewCell: UITableViewCell {

    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var reviewRatingLabel: UILabel!
    @IBOutlet weak var reviewRatingImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
