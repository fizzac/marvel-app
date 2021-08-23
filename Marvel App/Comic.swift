//
//  Comic.swift
//  Marvel App
//
//  Created by Fizza on 8/18/21.
//

import Foundation

struct ComicDataWrapper:Codable
{
    // This will be used to parse and store the data that is returned by the API call
    
    var data:ComicDataContainer
}

struct ComicDataContainer: Codable
{
    // This will be used to parse and store the array of comics that is returned by the API call
    
    var results:[Comic]
}

struct Comic: Codable
{
    // This will be used to parse and store each individual comic that is returned by the API call
    
    var title:String?
    var description:String?
    var thumbnail:[String:String]?
    var urls:[[String:String]]?
    
    public init(titleParam:String, descriptionParam:String, thumbnailParam:[String:String], urlsParam:[[String:String]])  {
        
        // Initialize Comic object with given parameters
        
        self.title = titleParam
        self.description = descriptionParam
        self.thumbnail = thumbnailParam
        self.urls = urlsParam
    }
}
