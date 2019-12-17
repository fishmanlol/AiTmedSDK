//
//  PhoneNumber.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/17/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import PhoneNumberKit

extension PhoneNumber {
    var formattedString: String {
        return "+\(self.countryCode) \(self.nationalNumber)"
    }
}
