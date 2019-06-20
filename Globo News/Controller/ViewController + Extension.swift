//
//  ViewController + Extension.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import UIKit

// A ui view controller extension that contains behavior shared across all app view controllers
extension UIViewController : UICollectionViewDelegate {
    
    // MARK: Helper Methods
    
    // A helper method to handle different errors
    func handleErrors(statusCode: Int,message: String ,error: Error?) {
        switch statusCode {
        // News Api Errors
        case 1 : showError(controller: self, title: "Error", message: message)
            
        // Http Errors
        case 400: showError(controller: self, title: "Bad Request", message: "The request was unacceptable, often due to a missing or misconfigured parameter")
        case 401: showError(controller: self, title: "Unauthorized", message: "Your API key was missing from the request, or wasn't correct")
        case 429: showError(controller: self, title: "Too Many Requests", message: "You made too many requests within a window of time and have been rate limited")
        case 404: showError(controller: self, title: "Error", message: "File Not Found")
        case 500: showError(controller: self, title: "Server Error", message: "Something went wrong on our side")
        default:  showError(controller: self,title: "Error", message: error?.localizedDescription ?? "")
        }
    }
    
    // A helper method that shows an Alert Box containing a given message
    func showError(controller: UIViewController, title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
    
    // A helper method that calculate the difference between the news date and the device time
    func calculateNewsDate(publishedAt: String) -> String {
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        
        let newsDate = dateFor.date(from: publishedAt)
        let currentDate = Date()
        var timeDifference: String = ""
        
        if let newsDate = newsDate {
            let dateDifference = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: newsDate,to: currentDate)
            
            let year = dateDifference.year ?? 0
            let month = dateDifference.month ?? 0
            let day = dateDifference.day ?? 0
            let hour = dateDifference.hour ?? 0
            let minute = dateDifference.minute ?? 0
            let second = dateDifference.second ?? 0
            
            if year != 0 {
                timeDifference = (year > 1) ? "\(year) years ago" : "\(year) year ago"
            } else if month != 0 {
                timeDifference = (month > 1) ? "\(month) months ago" : "\(month) month ago"
            } else if day != 0 {
                timeDifference = (day > 1) ? "\(day) days ago" : "\(day) day ago"
            } else if hour != 0 {
                timeDifference = (hour > 1) ? "\(hour) hours ago" : "\(hour) hour ago"
            } else if minute != 0 {
                timeDifference = (minute > 1) ? "\(minute) minutes ago" : "\(minute) minute ago"
            } else if second != 0 {
                timeDifference = (second > 1) ? "\(second) seconds ago" : "\(second) second ago"
            }
        }
        return timeDifference
    }
    
    // MARK: Shared Delegate Methods
    
    // Handle opening the news article url
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 10 , left: 50, bottom: 10, right: 50)
    }
}
