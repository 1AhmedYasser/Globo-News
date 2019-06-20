//
//  HeadlinesViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/8/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import ViewAnimator

class HeadlinesViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Given News Category
    var category = ""
    
    // pull refresh control
    var refreshControl = UIRefreshControl()
    
    // Animation flags
    var didAnimate = false
    
    // News articles , country names and loaded countries arrays
    var articles = [Article]()
    var countriesNames = [String]()
    var loadedCountries = [Country]()
    
    // Core data shared data controller
    var dataController =  DataController.shared
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewsHeadlines()
    }
    
    // MARK: View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromStorage()
    }
    
    // MARK: View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        category = ""
    }
    
    // Handle refreshing News Articles
    @objc func refreshNews() {
        navigationItem.rightBarButtonItem!.isEnabled = false
        didAnimate = false
        articles.removeAll()
        countriesNames.removeAll()
        collectionView.reloadData()
        requestHeadlinesForCountries(countries: loadedCountries)
    }
    
    // Handle headlines news response
    func handleHeadlineNewsResponse(articles: [Article] ,countryName: String,statusCode: Int, error: Error?) {
        if error != nil || statusCode != 200 {
            handleErrors(statusCode: statusCode,message: countryName ,error: error)
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItem!.isEnabled = true
            return
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = true
        activityIndicator.stopAnimating()
        
        for article in articles {
            if article.urlToImage != nil {
                self.articles.append(article)
                self.countriesNames.append(countryName)
            }
        }
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        collectionView.reloadData()
        if didAnimate == false {
            let fromAnimation = [AnimationType.from(direction: .right, offset: 100.0)]
            collectionView?.performBatchUpdates({
                UIView.animate(views: collectionView.visibleCells,
                               animations: fromAnimation,initialAlpha: 0, duration: 1)
            }, completion: nil)
            didAnimate = true
        }
    }
    
    // Handle presenting the activity view controller and sharing the news article
    @objc func shareNews(_ sender: UIButton) {
        let title = articles[sender.tag].title
        let url = String(articles[sender.tag].url).removingPercentEncoding ?? articles[sender.tag].url
        
        let controller = UIActivityViewController(activityItems: [title,url], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                controller.dismiss(animated: true, completion: nil)
            }else{
                return
            }
        }
        present(controller,animated: true,completion: nil)
    }
    
    // MARK: Helper methods
    
    // A helper method to setup the headlines view controller
    // Add refresh control and load data from store and refresh table
    func setupNewsHeadlines() {
        self.refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        fetchDataFromStorage()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refreshIcon"), style: .plain, target: self, action: #selector(refreshNews))
        navigationItem.rightBarButtonItem!.isEnabled = false
        
        if category.isEmpty {
            navigationItem.title = "Headlines"
            requestHeadlinesForCountries(countries: loadedCountries)
        } else {
            navigationItem.title = category
            requestHeadlinesForCountries(countries: loadedCountries)
        }
    }
    
    // A helper method that send news requests for all saved countries
    func requestHeadlinesForCountries(countries: [Country]){
        activityIndicator.startAnimating()
        for country in countries {
            NewsApi.getHeadlineNews(countryName: ["\(Countries(rawValue: country.country!)!)",country.country!], categoryName: category, completionHandler:handleHeadlineNewsResponse(articles:countryName:statusCode:error:))
        }
    }
    
    // A helper method that fetches data from the core data controller
    func fetchDataFromStorage() {
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            loadedCountries = result
        }
    }
    
}

extension HeadlinesViewController :  UICollectionViewDataSource {
    
    // MARK: Delegate methods
    
    // Number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    // Fill the collection view with the news articles and load the images
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let NewsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        if let articleImageString = articles[indexPath.row].urlToImage {
            
            var imageURL = URL(string: articleImageString)
            NewsCell.newsImage.kf.indicatorType = .activity
            NewsCell.newsImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "PlaceHolder"),options: [.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage
            ]){
                result in
                switch result {
                case .success( _): break
                case .failure( _): do {
                    imageURL =  URL(string: articleImageString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    NewsCell.newsImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "PlaceHolder"),options: [.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),
                        .cacheOriginalImage])
                    }
                }
            }
        }
        
        NewsCell.newsDescription.text = articles[indexPath.row].title
        NewsCell.newsInfoLabel.text = "\(calculateNewsDate(publishedAt: articles[indexPath.row].publishedAt)) | \(countriesNames[indexPath.row])"
        NewsCell.newsShareButton.tag = indexPath.row
        NewsCell.newsShareButton.addTarget(self, action: #selector(shareNews), for: .touchUpInside)
        
        return NewsCell
    }
    
    // Handle opening the news article url
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleUrl = URL(string: articles[indexPath.row].url)
        
        if let articleUrl = articleUrl {
            if UIApplication.shared.canOpenURL(articleUrl) {
                UIApplication.shared.open(articleUrl, options: [:], completionHandler: nil)
            } else {
                showError(controller: self, title: "Error", message: "Can't Open url")
            }
        }
    }
}
