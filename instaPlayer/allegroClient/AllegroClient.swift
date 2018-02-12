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

    func searchForVinylOffers(artist: String, album: String, completionHandler: @escaping (AllegroClientResponse?, AllegroClientResponseError?) -> Swift.Void) {
        let url = prepareSearchURL(baseURL: AllegroClientConstants.allegroApiVinylOffersURL, artist: artist, album: album)
        search(url: url, completionHandler: completionHandler)
    }
    
    func searchForCdOffers(artist: String, album: String, completionHandler: @escaping (AllegroClientResponse?, AllegroClientResponseError?) -> Swift.Void) {
        let url = prepareSearchURL(baseURL: AllegroClientConstants.allegroApiCdOffersURL, artist: artist, album: album)
        search(url: url, completionHandler: completionHandler)
    }
    
    func prepareSearchURL(baseURL: String, artist: String, album: String) -> URL {
        let criteria = artist + " " + album
        let encodedCriteria = criteria.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return URL(string: baseURL + encodedCriteria!)!
    }
    
    func search(url: URL, completionHandler: @escaping (AllegroClientResponse?, AllegroClientResponseError?) -> Swift.Void) {
        var request = URLRequest(url: url)
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
                    apiResponse = self.removeSponsoredOffers(response: apiResponse!)
                } catch {
                    apiError = AllegroClientResponseError(
                        message: "Could not retrieve API response")
                }
            }
            
            completionHandler(apiResponse, apiError)
        }
        
        task.resume()
    }
    
    func removeSponsoredOffers(response: AllegroClientResponse) -> AllegroClientResponse {
        var items: [AllegroClientResponseItem] = []
        response.itemsGroups.forEach { g in
            if g.items.count > items.count {
                items.removeAll()
                items.append(contentsOf: g.items)
            }
        }
        let itemsGroups = AllegroClientResponseItemsGroups(items: items)
        return AllegroClientResponse(itemsGroups: [itemsGroups])
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
