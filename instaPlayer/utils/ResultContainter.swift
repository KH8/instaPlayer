//
//  ResultContainter.swift
//  instaPlayer
//
//  Created by h8 on 03.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class ResultContainer {
    
    var response: ITunesClientResponse
    
    var index: Int
    
    init(response: ITunesClientResponse) {
        self.response = response
        self.index = 0
    }
    
    func current() -> ITunesClientResponseResult? {
        if (response.results.count <= 0) {
            return nil
        }
        return response.results[index]
    }
    
    func next() -> ITunesClientResponseResult? {
        index = index + 1
        if (index > response.results.count - 1) {
            index = 0
        }
        return current()
    }
    
    func previous() -> ITunesClientResponseResult? {
        index = index - 1
        if (index < 0) {
            index = response.results.count - 1
        }
        return current()
    }
    
}
