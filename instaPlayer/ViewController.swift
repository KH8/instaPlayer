//
//  ViewController.swift
//  instaPlayer
//
//  Created by h8 on 23.01.2018.
//  Copyright © 2018 h8. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageTaken: UIImageView!
    
    @IBOutlet weak var artworkFound: UIImageView!
    
    @IBOutlet weak var messageDisplay: UITextView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    var resultsContainer: ResultContainer!
    
    var googleVisionClient : GoogleVisionClient = GoogleVisionClient()
    
    var iTunesClient : ITunesClient = ITunesClient()
    
    var playerQueue : AVQueuePlayer = AVQueuePlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(nil, forKey: "artistName")
        UserDefaults.standard.set(nil, forKey: "collectionName")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageTaken.contentMode = .scaleAspectFill
            imageTaken.image = ImageCrop().crop(image: pickedImage, to: imageTaken.intrinsicContentSize)
            checkPicture()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkPicture() {
        self.messageDisplay.text = "searching..."
        let imageData:Data =  UIImageJPEGRepresentation(imageTaken.image!, CGFloat(AppConstants.imageCompression))!
        self.googleVisionClient.search(data: imageData, completionHandler: self.handleGoogleResponse)
    }
    
    func handleGoogleResponse(response: GoogleVisionClientResponse?, error: GoogleVisionClientResponseError?) {
        DispatchQueue.main.async {
            if error != nil {
                self.messageDisplay.text = error!.message
                return
            }
            var guess = response?.responses[0].webDetection.bestGuessLabels[0].label
            guess = CriteriaFilter().filter(criteria: guess!)
            self.iTunesClient.search(criteria: guess!, completionHandler: self.handleITunesResponse)
        }
    }
    
    func handleITunesResponse(response: ITunesClientResponse?, error: ITunesClientResponseError?) {
        DispatchQueue.main.async {
            if error != nil {
                self.messageDisplay.text = error!.message
                return
            }
            self.resultsContainer = ResultContainer(response: response!)
            self.initialize(track: self.resultsContainer.current()!)
            self.play()
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        if resultsContainer != nil {
            initialize(track: resultsContainer.next()!)
        }
    }
    
    @IBAction func backward(_ sender: Any) {
        if resultsContainer != nil {
            initialize(track: resultsContainer.previous()!)
        }
    }
    
    func initialize(track: ITunesClientResponseResult) {
        initializeArtwork(track: track)
        initializeMessage(track: track)
        initializePlayer(track: track)
        initializeUserDefaults(track: track)
    }
    
    @IBAction func playPause(_ sender: Any) {
        if isPlaying() {
            pause()
        } else {
            play()
        }
    }
    
    func initializeArtwork(track: ITunesClientResponseResult) {
        let imageUrl = URL(string: track.artworkUrl100)
        let imageData = try? Data(contentsOf: imageUrl!)
        artworkFound.image = UIImage(data: imageData!)
    }
    
    func initializeMessage(track: ITunesClientResponseResult) {
        messageDisplay.text = track.artistName + " - " + track.trackName + " [" + track.collectionName + "]"
    }
    
    func initializePlayer(track: ITunesClientResponseResult) {
        let isPlaying = self.isPlaying()
        
        let url = URL(string: track.previewUrl)!;
        let playerItem = AVPlayerItem.init(url: url)
        playerQueue.removeAllItems()
        playerQueue.insert(playerItem, after: nil)
        
        if isPlaying {
            play()
        }
    }
    
    func initializeUserDefaults(track: ITunesClientResponseResult) {
        UserDefaults.standard.set(track.artistName, forKey: "artistName")
        UserDefaults.standard.set(track.collectionName, forKey: "collectionName")
    }
    
    func isPlaying() -> Bool {
        return playerQueue.rate > 0
    }
    
    func play() {
        if playerQueue.items().count > 0 {
            playerQueue.play()
            togglePlayButton(mode: UIBarButtonSystemItem.pause)
        }
    }
    
    func pause() {
        playerQueue.pause()
        togglePlayButton(mode: UIBarButtonSystemItem.play)
    }
    
    func togglePlayButton(mode: UIBarButtonSystemItem) {
        var items = self.toolBar.items
        items![3] = UIBarButtonItem(barButtonSystemItem: mode, target: self, action: #selector(self.playPause(_:)))
        self.toolBar.setItems(items, animated: true)
    }
    
}

