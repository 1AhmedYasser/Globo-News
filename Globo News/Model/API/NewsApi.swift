//
//  NewsApi.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/9/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import UIKit

// A class that handles News api requests
class NewsApi {
    
    // Static api key
    static let apiKey = "672e322a33e044cebd77cb35a8fdebff"
    
    // Struct that contains News info and can be used throughout the app
    struct NewsInfo {
        static var countryName = ""
        static var categoryName = ""
        static var searchPage = 1
        static var totalPages = 0
    }
    
    // Enum that stores the base urls for News api and requests url's
    enum Endpoints {
        static let headlinesBase = "https://newsapi.org/v2/top-headlines?"
        static let everythingBase = "https://newsapi.org/v2/everything?"
        
        case getCountryHeadline
        case getCategoryHeadline
        case searchForNews(String)
        
        var stringValue: String {
            switch self {
            case .getCountryHeadline: return Endpoints.headlinesBase + "country=\(NewsInfo.countryName)"
            case .getCategoryHeadline: return Endpoints.headlinesBase + "country=\(NewsInfo.countryName)&category=\(NewsInfo.categoryName)"
            case .searchForNews(let query): return Endpoints.everythingBase + "q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&sortBy=publishedAt&language=en&pageSize=20&page=\(NewsInfo.searchPage)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    /* A class function that requests headline news for a country given the country name and an optional given
       category
     */
    class func getHeadlineNews(countryName: [String],categoryName: String , completionHandler: @escaping ([Article],String,Int,Error?) -> Void) {
        NewsInfo.countryName = countryName[0]
        NewsInfo.categoryName = categoryName
        let newsUrl = (categoryName.isEmpty) ? Endpoints.getCountryHeadline.url : Endpoints.getCategoryHeadline.url
        _ = newsGetRequest(countryName: countryName, url: newsUrl, responseType: NewsResponse.self, completion: {(response,errorMessage,statusCode,error) in
            
            if let response = response {
                completionHandler(response.articles,countryName[1],statusCode,nil)
            } else {
                completionHandler([],errorMessage,statusCode,error)
            }
        })
    }
    
    // A class function that requests lastest news for a given keyword
    class func searchForNews(keyword:String , completionHandler: @escaping ([Article],String,Int,Error?) -> Void) {
        
        _ = newsGetRequest(countryName: [""], url: Endpoints.searchForNews(keyword).url, responseType: NewsResponse.self, completion: {(response,errorMessage,statusCode,error) in
            
            if let response = response {
                NewsInfo.totalPages = response.totalResults / 20
                completionHandler(response.articles,"",statusCode,nil)
            } else {
                completionHandler([],errorMessage,statusCode,error)
            }
        })
    }
    
    // A class function that handles all news get requests given country name and response type
    class func newsGetRequest<ResponseType: Decodable>(countryName: [String],url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?,String,Int, Error?) -> Void) {
        NewsInfo.countryName = countryName[0]
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil,"",0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data!)
                    DispatchQueue.main.async {
                        completion(responseObject,"",httpStatusCode,nil)
                    }
                } catch {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data!)
                        DispatchQueue.main.async {
                            completion(nil,errorResponse.message,1,error)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil,"",0,error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    switch httpStatusCode {
                    case 400: completion(nil,"",400,error)
                    case 401: completion(nil,"",401,error)
                    case 429: completion(nil,"",429,error)
                    case 404: completion(nil,"",404,error)
                    case 500: completion(nil,"",500,error)
                    default: completion(nil,"",0,error)
                    }
                }
            }
        }
        task.resume()
    }
}

