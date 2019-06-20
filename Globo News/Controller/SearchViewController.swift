//
//  SearchViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/13/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import ViewAnimator
import EmptyDataSet_Swift

class SearchViewController: UIViewController{
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // pull refresh control
    var refreshControl = UIRefreshControl()

    // News articles and country names arrays
    var articles = [Article]()
    var countriesNames = [String]()
    
    // Search keyword supplied from search bar
    var searchKeyword = ""
    
    // Load more flag
    var isLoadingMore = false
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNewsSearch()
    }
    
    // MARK: Helper methods
    
    // A helper method to setup the news search controller
    func setupNewsSearch() {
        self.refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refreshIcon"), style: .plain, target: self, action: #selector(refreshNews))
        navigationItem.rightBarButtonItem!.isEnabled = false
    }
    
    // Helper method that handles showing/hiding empty results message
    func EmptyResultsMessage(show: Bool,keyword: String) {
        if show {
            collectionView.emptyDataSetView { view in
                view.titleLabelString(NSAttributedString(string: "No Results"))
                    .detailLabelString(NSAttributedString(string: "No results were found for `\(keyword)`. Try searching for another keyword"))
                    .image(UIImage(named: "EmptyResults"))
            }
        } else {
            collectionView.emptyDataSetView { view in
                view.titleLabelString(NSAttributedString(string: ""))
        }
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
    
    // Delegate Methods
    
    // Search bar begins editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    // Search bar ends editing
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    // Search bar cancel editing
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    // Search bar search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        self.articles.removeAll()
        self.countriesNames.removeAll()
        EmptyResultsMessage(show: false, keyword: "")
        collectionView.reloadData()
        if let searchKeyword = searchBar.text {
            activityIndicator.startAnimating()
            NewsApi.NewsInfo.searchPage = 1
            self.searchKeyword = searchKeyword
            NewsApi.searchForNews(keyword: searchKeyword, completionHandler: handleNewsSearchResponse(articles:countryName:statusCode:error:))
        }
    }
    
    // Handle refreshing News Articles
    @objc func refreshNews() {
        navigationItem.rightBarButtonItem!.isEnabled = false
        activityIndicator.startAnimating()
        articles.removeAll()
        collectionView.reloadData()
        NewsApi.NewsInfo.searchPage = 1
        EmptyResultsMessage(show: false, keyword: "")
        collectionView.reloadData()
        NewsApi.searchForNews(keyword: searchKeyword, completionHandler: handleNewsSearchResponse(articles:countryName:statusCode:error:))
    }
    
     // Handle presenting the activity view controller and sharing the news article
    @objc func shareNews(_ sender: UIButton) {
        let title = articles[sender.tag].title
        let url = String(articles[sender.tag].url).removingPercentEncoding ?? articles[sender.tag].url
        
        let controller = UIActivityViewController(activityItems: [title,url], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                controller.dismiss(animated: true, completion: nil)
            } else {
                return
            }
        }
        present(controller,animated: true,completion: nil)
    }
    
    // Handle headlines news response
    func handleNewsSearchResponse(articles: [Article] ,countryName: String,statusCode:Int, error: Error?) {
        if error != nil || statusCode != 200 {
            handleErrors(statusCode: statusCode,message: countryName ,error: error)
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItem!.isEnabled = true
            return
        }
        
        if articles.count == 0 {
            EmptyResultsMessage(show: true, keyword: searchKeyword)
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = true
        activityIndicator.stopAnimating()

        for article in articles {
            if article.urlToImage != nil {
                self.articles.append(article)
                self.countriesNames.append(countryName)
            } else {
                print("Not an article: \(article.url)")
            }
        }
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        collectionView.reloadData()
        if isLoadingMore == false {
            let fromAnimation = [AnimationType.from(direction: .bottom, offset: 100.0)]
            collectionView?.performBatchUpdates({
                UIView.animate(views: collectionView.visibleCells,
                               animations: fromAnimation,initialAlpha: 0, duration: 1)
            }, completion: nil)
        }
        isLoadingMore = false
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
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
        NewsCell.newsInfoLabel.text = "\(calculateNewsDate(publishedAt: articles[indexPath.row].publishedAt))"
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
                showError(controller: self, title: "Invalid Error", message: "Could not open news article")
            }
        }
    }
    
    // Handle loading more articles upon reaching the end of the page
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = articles.count - 1
        if indexPath.row == lastElement {
            
            if NewsApi.NewsInfo.searchPage <= NewsApi.NewsInfo.totalPages {
                isLoadingMore = true
                NewsApi.NewsInfo.searchPage += 1
                print( NewsApi.NewsInfo.searchPage)
                NewsApi.searchForNews(keyword: searchKeyword, completionHandler: handleNewsSearchResponse(articles:countryName:statusCode:error:))
            }
        }
    }
}
