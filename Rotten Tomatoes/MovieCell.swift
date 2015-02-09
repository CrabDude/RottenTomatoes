//
//  MovieCell.swift
//  Rotten Tomatoes
//
//  Created by Adam Crabtree on 2/2/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
