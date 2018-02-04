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
                } catch {
                    apiError = ITunesClientResponseError(
                        message: "Could not retrieve response for: " + criteria)
                }
            }
            
            if (apiError == nil && apiResponse!.results.count == 0) {
                if criteria.contains(" ") {
                    let reducedCriteria = self.reduceCriteria(criteria: criteria)
                    self.search(criteria: reducedCriteria, completionHandler: completionHandler)
                } else {
                    apiError = ITunesClientResponseError(
                        message: "Could not find any results")
                    completionHandler(apiResponse, apiError)
                }
            } else {
                completionHandler(apiResponse, apiError)
            }
        }
        
        task.resume()
    }
    
    func reduceCriteria(criteria: String) -> String {
        let reducedCriteria = criteria
            .components(separatedBy: " ")
            .dropLast()
            .joined(separator: " ")
        print("- reduced criteria: " + criteria)
        print("- to: " + reducedCriteria)
        return reducedCriteria
    }

}
