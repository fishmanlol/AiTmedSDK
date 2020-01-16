//
//  NotebookSelectionView.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/15/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class NotebookSelectionView: UIView {
    @IBOutlet weak var notebookButton: UIButton!
    @IBAction func notebookButtonTapped(_ sender: Any) {
        
    }
    
    func setNotebooktitle(_ title: String) {
        notebookButton.setTitle(title, for: .normal)
    }
    
    static func initWithNib() -> NotebookSelectionView {
        return Bundle.main.loadNibNamed(R.nib.notebookSelectionView.name, owner: nil, options: nil)?.first as! NotebookSelectionView
    }
}
