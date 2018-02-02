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
    
    @IBOutlet weak var imageCache: UIImageView!
    
    @IBOutlet weak var myImg: UIImageView!
    
    @IBOutlet weak var foundResponse: UITextView!
    
    var response: ITunesAPIResponse!
    
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
            imageCache.contentMode = .scaleAspectFill
            imageCache.image = crop(image: pickedImage, to: imageCache.intrinsicContentSize)
            checkPicture()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkPicture() {
        self.foundResponse.text = "searching..."
        
        let url = URL(string: AppConstants.googleApiURL + AppConstants.googleApiKey)
        
        let imageData:Data =  UIImageJPEGRepresentation(imageCache.image!, CGFloat(AppConstants.imageCompression))!
        let base64String = imageData.base64EncodedString()
        
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
                
                guess = guess
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
                print(guess)

                let encodedCriterias = guess.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let url = URL(string: AppConstants.iTunesApiURL + encodedCriterias!)
                
                var request = URLRequest(url: url!)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    DispatchQueue.main.async {
                        let decoder = JSONDecoder()
                        self.response = try! decoder.decode(ITunesAPIResponse.self, from: data!)
                        
                        if self.response.results.count <= 0 {
                            self.foundResponse.text = "No results found for: " + guess + " - " + encodedCriterias!;
                            return;
                        }
                        
                        let result = self.response.results[0];
                        self.foundResponse.text = result.artistName + " - " + result.trackName + " [" + result.collectionName + "]"
                        
                        let imageUrl = URL(string: result.artworkUrl100)
                        let imageData = try? Data(contentsOf: imageUrl!)
                        self.myImg.image = UIImage(data: imageData!)
                        
                        let url = URL(string: result.previewUrl)!;
                        let playerItem = AVPlayerItem.init(url: url)
                        self.playerQueue.removeAllItems()
                        self.playerQueue.insert(playerItem, after: nil)
                        self.playerQueue.play()
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
        var artworkUrl100: String
    }
    
    func crop(image: UIImage, to:CGSize) -> UIImage {
        guard let cgimage = image.cgImage else { return image }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
    
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
    
}

