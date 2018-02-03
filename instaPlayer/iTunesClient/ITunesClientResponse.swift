//
//  ITunesClientResponse.swift
//  instaPlayer
//
//  Created by h8 on 03.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

struct ITunesClientResponse: Codable {
    var results: [ITunesClientResponseResult]
}

struct ITunesClientResponseResult: Codable {
    var artistName: String
    var collectionName: String
    var trackName: String
    var previewUrl: String
    var artworkUrl100: String
}

struct ITunesClientResponseError: Codable {
    var message: String
}
