//
//  Country.swift
//  NewStartPart
//
//  Created by tongyi on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

struct Country {
    let code: Int
    let fullName: String
    let shortName: String
    
    static let defaultCountry = Country(code: 1, fullName: "United States", shortName: "US")
    
    func shortNameAndCodeString() -> String {
        return "\(shortName) +\(code)"
    }
    
    func fullNameAndCodeString() -> String {
        return "\(fullName)(+\(code))"
    }
}
