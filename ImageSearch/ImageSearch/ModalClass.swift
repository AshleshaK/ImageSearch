//
//  ModalClass.swift
//  ImageSearch
//
//  Created by Mac on 04/12/21.
//

import Foundation

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let urls: URLS
 
}

struct URLS: Codable {
    let regular: String
}
