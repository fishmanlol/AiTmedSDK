//
//  Date+.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Date {
    var components: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    var year: Int {
        return components.year ?? 0
    }
    
    var month: Int {
        return components.month ?? 0
    }
    
    var day: Int {
        return components.day ?? 0
    }
    
    var formattedDate: String {
        return String(month) + "/" + String(day) + "/" + String("\(year)".suffix(2))
    }
}
