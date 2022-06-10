//
//  NewPlaceTableViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/4/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    var currentRating = 0.0

    @IBOutlet var placeNameTextField: UITextField!
    @IBOutlet var placeLocationTextField: UITextField!
    @IBOutlet var placeTypeTextField: UITextField!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1
                                                        )
        )
        
        saveButton.isEnabled = false
        
        placeNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
           view.endEditing(true)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let indentifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
        else { return }
        
        mapVC.incomeSegueIndentifier = indentifier
        mapVC.mapViewControllerDelegate = self
        
        if indentifier == "showPlace" {
            mapVC.place.name = placeNameTextField.text!
            mapVC.place.location = placeLocationTextField.text
            mapVC.place.type = placeTypeTextField.text
            mapVC.place.imageData = photoImageView.image?.pngData()
        }
        
    }
    
    func savePlace() {
        let image = imageIsChanged ? photoImageView.image : #imageLiteral(resourceName: "imagePlaceholder")
        
        let imageData = image?.pngData()
        
        let newPlace = Place(
            name: placeNameTextField.text!, // Because if this field will be empty, save button would not be enable
            location: placeLocationTextField.text,
            type: placeTypeTextField.text,
            imageData: imageData,
            rating: currentRating
        )
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
                
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            setupNavigationBar()
            imageIsChanged = true
            
            photoImageView.image = image
            photoImageView.contentMode = .scaleAspectFill
            placeNameTextField.text = currentPlace?.name
            placeLocationTextField.text = currentPlace?.location
            placeTypeTextField.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
            
            
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    

}

// MARK: Work with text field Delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeNameTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: Work with image
extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
        
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        photoImageView.image = info[.editedImage] as? UIImage
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}

// MARK: Work with MapVCDelegate
extension NewPlaceTableViewController: MapViewControllerDelegate {
    func getAddress(address: String?) {
        placeLocationTextField.text = address
    }
}
