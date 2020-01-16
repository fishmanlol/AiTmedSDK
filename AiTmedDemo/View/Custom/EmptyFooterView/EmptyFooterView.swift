//
//  EmptyFooterView.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/13/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

@objc protocol EmptyFooterViewDatasource: AnyObject {
    @objc optional func buttonTitle(forEmptyFooter footer: EmptyFooterView!) -> NSAttributedString?
    @objc optional func title(forEmptyFooter footer: EmptyFooterView!) -> NSAttributedString?
    @objc optional func emptyFooterViewDidButtonTapped(_ v: EmptyFooterView)
}

class EmptyFooterView: UIView {
    lazy var titleLabel: UILabel = createTitleLabel()
    lazy var titleButton: UIButton = createTitleButton()
    
    weak var datasource: EmptyFooterViewDatasource?
    
    init(datasource: EmptyFooterViewDatasource) {
        self.datasource = datasource
        super.init(frame: .zero)
        setNeedsUpdateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        guard let datasource = datasource else { return }
        let _title = datasource.title?(forEmptyFooter: self)
        let _buttonTitle =  datasource.buttonTitle?(forEmptyFooter: self)
        
        //if only title
        if _title != nil && _buttonTitle == nil {
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-60)
            }
            return
        }
        
        //if only button
        if _title == nil && _buttonTitle != nil {
            titleButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-60)
            }
            return
        }
        
        //if both
        if _title != nil && _buttonTitle != nil {
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().inset(16)
                make.centerY.equalToSuperview().offset(-60)
            }
            
            titleButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
            }
            return
        }
    }
    
    @objc private func didButtonTapped() {
        datasource?.emptyFooterViewDidButtonTapped?(self)
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = datasource?.title?(forEmptyFooter: self)
        addSubview(label)
        return label
    }
    
    private func createTitleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setAttributedTitle(datasource?.buttonTitle?(forEmptyFooter: self), for: .normal)
        button.addTarget(datasource, action: #selector(EmptyFooterViewDatasource.emptyFooterViewDidButtonTapped(_:)), for: .touchUpInside)
        addSubview(button)
        return button
    }
}

private var footerDatasourceKey: Void = ()

extension UITableView {
    weak var emptyFooterViewDatasource: EmptyFooterViewDatasource? {
        get {
            return objc_getAssociatedObject(self, &footerDatasourceKey) as? EmptyFooterViewDatasource
        }
        
        set {
            objc_setAssociatedObject(self, &footerDatasourceKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
        }
    }
    
    func showEmptyFooter() {
        tableFooterView = EmptyFooterView(frame: frame)
    }
    
    func hideEmptyFooter() {
        tableFooterView = UIView()
    }
}
