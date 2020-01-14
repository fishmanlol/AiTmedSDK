//
//  EmptyFooterView.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/13/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

protocol EmptyFooterViewDelegate: AnyObject {
    var title: NSAttributedString? { get }
    var buttonTitle: NSAttributedString? { get }
    func emptyFooterViewDidButtonTapped(_ v: EmptyFooterView)
}

extension EmptyFooterViewDelegate {
    var title: NSAttributedString? {
        return nil
    }
    
    var buttonTitle: NSAttributedString? {
        return nil
    }
    
    func emptyFooterViewDidButtonTapped(_ v: EmptyFooterView) {}
}

class EmptyFooterView: UIView {
    lazy var titleLabel: UILabel = createTitleLabel()
    lazy var titleButton: UIButton = createTitleButton()
    
    weak var delegate: EmptyFooterViewDelegate?
    
    override func updateConstraints() {
        super.updateConstraints()
        
        guard let delegate = delegate else { return }
        let _title = delegate.title
        let _buttonTitle =  delegate.buttonTitle
        
        //if only title
        if _title != nil && delegate.buttonTitle == nil {
            titleLabel.snp.makeConstraints { (make) in
                
            }
            return
        }
        
        //if only button
        if _title == nil && delegate.buttonTitle != nil {
            return
        }
        
        //if both
        if _title != nil && _buttonTitle != nil {
            return
        }
    }
    
    @objc private func didButtonTapped() {
        delegate?.emptyFooterViewDidButtonTapped(self)
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.attributedText = delegate?.title
        addSubview(label)
        return label
    }
    
    private func createTitleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setAttributedTitle(delegate?.buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(didButtonTapped), for: .touchUpInside)
        addSubview(button)
        return button
    }
}
