//
//  Place.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/4/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation

struct Place {
    
    let name: String
    let location: String
    let type: String
    
    let image: String
    
    static let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "St. Petersburg", type: "Restaurant", image: place))
        }
        
        return places
    }
}
