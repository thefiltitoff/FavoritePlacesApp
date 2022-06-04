//
//  NewPlaceTableViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/4/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit

class NewPlaceTableViewController: UITableViewController {

    @IBOutlet var placeNameTextField: UITextField!
    @IBOutlet var placeLocationTextField: UITextField!
    @IBOutlet var placeTypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
           view.endEditing(true)
        }
    }

}

// MARK: Work with text field Delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
