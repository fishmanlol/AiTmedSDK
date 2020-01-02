//
//  PlaceholderViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController {
    @IBOutlet weak var placeholderLabel: UILabel!
    
    static func initWithPlaceholder(_ placeholder: String? = nil) -> PlaceholderViewController {
        let instance = R.nib.placeholderViewController(owner: nil)!
        if let placeholder = placeholder {
            instance.placeholderLabel.text = placeholder
        }
        return instance
    }
}
