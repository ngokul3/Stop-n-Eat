//
//  MapModel.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/28/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class Place{
    var trainStop : TrainStop?
    var restaurants : [Restaurant]?
}

enum PlaceType{
    case train
    case restaurant
}

