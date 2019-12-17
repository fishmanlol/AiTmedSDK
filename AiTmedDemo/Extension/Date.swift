//
//  Date.swift
//  BluetoothDemo2
//
//  Created by Yi Tong on 6/10/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Date {
    
    init?(year: Int?, month: Int?, day: Int?, hour: Int?, min: Int?, sec: Int?) {
        
        guard let year = year, let month = month, let day = day, let hour = hour, let min = min, let sec = sec else { return nil }
        
        let calendar = Calendar.current
        let timeZone = TimeZone.current
        
        let components = DateComponents(calendar: calendar, timeZone: timeZone, era: nil, year: year, month: month, day: day, hour: hour, minute: min, second: sec, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        if let date = components.date {
            self = date
        } else {
            return nil
        }
    }
    
    var formattedString: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM d, HH:mm"
        
        return dateFormatter.string(from: self)
    }
    
}
