//
//  AllegroClient.swift
//  instaPlayer
//
//  Created by h8 on 09.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import UIKit
import Foundation

class AllegroClient {

    func search(artist: String, album: String, completionHandler: @escaping (AllegroClientResponse?, AllegroClientResponseError?) -> Swift.Void) {
        let criteria = artist + " " + album
        let encodedCriteria = criteria.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: AllegroClientConstants.allegroApiURL + encodedCriteria!)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/html", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var apiResponse: AllegroClientResponse? = nil
            var apiError: AllegroClientResponseError? = nil
            
            if error != nil {
                apiError = AllegroClientResponseError(
                    message: "Allegro API returned error: " + error.debugDescription)
            } else {
                do {
                    let offersJson = self.retrieveOffersJson(data: data!)
                    let decoder = JSONDecoder()
                    apiResponse = try decoder.decode(AllegroClientResponse.self, from: offersJson.data(using: .utf8)!)
                } catch {
                    apiError = AllegroClientResponseError(
                        message: "Could not retrieve response for: " + criteria)
                }
            }
            
            completionHandler(apiResponse, apiError)
        }
        
        task.resume()
    }
    
    func retrieveOffersJson(data: Data) -> String {
        do {
            let input = String(data: data, encoding: .utf8)
            let regex = try NSRegularExpression(pattern: AllegroClientConstants.offersPattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: input!, options: [], range: NSRange(location: 0, length: (input?.utf16.count)!))
            
            if let match = matches.first {
                let range = match.range(at:1)
                if let jsonRange = Range(range, in: input!) {
                    return String(input![jsonRange])
                }
            }
        } catch {}
        return ""
    }
    
}
