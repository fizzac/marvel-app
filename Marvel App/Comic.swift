//
//  Comic.swift
//  Marvel App
//
//  Created by Fizza on 8/18/21.
//

import Foundation

struct ComicDataWrapper:Codable
{
    var data:ComicDataContainer
}

struct ComicDataContainer: Codable
{
    var results:[Comic]
}

struct Comic: Codable
{
    var title:String
    var description:String?
    var thumbnail:[String:String]
    
    public init(titleParam:String, descriptionParam:String, thumbnailParam:[String:String])  {
        self.title = titleParam
        self.description = descriptionParam
        self.thumbnail = thumbnailParam
    }
}
