//
//  OTPCodeViewController.swift
//  Prynote
//
//  Created by Yi Tong on 10/23/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit
import AiTmedSDK

//protocol OPTCodeDelgate: class {
//    func OPTCodeDidInput(_ viewController: OPTCodeViewController, code: String, state: State)
//}
//
//extension OPTCodeDelgate {
//    func OPTCodeDidInput(_ viewController: OPTCodeViewController, code: String, state: State) {}
//}
//
//enum State {
//    case
//    case signup
//}

class OPTCodeViewController: UIViewController {
    weak var container: UIView!
    weak var titleLabel: UILabel!
    weak var detailLabel: UILabel!
    weak var codeInput: TYInput!
    weak var resendButton: TYButton!
    weak var backButton: UIButton!
    weak var errorLabel: UILabel!
//    weak var delegate: OPTCodeDelgate?
    
    private let phoneNumber: String
    private let countDown = 5
    private let action: (String) -> Void
//    private let type: Type
    
    init(phoneNumber: String, action: @escaping (String) -> Void) {
//        self.type = type
        self.action = action
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        setupViews()
        initializeViews()
        initializeObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        resizeCodeInput()
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func resendButtonTapped(button: TYButton) {
        resendButton.startAnimating()
        
        AiTmed.sendOPTCode(args: AiTmedSDK.SendOPTCodeArgs(phoneNumber: phoneNumber)) { [weak self] (result) in
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                weakSelf.resendButton.endAnimating()
                
                switch result {
                case .failure(let error):
                    weakSelf.displayError(error.localizedDescription)
                case .success(_):
                    weakSelf.resendButton.startCountDown(weakSelf.countDown)
                }
            })
        }
    }
    
//    @objc func createUserFinished(notification: Notification) {
//        guard let success = notification.userInfo?[NotificationUserInfoKey.success] as? Bool else { return }
//
//        DispatchQueue.main.async {
//            if success {
//                self.dismiss(animated: true) {
//                    getRootViewController()?.dismiss(animated: false, completion: nil)
//                }
//            } else {
//                var msg = "Unknow Error"
//                if let error = notification.userInfo?[NotificationUserInfoKey.errorMessage] as? String {
//                    msg = error
//                }
//                self.displayError(msg)
//
//                self.codeInput.text = ""
//            }
//        }
//    }
//
//    @objc func loginUserFinished(notification: Notification) {
//        guard let success = notification.userInfo?[NotificationUserInfoKey.success] as? Bool else { return }
//
//        DispatchQueue.main.async {
//            if success {
//                self.dismiss(animated: true) {
//                    getRootViewController()?.dismiss(animated: false, completion: nil)
//                }
//            } else {
//                var msg = "Unknow Error"
//                if let error = notification.userInfo?[NotificationUserInfoKey.errorMessage] as? String {
//                    msg = error
//                }
//                self.displayError(msg)
//
//                self.codeInput.text = ""
//            }
//        }
//    }
}

//private functions
extension OPTCodeViewController {
    private func initializeObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(createUserFinished), name: .createUserFinishedNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(loginUserFinished), name: .loginUserFinishedNotification, object: nil)
    }
    
//    private func sendOPTCode() {
//        resendButton.startAnimating()
//
//        aitmed.sendOPTCode(to: phoneNumber) { [weak self] (result) in
//            guard let weakSelf = self else { return }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
//                weakSelf.resendButton.endAnimating()
//
//                switch result {
//                case .failure(let error):
//                    weakSelf.displayError(error.msg)
//                case .success(_):
//                weakSelf.resendButton.startCountDown(weakSelf.countDown)
//                }
//            })
//        }
//    }
    
    private func displayError(_ msg: String) {
        errorLabel.text = msg
    }
    
    private func clearError() {
        errorLabel.text = ""
    }
    
    private func resizeCodeInput() {
        let containerW = container.ty.width
        let contianerH = container.ty.height
        let resendButtonH = resendButton.ty.height
        let height: CGFloat = 80
        let gap: CGFloat = 40
        codeInput.frame = CGRect(x: 0, y: contianerH - resendButtonH - height - gap, width: containerW, height: height)
        errorLabel.frame = CGRect(x: 0, y: codeInput.frame.maxY + 2, width: containerW, height: 20)
    }
    
    private func initializeViews() {
        view.backgroundColor = .white
        backButton.setImage(UIImage(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Verify your mobile"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.ty.avenirNext(bold: .bold, size: 32)
        titleLabel.textColor = UIColor.ty.drakGray
        
        detailLabel.text = "Enter your OPT code here"
        detailLabel.textAlignment = .center
        detailLabel.font = UIFont.ty.avenirNext(bold: .medium, size: 16)
        detailLabel.textColor = UIColor.ty.lightGray
        
        codeInput.labelText = "Code"
        codeInput.delegate = self
        
        resendButton.setTitle("Resend", for: .normal)
        resendButton.setTitleColor(.white, for: .normal)
        resendButton.backgroundColor = UIColor.ty.lightBlue
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        resendButton.ty.roundedCorner(with: 2)
        resendButton.startCountDown(countDown)
        
        errorLabel.font = UIFont.ty.avenirNext(bold: .regular, size: 12)
        errorLabel.textColor = UIColor.ty.defaultRed
    }
    
    private func setupViews() {
        let container = UIView()
        self.container = container
        view.addSubview(container)
        
        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        container.addSubview(titleLabel)
        
        let detailLabel = UILabel()
        self.detailLabel = detailLabel
        container.addSubview(detailLabel)
        
        let codeInput = TYInput(frame: CGRect.zero, type: .pinCode)
        self.codeInput = codeInput
        container.addSubview(codeInput)
        
        let resendButton = TYButton()
        self.resendButton = resendButton
        container.addSubview(resendButton)
        
        let backButton = UIButton()
        self.backButton = backButton
        view.addSubview(backButton)
        
        let errorLabel = UILabel()
        self.errorLabel = errorLabel
        container.addSubview(errorLabel)
        
        //--------------------------------------------------
        backButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.width.height.equalTo(16)
        }
        
        //width: 2/3 of superview's width but less than 300, height is 1.25 of width
        container.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(2/3.0).priority(.high)
            make.width.lessThanOrEqualTo(300).priority(.required)
            make.height.equalTo(container.snp.width).multipliedBy(1.25)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }

        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }

        resendButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(44)
        }
        
        view.layoutIfNeeded()
    }
}

extension OPTCodeViewController: TYInputDelegate {
    func textFieldValueChanged(_ input: TYInput) {
        clearError()
        guard let text = input.text, text.count == 6 else { return }
        
        dismiss(animated: true) {
            self.action(text)
        }
    }
}
