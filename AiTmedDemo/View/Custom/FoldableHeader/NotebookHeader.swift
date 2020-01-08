//
//  NotebookHeader.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/4/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

protocol NotebookHeaderDelegate: class {
    func notebookHeaderDidOpen(_ header: NotebookHeader, in section: Int)
    func notebookHeaderDidClose(_ header: NotebookHeader, in section: Int)
}

extension NotebookHeaderDelegate {
    func notebookHeaderDidOpen(_ header: NotebookHeader, in section: Int) {}
    func notebookHeaderDidClose(_ header: NotebookHeader, in section: Int) {}
}

class NotebookHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    var section: Int!
    private(set) var open: Bool = true
    
    weak var delegate: NotebookHeaderDelegate?
    
    @objc func didTapHeader(_ sender: UITapGestureRecognizer) {
        open = !open
        toggleOpenAnimation(with: open, animated: true)
        if open {
            delegate?.notebookHeaderDidOpen(self, in: section)
        } else {
            delegate?.notebookHeaderDidClose(self, in: section)
        }
    }
    
    private func toggleOpenAnimation(with: Bool, animated: Bool) {
        if open {
            self.arrowImageView.rotate(.pi * 0.5, animated: animated)
        } else {
            self.arrowImageView.rotate(0, animated: animated)
        }
    }
    
    func configure(title: String, section: Int, delegate: NotebookHeaderDelegate) {
        self.titleLabel.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tap)
        toggleOpenAnimation(with: open, animated: false)
    }
}
