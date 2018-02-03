//
//  ITunesClient.swift
//  instaPlayer
//
//  Created by h8 on 03.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class ITunesClient {
    
    func search(criteria: String, completionHandler: @escaping (ITunesClientResponse?, ITunesClientResponseError?) -> Swift.Void) {
        let encodedCriteria = criteria.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: ITunesClientConstants.iTunesApiURL + encodedCriteria!)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var apiResponse: ITunesClientResponse? = nil
            var apiError: ITunesClientResponseError? = nil
            
            if error != nil {
                apiError = ITunesClientResponseError(
                    message: "iTunes API returned error: " + error.debugDescription)
            } else {
                do {
                    let decoder = JSONDecoder()
                    apiResponse = try decoder.decode(ITunesClientResponse.self, from: data!)
                    if apiResponse!.results.count <= 0 {
                        apiError = ITunesClientResponseError(
                            message: "No results for: " + criteria)
                    }
                } catch {
                    apiError = ITunesClientResponseError(
                        message: "Could not retrieve response for: " + criteria)
                }
            }
            
            completionHandler(apiResponse, apiError)
        }
        
        task.resume()
    }

}
