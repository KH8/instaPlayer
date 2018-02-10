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
    
    var items: [AllegroClientResponseItem] = []
    
    var allegroClient : AllegroClient = AllegroClient()
    
    @IBOutlet weak var messages: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUserDefaults()
        if artistName != nil && collectionName != nil {
            messages.text = "Searching for " + artistName! + " - " + collectionName!
            initializeOffersData()
        } else {
            messages.text = "No data to search for"
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
        allegroClient.search(artist: artistName!, album: collectionName!, completionHandler: handleAllegroResponse)
    }
    
    func handleAllegroResponse(response: AllegroClientResponse?, error: AllegroClientResponseError?) {
        DispatchQueue.main.async{
            if error != nil {
                self.messages.text = "An error occured while retriving data"
                return
            }
            if !(response?.itemsGroups.isEmpty)! {
                self.items = (response?.itemsGroups[0].items)!
                self.messages.text = "Data found"
                self.tableView.reloadData()
            } else {
                self.messages.text = "Could not find any data for given record"
            }
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allegroSearch", for: indexPath) as? ListViewCell
        let row = items[indexPath.row]
        cell?.product.text = row.title.text.components(separatedBy: CharacterSet.punctuationCharacters).joined()
        cell?.price.text = row.price.normal.amount + " " + row.price.normal.currency
        return cell!
    }

}
