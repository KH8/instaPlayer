//
//  AllegroClientConstants.swift
//  instaPlayer
//
//  Created by h8 on 09.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

class AllegroClientConstants {
    static let allegroApiVinylOffersURL = "https://allegro.pl/kategoria/plyty-winylowe-279?order=p&strategy=NO_FALLBACK&string="
    static let allegroApiCdOffersURL = "https://allegro.pl/kategoria/plyty-kompaktowe-175?order=p&strategy=NO_FALLBACK&string="
    static let offersPattern = "(?<=ItemsStoreState = )(.*)(?=;)"
}
