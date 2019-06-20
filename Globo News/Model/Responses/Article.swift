//
//  Article.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/9/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that stores an article information including its source stored in the source struct
struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}
