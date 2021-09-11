//
//  Places.swift
//  Maps and Navigation
//
//  Created by MD Salauddin on 7/8/18.
//  Copyright © 2018 Jorudan. All rights reserved.
//

import UIKit

class Places: Codable {
    let places: [Places]
    
    init(places: [Places]) {
        self.places = actors
    }
}


class Places: Codable {
    let name: String
    let description: String
    let country: String
    let division: String
    let district: String
    let images: String
    
    init(name: String, description: String, country: String, division: String, district: String, images: String){
        self.name = name
        self.description = description
        self.country = country
        self.division = division
        self.district = district
        self.images = images
    }
}
