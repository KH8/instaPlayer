//
//  GoogleVisionClientResponse.swift
//  instaPlayer
//
//  Created by h8 on 02.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

struct GoogleVisionClientResponse: Codable {
    var responses: [GoogleVisionClientNestedResponse]
}

struct GoogleVisionClientNestedResponse: Codable {
    var webDetection: GoogleVisionClientResponseWebDetection
}

struct GoogleVisionClientResponseWebDetection: Codable {
    var bestGuessLabels: [GoogleVisionClientResponseBestGuessLabel]
}

struct GoogleVisionClientResponseBestGuessLabel: Codable {
    var label: String
}

struct GoogleVisionClientResponseError: Codable {
    var message: String
}
