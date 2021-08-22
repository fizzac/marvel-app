//
//  ViewController.swift
//  Marvel App
//
//  Created by Fizza on 8/17/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var comicImage: UIImageView!
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var searchStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var myImageURL:String?
    var myAttributionURL:String = ""
    var myComicDescription:String = ""
    let dispatchGroup = DispatchGroup()
    var currentComic = Comic(titleParam: "", descriptionParam: "", thumbnailParam: ["":""], urlsParam: [["":""]])
    let baseURL = "https://gateway.marvel.com/v1/public/comics/"
    let urlKeys = "?ts=1&apikey=32b416300c15b326ac119c7fe07c0fa3&hash=4b048e70838e1b1aba77601ca4582c33"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure displays and variables are empty
        myImageURL = nil
        currentComic = Comic(titleParam: "", descriptionParam: "", thumbnailParam: ["":""], urlsParam: [["":""]])
        titleLabel.text = ""
        descriptionLabel.text = ""
        comicImage.image = nil
        attributionLabel.text = ""
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any)
    {
        idTextField.resignFirstResponder()
        resetVarDisplay()
        
        let comicID = idTextField.text
        if comicID != "" && comicID != nil
        {
            print(comicID!)
            
            makeAPICall(comicID!)
            dispatchGroup.notify(queue: .main)
            {
                if self.currentComic.title == ""
                {
                    print("Invalid Comic ID")
                    self.displayAlert("You provided an invalid comic ID. Please try again.")
                }
                else
                {
                    self.titleLabel.text = self.currentComic.title
                    
                    self.myComicDescription = self.myComicDescription.replacingOccurrences(of: "<br>", with: "\r")
                    self.myComicDescription = self.myComicDescription.replacingOccurrences(of: "\n", with: "\r")
                    
                    while (self.myComicDescription.hasSuffix("\r"))
                    {
                        self.myComicDescription = String(self.myComicDescription.dropLast(1))
                    }
                    
                    // Append Marvel attribution to display it at the bottom of the page, after all the data has been displayed
                    
                    
                    self.descriptionLabel.text = self.myComicDescription
                    self.attributionLabel.text = self.myAttributionURL
                    
                    self.setImage(from: self.myImageURL!)
                }
            }
        }
        else
        {
            displayAlert("You forgot to provide a comic ID. Please try again.")
        }
    }
    
    
    func resetVarDisplay()
    {
        // Clear all variables and display fields
        myImageURL = nil
        currentComic = Comic(titleParam: "", descriptionParam: "", thumbnailParam: ["":""], urlsParam: [["":""]])
        titleLabel.text = ""
        descriptionLabel.text = ""
        comicImage.image = nil
        attributionLabel.text = ""
    }
    
    
    func makeAPICall(_ comicID:String)
    {
        dispatchGroup.enter()
        // URL
        let url = URL(string: baseURL + comicID + urlKeys)
                
        guard url != nil else {
            print("Error creating URL object")
            displayAlert("Did you enter a comic ID? Please try again.")
            return
        }
        print("URL object created successfully")
        
        // URL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // Set the request type
        request.httpMethod = "GET"
                
        // Get the URLSession
        let session = URLSession.shared

        // Create the Data Task
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // Check for errors
            if error == nil && data != nil
            {
                // Try to parse out the data
                let decoder = JSONDecoder()
                
                do {
                    let comicWrapper = try decoder.decode(ComicDataWrapper.self, from: data!)
                    print(comicWrapper)
                    
                    self.currentComic.title = comicWrapper.data.results[0].title
                    self.currentComic.description = comicWrapper.data.results[0].description
                    self.myComicDescription = self.currentComic.description ?? "Description not available for this comic"
                    self.currentComic.thumbnail = comicWrapper.data.results[0].thumbnail
                    self.currentComic.urls = comicWrapper.data.results[0].urls
                    self.myImageURL = self.currentComic.thumbnail["path"]
                    
                    if self.myImageURL != nil
                    {
                        self.myImageURL = self.secureUrlAsHttps(self.myImageURL!)
                        self.myImageURL!.append("/portrait_xlarge." + self.currentComic.thumbnail["extension"]!)
                    }
                                        
                    if self.currentComic.urls[0]["type"] == ""
                    {
                        self.myAttributionURL = "https://marvel.com"
                    }
                    else
                    {
                        for item in self.currentComic.urls
                        {
                            if item["type"] == "detail"
                            {
                                self.myAttributionURL = item["url"] ?? "https://marvel.com"
                            }
                        }
                        if self.myAttributionURL == ""
                        {
                            self.myAttributionURL = self.currentComic.urls[0]["url"] ?? "https://marvel.com"
                        }
                    }

                    self.myAttributionURL = self.secureUrlAsHttps(self.myAttributionURL)
                    //self.myAttributionURL.append()
                    self.myAttributionURL = "Attribution: " + self.myAttributionURL + "\r\rData provided by Marvel. © 2014 Marvel"
                }
                catch
                {
                    print("Error parsing comic wrapper")
                    print(self.currentComic)
                }
            }
            else
            {
                self.displayAlert("Could not connect to the server. Please check your internet connection or try again later.")
            }
            self.dispatchGroup.leave()
        }
        
        // Make the API Call
        dataTask.resume()
    }
    
    
    func displayAlert(_ messagePassed:String)
    {
        let alert = UIAlertController(title: "Oops!", message: messagePassed, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func secureUrlAsHttps(_ currentUrl:String) -> String
    {
        var secureUrl = currentUrl
        
        if secureUrl.contains("https://")
        {
            print("URL is already HTTPS secure")
        }
        else
        {
            secureUrl.insert("s", at: secureUrl.index(secureUrl.startIndex, offsetBy: 4))
            print("URL has been HTTPS secured")
            print(secureUrl)
        }
        
        return secureUrl
    }
    
    
    func setImage(from url:String)
    {
        dispatchGroup.enter()
        
        // Create Image URL
        let myImageURL = URL(string: url)!
        
        // Create Data Task
        let dataTask = URLSession.shared.dataTask(with: myImageURL) { (data, response, error) in
            if let myData = data
            {
                DispatchQueue.main.async {
                    // Set comicImage
                    self.comicImage.image = UIImage(data: myData)
                }
            }
            self.dispatchGroup.leave()
        }
        
        // Start Data Task
        dataTask.resume()
    }
}
