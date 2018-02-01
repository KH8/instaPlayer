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
    
    @IBOutlet weak var myImg: UIImageView!
    
    @IBOutlet weak var foundResponse: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            myImg.contentMode = .scaleAspectFill
            myImg.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkPicture(_ sender: Any) {
        self.foundResponse.text = "searching..."
        
        let url = URL(string: AppConstants.googleApiURL + AppConstants.googleApiKey)
        
        let imageData:Data =  UIImageJPEGRepresentation(myImg.image!, CGFloat(AppConstants.imageCompression))!
        let base64String = imageData.base64EncodedString()
       
//        let base64String = AppConstants.testImage;
        
        let body = "{\"requests\":[{\"image\":{\"content\":\"" + base64String + "\"},\"features\":[{\"type\":\"WEB_DETECTION\",\"maxResults\":1}]}]}"
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
                let decoder = JSONDecoder()
                let response = try! decoder.decode(VisionAPIResponse.self, from: data!)
                var guess = response.responses[0].webDetection.bestGuessLabels[0].label;
                print(guess)
                
                guess = guess.components(separatedBy: CharacterSet.punctuationCharacters).joined()
                    .replacingOccurrences(of: "cd", with: "")
                    .replacingOccurrences(of: "vinyl", with: "")
                    .replacingOccurrences(of: "poster", with: "")
                print(guess)

                let encodedCriterias = guess.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let url = URL(string: AppConstants.iTunesApiURL + encodedCriterias!)
                
                var request = URLRequest(url: url!)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    DispatchQueue.main.async {
                        let decoder = JSONDecoder()
                        let response = try! decoder.decode(ITunesAPIResponse.self, from: data!)
                        
                        if response.results.count <= 0 {
                            self.foundResponse.text = "No results found for: " + guess + " - " + encodedCriterias!;
                            return;
                        }
                        
                        let result = response.results[0];
                        self.foundResponse.text = result.artistName + " - " + result.trackName + " [" + result.collectionName + "]"
                        
                        let url = URL(string: result.previewUrl)!;
                        let playerItem = AVPlayerItem.init(url: url)
                        self.playerQueue.removeAllItems()
                        self.playerQueue.insert(playerItem, after: nil)
                        //self.playerQueue.play()
                    }
                }
                task.resume()
            }
        }
        task.resume()
    }
    
    @IBAction func playSound(_ sender: Any) {
        let url = URL(string: AppConstants.testSongURL)!;
        let playerItem = AVPlayerItem.init(url: url)
        self.playerQueue.insert(playerItem, after: nil)
        self.playerQueue.play()
    }
    
    @IBAction func stopSound(_ sender: Any) {
        self.playerQueue.pause()
    }
    
    var playerQueue : AVQueuePlayer = {
        return AVQueuePlayer()
    }()
    
    struct VisionAPIResponse: Codable {
        var responses: [VisionResponse]
    }
    
    struct VisionResponse: Codable {
        var webDetection: VisionResponseWebDetection
    }
    
    struct VisionResponseWebDetection: Codable {
        var bestGuessLabels: [VisionResponseBestGuessLabel]
    }
    
    struct VisionResponseBestGuessLabel: Codable {
        var label: String
    }
    
    struct ITunesAPIResponse: Codable {
        var results: [ITunesResponseResults]
    }
    
    struct ITunesResponseResults: Codable {
        var artistName: String
        var collectionName: String
        var trackName: String
        var previewUrl: String
    }
    
}

