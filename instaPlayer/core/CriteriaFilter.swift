//
//  CriteriaFilter.swift
//  instaPlayer
//
//  Created by h8 on 03.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class CriteriaFilter {
    
    func filter(criteria: String) -> String {
        let result = criteria
            .replacingOccurrences(of: "cd", with: "")
            .replacingOccurrences(of: "album", with: "")
            .replacingOccurrences(of: "record", with: "")
            .replacingOccurrences(of: "video", with: "")
            .replacingOccurrences(of: "vhs", with: "")
            .replacingOccurrences(of: "audio", with: "")
            .replacingOccurrences(of: "vinyl", with: "")
            .replacingOccurrences(of: "poster", with: "")
            .components(separatedBy: CharacterSet.punctuationCharacters)
            .prefix(5)
            .joined()
        print("Given criteria: " + criteria)
        print("Filtered criteria: " + result)
        return result
    }
    
}
