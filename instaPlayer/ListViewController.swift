//
//  ListViewController.swift
//  instaPlayer
//
//  Created by h8 on 09.02.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import UIKit
import Foundation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var artistName: String?
    
    var collectionName: String?
    
    var vinylOffers: [AllegroClientResponseItem] = []
    
    var cdOffers: [AllegroClientResponseItem] = []
    
    var messages = ["", ""]
    
    var allegroClient : AllegroClient = AllegroClient()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUserDefaults()
        if artistName != nil && collectionName != nil {
            messages[0] = "Searching..."
            messages[1] = "Searching..."
            initializeOffersData()
        } else {
            messages[0] = "No data to search for"
            messages[1] = "No data to search for"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeUserDefaults() {
        artistName = UserDefaults.standard.object(forKey: "artistName") as? String
        collectionName = UserDefaults.standard.object(forKey: "collectionName") as? String
    }
    
    func initializeOffersData() {
        allegroClient.searchForVinylOffers(artist: artistName!, album: collectionName!, completionHandler: handleVinylOffersResponse)
        allegroClient.searchForCdOffers(artist: artistName!, album: collectionName!, completionHandler: handleCdOffersResponse)
    }
    
    func handleVinylOffersResponse(response: AllegroClientResponse?, error: AllegroClientResponseError?) {
        DispatchQueue.main.async{
            if error == nil {
                if !(response?.itemsGroups[0].items.isEmpty)! {
                    self.vinylOffers = (response?.itemsGroups[0].items)!
                    self.tableView.reloadData()
                    return;
                }
            }
            self.messages[0] = "Could not find any offers"
        }
    }
    
    func handleCdOffersResponse(response: AllegroClientResponse?, error: AllegroClientResponseError?) {
        DispatchQueue.main.async{
            if error == nil {
                if !(response?.itemsGroups[0].items.isEmpty)! {
                    self.cdOffers = (response?.itemsGroups[0].items)!
                    self.tableView.reloadData()
                    return;
                }
            }
            self.messages[1] = "Could not find any offers"
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ?
            "Vinyls" : "CD's"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ?
            offerCount(offers: vinylOffers) : offerCount(offers: cdOffers)
    }
    
    func offerCount(offers: [AllegroClientResponseItem]) -> Int {
        return offers.isEmpty ?
            1 : offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return indexPath.section == 0 ?
            offerCell(offers: vinylOffers, alternativeText: messages[0], tableView: tableView, indexPath: indexPath) :
            offerCell(offers: cdOffers, alternativeText: messages[1], tableView: tableView, indexPath: indexPath)
    }
    
    func offerCell(offers: [AllegroClientResponseItem], alternativeText: String, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allegroSearch", for: indexPath) as? ListViewCell
        
        if offers.isEmpty {
            cell?.product.text = alternativeText
            cell?.price.text = ""
            return cell!
        }
        
        let row = offers[indexPath.row]
        cell?.product.text = row.title.text.components(separatedBy:
                CharacterSet.alphanumerics.union(CharacterSet.whitespaces).inverted).joined()
        
        var price = row.price.normal.amount + " " + row.price.normal.currency
        if row.label.text == nil {
            price = price + "*"
        }
        
        cell?.price.text = price
        return cell!
    }

}
