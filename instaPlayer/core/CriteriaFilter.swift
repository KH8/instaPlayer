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
            .components(separatedBy: CharacterSet.punctuationCharacters)
            .prefix(8)
            .joined()
        print("- filtered criteria: " + criteria)
        print("- to: " + result)
        return result
    }
    
}
