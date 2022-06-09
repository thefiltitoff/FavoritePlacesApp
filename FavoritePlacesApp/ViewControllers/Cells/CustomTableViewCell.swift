//
//  CustomTableViewCell.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/3/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var placeImageView: UIImageView! {
        didSet {
            placeImageView.layer.cornerRadius = placeImageView.frame.size.height / 2
            placeImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
}
