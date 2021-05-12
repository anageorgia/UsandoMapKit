//
//  File.swift
//  UsandoMapKit
//
//  Created by Ana Geórgia Gama on 03/05/21.
//

import Foundation
import Contacts
import CoreLocation

struct Address {
    var name         : String
    var placemark    : CLPlacemark
    var postalAddress: CNPostalAddress
    
    init(name: String, placemark: CLPlacemark, postalAddress: CNPostalAddress) {
        self.name          = name
        self.placemark     = placemark
        self.postalAddress = postalAddress
    }
}
