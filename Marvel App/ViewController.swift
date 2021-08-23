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
    //@IBOutlet weak var searchStackView: UIStackView!
    
    var myAttributionURL:String = ""
    let dispatchGroup = DispatchGroup()
    var currentComic = Comic(titleParam: "", descriptionParam: "", thumbnailParam: ["":""], urlsParam: [["":""]])
    let baseURL = "https://gateway.marvel.com/v1/public/comics/"
    let urlKeys = "?ts=1&apikey=32b416300c15b326ac119c7fe07c0fa3&hash=4b048e70838e1b1aba77601ca4582c33"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure displays and variables are empty
        resetVarDisplay()
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any)
    {
        // Dismiss keyboard and reset displays and variables
        idTextField.resignFirstResponder()
        resetVarDisplay()
        
        // Get Comic ID as input from textfield
        let comicID = idTextField.text
        
        //If there is a Comic ID input (textfield is not empty)
        if comicID != "" && comicID != nil
        {
            // Make API call
            makeAPICall(comicID!)
            
            // Wait to be notified that asynchronous tasks have finished, then execute code in this closure
            dispatchGroup.notify(queue: .main)
            {
                
                if self.currentComic.title == "" || self.currentComic.title == nil
                {
                    // If title is empty, assume invalid Comic ID was inputted by the user
                    print("Invalid Comic ID")
                    self.displayAlert("You provided an invalid comic ID. Please try again.")
                }
                else
                {
                    // Replace breaks (<br>) and newline characters (\n) with carriage returns (\r) in the comic description, and remove all extra spaces from the end of the description
                    if self.currentComic.description != "" && self.currentComic.description != nil
                    {
                        self.currentComic.description = self.currentComic.description!.replacingOccurrences(of: "<br>", with: "\r")
                        self.currentComic.description = self.currentComic.description!.replacingOccurrences(of: "\n", with: "\r")
                        while (self.currentComic.description!.hasSuffix("\r"))
                        {
                            self.currentComic.description = String(self.currentComic.description!.dropLast(1))
                        }
                    }
                    else
                    {
                        self.currentComic.description = "Description not available for this comic"
                    }
                    
                    // Display title, description, and attribution url to user
                    self.titleLabel.text = self.currentComic.title!
                    self.descriptionLabel.text = self.currentComic.description!
                    self.attributionLabel.text = "Attribution: " + self.myAttributionURL + "\r\rData provided by Marvel. © 2014 Marvel"
                    
                    // If a url for the image is present, call function to display image to user
                    if self.currentComic.thumbnail?["path"] != "" && self.currentComic.thumbnail != nil
                    {
                        self.setImage()
                    }
                }
            }
        }
        else
        {
            // If there is no Comic ID input (textfield is empty), display alert to user
            displayAlert("You forgot to provide a comic ID. Please try again.")
        }
    }
    
    
    func resetVarDisplay()
    {
        // Clear all variables and display fields
        myAttributionURL = ""
        currentComic = Comic(titleParam: "", descriptionParam: "", thumbnailParam: ["":""], urlsParam: [["":""]])
        titleLabel.text = ""
        descriptionLabel.text = ""
        comicImage.image = nil
        attributionLabel.text = ""
        idTextField.placeholder = "Enter Comic ID"
    }
    
    
    func makeAPICall(_ comicID:String)
    {
        // Notify main thread that asynchronous tasking has been started (main thread will wait for this task to finish before continuing execution)
        dispatchGroup.enter()
        
        // Make URL with user-provided Comic ID input
        let url = URL(string: baseURL + comicID + urlKeys)
             
        // Continue execution if URL object is successfully created and print URL to console, else stop execution and display alert to user
        guard url != nil else {
            print("Error creating URL object")
            displayAlert("Did you enter a comic ID? Please try again.")
            dispatchGroup.leave()
            return
        }
        print("URL object created successfully")
        
        // Create URL request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // Set the request type
        request.httpMethod = "GET"
                
        // Get the URLSession
        let session = URLSession.shared

        // Create the Data Task
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // Check for errors and continue if there are none
            if error == nil && data != nil
            {
                // Try to parse out the data
                let decoder = JSONDecoder()
                
                do {
                    // Parse data into object of type ComicDataWrapper and print it to console
                    let comicWrapper = try decoder.decode(ComicDataWrapper.self, from: data!)
                    print(comicWrapper)
                    
                    // Assign comic title, description, thumbnails, and image url to currentComic object of type Comic and print object to console
                    self.currentComic.title = comicWrapper.data.results[0].title
                    self.currentComic.description = comicWrapper.data.results[0].description ?? "Description not available for this comic"
                    self.currentComic.thumbnail = comicWrapper.data.results[0].thumbnail
                    self.currentComic.urls = comicWrapper.data.results[0].urls
                    print("Current Comic contains the following data")
                    print(self.currentComic)
                                                            
                    // Make sure there is an image url - url might be HTTP (not secure), so secure it by making it HTTPS
                    if self.currentComic.thumbnail?["path"] != "" && self.currentComic.thumbnail != nil
                    {
                        self.currentComic.thumbnail!["path"] = self.secureUrlAsHttps(self.secureUrlAsHttps(self.currentComic.thumbnail!["path"]!))
                    }
                    
                    // If there are no attribution urls, set attribution url to default value
                    if self.currentComic.urls?[0]["type"] == "" || self.currentComic.urls == nil
                    {
                        self.myAttributionURL = "https://marvel.com"
                    }
                    else
                    {
                        // Else (there are attribution urls), try to find the "detail" url and assign to variable
                        for item in self.currentComic.urls!
                        {
                            if item["type"] == "detail"
                            {
                                self.myAttributionURL = item["url"] ?? "https://marvel.com"
                            }
                        }
                        if self.myAttributionURL == ""
                        {
                            // If there is no "detail" attribution url, assign first available url as attribution url
                            self.myAttributionURL = self.currentComic.urls?[0]["url"] ?? "https://marvel.com"
                        }
                    }
                    
                    // URL might be HTTP (not secure), so secure URL by making it HTTPS
                    self.myAttributionURL = self.secureUrlAsHttps(self.myAttributionURL)
                }
                catch
                {
                    // Catch any errors while parsing the data
                    print("Error parsing comic wrapper")
                }
            }
            else
            {
                // If there is an error or if there is no data, there might be a problem with the internet connection, display alert to user
                self.displayAlert("Could not connect to the server. Please check your internet connection or try again later.")
            }
            // Notify the main queue that asynchronous task has ended and main thread can continue execution
            self.dispatchGroup.leave()
        }
        
        // Make the API Call
        dataTask.resume()
    }
    
    
    func displayAlert(_ messagePassed:String)
    {
        // Display alert to user with message that was passed into this function
        let alert = UIAlertController(title: "Oops!", message: messagePassed, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func secureUrlAsHttps(_ currentUrl:String) -> String
    {
        // Assign parameter to variable for editing, this variable will be returned at the end of the function
        var secureUrl = currentUrl
        
        // If the url contains "https://" then it is already secure, print update to console
        if secureUrl.contains("https://")
        {
            print("URL is already HTTPS secure")
        }
        else
        {
            // Else, the url is not secure, so append 's' after HTTP to make the url HTTPS secure and print update to console
            secureUrl.insert("s", at: secureUrl.index(secureUrl.startIndex, offsetBy: 4))
            print("URL has been HTTPS secured")
            print(secureUrl)
        }
        
        // Return url
        return secureUrl
    }
    
    
    func setImage()
    {
        // Notify main thread that asynchronous task has started, main thread will wait for this task to finish before continuing execution
        dispatchGroup.enter()
        
        // Create Image URL with url path, and appended image size and extension
        let myComicImageUrl = URL(string: self.currentComic.thumbnail!["path"]! + "/portrait_xlarge." + self.currentComic.thumbnail!["extension"]!)!
        
        // Create Data Task and get image
        let dataTask = URLSession.shared.dataTask(with: myComicImageUrl) { (data, response, error) in
            if let myData = data
            {
                DispatchQueue.main.async {
                    // Display image to user
                    self.comicImage.image = UIImage(data: myData)
                }
            }
            
            // Notify main thread that aynchronous task has finished execution and main thread can continue executing
            self.dispatchGroup.leave()
        }
        
        // Start Data Task
        dataTask.resume()
    }
}
