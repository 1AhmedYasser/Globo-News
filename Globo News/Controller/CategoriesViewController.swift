//
//  CategoriesViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/13/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Categories titles and images arrays
    let categoryTitles = ["Business", "Entertainment", "Health","Science","Sports","Technology"]
    let categoryImages = [UIImage(named: "Business"), UIImage(named: "Entertainment"), UIImage(named: "Health"), UIImage(named: "Science"),UIImage(named: "Sports"),UIImage(named: "Technology")]
    
    // Selected category to pass to the headlines controller
    var selectedCategory = ""
    
    // Loaded countries from the core data controller
    var loadedCountries = [Country]()
}

extension CategoriesViewController: UICollectionViewDataSource {
    
    // Delegate Methods
    
    // Number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTitles.count
    }
    
    // Fill category cells with appropriate title and image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        categoryCell.newsImage.image = categoryImages[indexPath.row]
        categoryCell.newsDescription.text = categoryTitles[indexPath.row]
        
        return categoryCell
    }
    
    // handle when a category item is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categoryTitles[indexPath.row]
        performSegue(withIdentifier: "CategorySegue", sender: self)
    }
    
    // Send selected category and loaded countries to headlines view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategorySegue" {
            let HeadlinesVC = segue.destination as! HeadlinesViewController
            HeadlinesVC.category = selectedCategory
            HeadlinesVC.loadedCountries = self.loadedCountries
        }
    }
}
