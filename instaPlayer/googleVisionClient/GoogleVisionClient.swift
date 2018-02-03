//
//  googleVisionClient.swift
//  instaPlayer
//
//  Created by h8 on 02.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class GoogleVisionClient {
    
    func search(data: Data, completionHandler: @escaping (GoogleVisionClientResponse?, GoogleVisionClientResponseError?) -> Swift.Void) {
        let base64String = data.base64EncodedString()
        search(data: base64String, completionHandler: completionHandler)
    }
    
    func search(data: String, completionHandler: @escaping (GoogleVisionClientResponse?, GoogleVisionClientResponseError?) -> Swift.Void) {
        let url = URL(string: GoogleVisionClientConstants.googleApiURL + GoogleVisionClientSecurity.googleApiKey)
        var request = URLRequest(url: url!)
        
        let body = "{\"requests\":[{\"image\":{\"content\":\"" + data + "\"},\"features\":[{\"type\":\"WEB_DETECTION\",\"maxResults\":1}]}]}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var apiResponse: GoogleVisionClientResponse? = nil
            var apiError: GoogleVisionClientResponseError? = nil
            
            do {
                let decoder = JSONDecoder()
                apiResponse = try decoder.decode(GoogleVisionClientResponse.self, from: data!)
            } catch {
                apiError = GoogleVisionClientResponseError(message: "Could not retrieve response from Google Vision API.")
            }
            
            completionHandler(apiResponse, apiError)
        }
        
        task.resume()
    }
    
}
