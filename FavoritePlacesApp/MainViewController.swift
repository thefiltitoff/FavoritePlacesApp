//
//  MainTableViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/3/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        searchController.isActive && !searchBarIsEmpty
    }
    
    private var ascendingSorting = true
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var sortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.isActive = false
        
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        
        return places.isEmpty ? 0 : places.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.placeImageView.image = UIImage(data: place.imageData!) // This nevel will be nil


        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.size.height / 2
        cell.placeImageView.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
            
            let place: Place
            
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
            guard let newPlaceVC = segue.destination as? NewPlaceTableViewController else { return }
            
            newPlaceVC.currentPlace = place
        }
        
    }
    
    @IBAction func sortSelectionTapped(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverseSortingTapped(_ sender: Any) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            sortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }

}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearhText(searchController.searchBar.text!) // Never will be nil
    }
    
    func filterContentForSearhText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
    
    
}
