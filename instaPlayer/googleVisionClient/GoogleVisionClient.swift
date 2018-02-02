//
//  googleVisionClient.swift
//  instaPlayer
//
//  Created by h8 on 02.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class GoogleVisionClient {
    
    func search(data: Data, completionHandler: @escaping (GoogleVisionClientResponse?) -> Swift.Void) {
        let base64String = data.base64EncodedString()
        let body = "{\"requests\":[{\"image\":{\"content\":\"" + base64String + "\"},\"features\":[{\"type\":\"WEB_DETECTION\",\"maxResults\":1}]}]}"

        let url = URL(string: GoogleVisionClientConstants.googleApiURL + GoogleVisionClientSecurity.googleApiKey)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            let decoder = JSONDecoder()
            let response = try! decoder.decode(GoogleVisionClientResponse.self, from: data!)
            completionHandler(response)
        }
        task.resume()
    }
    
}
