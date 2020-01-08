//
//  UIImage.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/15/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIImage {
    static func from(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    static var earThermometer: UIImage? {
        return UIImage(named: "ear_thermometer")
    }
    
    static var earThermometerDisconnected: UIImage? {
        return UIImage(named: "ear_thermometer_disconnected")
    }
    
    static var pulseOximeter: UIImage? {
        return UIImage(named: "pulse_oximeter")
    }
    
    static var pulseOximeterDisconnected: UIImage? {
        return UIImage(named: "pulse_oximeter_disconnected")
    }
    
    static var bloodPressure: UIImage? {
        return UIImage(named: "blood_pressure")
    }
    
    static var bloodPressureDisconnected: UIImage? {
        return UIImage(named: "blood_pressure_disconnected")
    }
    
    static var scale: UIImage? {
        return UIImage(named: "scale")
    }
    
    static var scaleDisconnected: UIImage? {
        return UIImage(named: "scale_disconnected")
    }
    
    static var infraredThermometer: UIImage? {
        return UIImage(named: "infrared_thermometer")
    }
    
    static var infraredThermometerDisconnected: UIImage? {
        return UIImage(named: "infrared_thermometer_disconnected")
    }
    
    static var faceID: UIImage? {
        return UIImage(named: "face_ID")
    }
    
    static var touchID: UIImage? {
        return UIImage(named: "fingerprint")
    }
}
