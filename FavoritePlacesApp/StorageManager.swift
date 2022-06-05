//
//  StorageManager.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/5/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
