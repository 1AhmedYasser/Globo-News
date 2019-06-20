//
//  NewsCell.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/8/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

// A class that presents a custom News Cell used for all news collection views
class NewsCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var newsInfoLabel: UILabel!
    @IBOutlet weak var newsShareButton: UIButton!
    
    // MARK: Awake from Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCardEffect()
    }
    
    // A Helper method that setup the card effect on the news cell
    func setupCardEffect() {
        self.contentView.layer.cornerRadius = 4.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
