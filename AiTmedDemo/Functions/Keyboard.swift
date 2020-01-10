//
//  Keyboard.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

class Keyboard {
    enum State {
        case onScreen
        case offScreen
    }
    
    typealias Action = (KeyboardInfo) -> Void
    
    private var willShowObserver: NSObjectProtocol?
    private var willHideObserver: NSObjectProtocol?
    private var didShowObserver: NSObjectProtocol?
    private var didHideObserver: NSObjectProtocol?
    
    private(set) var state: State = .offScreen
    
    func observeKeyboardWillShow(completion: @escaping Action) {
        willShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            guard let userInfo = notification.userInfo else { fatalError() }
            let keyboardInfo = KeyboardInfo(userInfo)
            completion(keyboardInfo)
        }
    }
    
    func observeKeyboardWillHide(completion: @escaping Action) {
        willHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            guard let userInfo = notification.userInfo else { fatalError() }
            let keyboardInfo = KeyboardInfo(userInfo)
            completion(keyboardInfo)
        }
    }
    
    func observeKeyboardDidShow(completion: @escaping Action) {
        didShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { (notification) in
            self.state = .onScreen
            guard let userInfo = notification.userInfo else { fatalError() }
            let keyboardInfo = KeyboardInfo(userInfo)
            completion(keyboardInfo)
        }
    }
    
    func observeKeyboardDidHide(completion: @escaping Action) {
        didHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil) { (notification) in
            self.state = .offScreen
            guard let userInfo = notification.userInfo else { fatalError() }
            let keyboardInfo = KeyboardInfo(userInfo)
            completion(keyboardInfo)
        }
    }
    
    deinit {
        if let observer = willShowObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = willHideObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = didShowObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = didHideObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    struct KeyboardInfo {
        let beginRect: CGRect
        let endRect: CGRect
        
        init(_ dict: [AnyHashable: Any]) {
            guard let beginRect = (dict[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
                   let endRect =  (dict[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                fatalError()
            }
            
            self.beginRect = beginRect
            self.endRect = endRect
        }
    }
}
