//
//  AllegroClientResponse.swift
//  instaPlayer
//
//  Created by h8 on 10.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import Foundation

struct AllegroClientResponse: Codable {
    var itemsGroups: [AllegroClientResponseItemsGroups]
}

struct AllegroClientResponseItemsGroups: Codable {
    var items: [AllegroClientResponseItem]
}

struct AllegroClientResponseItem: Codable {
    var title: AllegroClientResponseItemTitle
    var price: AllegroClientResponseItemPrice
    var label: AllegroClientResponseItemLabel
}

struct AllegroClientResponseItemTitle: Codable {
    var text: String
}

struct AllegroClientResponseItemPrice: Codable {
    var normal: AllegroClientResponseItemPriceNormal
}

struct AllegroClientResponseItemPriceNormal: Codable {
    var amount: String
    var currency: String
}

struct AllegroClientResponseItemLabel: Codable {
    var text: String?
}

struct AllegroClientResponseError: Codable {
    var message: String
}
