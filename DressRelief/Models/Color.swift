//
//  Color.swift
//  bFashionIster
//
//  Created by Mary Martinez on 12/20/16.
//  Copyright © 2016 Mary Martinez. All rights reserved.
//

import Foundation

enum Color: Int, CustomStringConvertible {
    case multi, pattern, blackAndWhite, bold, pastel, neutral, earthy, warm, cool, display

    var description: String {
        switch self {
        case .multi:            return "Multi"
        case .pattern:          return "Pattern"
        case .blackAndWhite:    return "B&W"
        case .bold:             return "Bold"
        case .pastel:           return "Pastel"
        case .earthy:           return "Earthy"
        case .neutral:          return "Neutral"
        case .warm:             return "Warm"
        case .cool:             return "Cool"
        case .display:          return "Select a Color..."
        }
    }
    
    static let allRawValues = multi.rawValue...cool.rawValue
    static let allValues = allRawValues.map { Color(rawValue: $0)!.description }
}
