//
//  ErrorResponse.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/9/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store an error object including error status , error code and error message
struct ErrorResponse: Codable {    
    let status: String
    let code: String
    let message: String
}
