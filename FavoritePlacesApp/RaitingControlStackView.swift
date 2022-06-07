//
//  RaitingControlStackView.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/7/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit

@IBDesignable class RaitingControlStackView: UIStackView {
    
    // MARK: Prooperties
    
    private var raitingButtons = [UIButton]()
    
    var raiting = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button action
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = raitingButtons.firstIndex(of: button) else { return }
        
        // Calculate the raiting
        let selectedRating = index + 1
        
        if  selectedRating == raiting {
            raiting = 0
        } else {
            raiting = selectedRating
        }
    }
    
    // MARK: Private methods
    private func setupButtons() {
        for button in raitingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        raitingButtons.removeAll()
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
        
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            // Set th button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Add action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add to stack view
            addArrangedSubview(button)
            
            // Add the new button to array
            
            raitingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in raitingButtons.enumerated() {
            button.isSelected = index < raiting
        }
    }
}
