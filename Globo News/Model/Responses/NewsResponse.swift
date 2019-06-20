//
//  NewsResponse.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/9/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

/* A codable struct that store a News article object including request status , total article results and
 an array of article structs
 */
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
