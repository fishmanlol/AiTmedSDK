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
    
    private static var timer: Timer?
    private static var isOnWindow = false
    private static var tag = 1000
    
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
    
    static func scheduleDisplayOnWindow(delay: TimeInterval, msg: String) {
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (_) in
            DispatchQueue.main.async {
                let view = WaitingView(frame: UIScreen.main.bounds)
                view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
                view.setMsg(msg)
                view.tag = tag
                let keyWindow = UIApplication.shared.keyWindow!
                keyWindow.addSubview(view)
                self.isOnWindow = true
            }
        })
    }
    
    static func dismissOnWindow() {
        timer?.invalidate()
        
        if isOnWindow {
            DispatchQueue.main.async {
                let keyWindow = UIApplication.shared.keyWindow!
                for subview in keyWindow.subviews where subview.tag == tag {
                    subview.removeFromSuperview()
                    self.isOnWindow = false
                }
            }
        }
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
