//
//  MainTableViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/3/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import RealmSwift

class MainTableViewController: UITableViewController {
    
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  places.isEmpty ? 0 : places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.placeImageView.image = UIImage(data: place.imageData!) // This nevel will be nil


        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.size.height / 2
        cell.placeImageView.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let newPlaceVC = segue.destination as? NewPlaceTableViewController else { return }
            
            let place = places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
        
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

}
