//
//  WaitingView.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit

class WaitingView: UIView {
    weak var msgLabel: UILabel!
    weak var activityIndicator: UIActivityIndicatorView!
    weak var middle: UIView!
    
    convenience init(msg: String) {
        self.init(frame: CGRect.zero)
        
        setMsg(msg)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setMsg(_ msg: String) {
        msgLabel.text = msg
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    private func setUp() {
        let msgLabel = UILabel()
        msgLabel.textAlignment = .center
        self.msgLabel = msgLabel
        addSubview(msgLabel)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.activityIndicator = activityIndicator
        addSubview(activityIndicator)
        
        let middle = UIView()
        self.middle = middle
        addSubview(middle)
        
        middle.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.right.centerY.equalToSuperview()
        }
        
        msgLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.top.equalTo(middle.snp.bottom)
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(middle.snp.top)
        }
    }
}
