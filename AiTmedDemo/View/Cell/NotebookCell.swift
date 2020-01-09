//
//  NotebookCell.swift
//  SplitViewControllerDemo
//
//  Created by tongyi on 12/3/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class NotebookCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var observation: NSKeyValueObservation?
    var isLoading: Bool {
        get {
            return indicator.isAnimating
        }
        
        set {
            if newValue {
                indicator.startAnimating()
                notesCountLabel.isHidden = true
                isUserInteractionEnabled = false
            } else {
                indicator.stopAnimating()
                notesCountLabel.isHidden = false
                isUserInteractionEnabled = true
            }
        }
    }
    
    override func awakeFromNib() {
        backgroundColor = .clear
        observation = observe(\.indicator.isAnimating, options: [.new]) { (object, change) in
            guard let isAnimating = change.newValue else { return }
            self.notesCountLabel.isHidden = isAnimating
        }
    }
}
