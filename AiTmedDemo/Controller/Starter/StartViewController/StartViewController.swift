//
//  ViewController.swift
//  Prynote1
//
//  Created by Yi Tong on 11/27/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit
import AiTmedSDK1

enum Mode: Equatable {
    case initial
    case second
    case login
    case signin(Int32)

    static func ==(lhs: Mode, rhs: Mode) -> Bool {
        switch (lhs, rhs) {
        case (Mode.initial, Mode.initial):
            return true
        case (Mode.login, Mode.login):
            return true
        case (Mode.second, Mode.second):
            return true
        case (signin(_), signin(_)):
            return true
        default:
            return false
        }
    }
}

class StartViewController: UIViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var LoginOrSignUpLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateBar: UIView!
    
    weak var container: UIView!
    weak var phoneNumberInput: TYInput!
    weak var passwordInput: TYInput!
    weak var nameInput: TYInput!
    weak var continueButton: UIButton!
    
    private var mode: Mode = .initial {
        didSet {
            lastModes.append(oldValue)
            DispatchQueue.main.async {
                self.changeLayout(from: oldValue, to: self.mode)
            }
        }
    }
    
    private var lastModes: [Mode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initializeViews()
    }
    
    @objc func continueButtonTapped(button: TYButton) {
        if mode == .initial {
            mode = .second
        } else if mode == .second {
            guard let number = phoneNumberInput.phoneNumber else {
                displayAlert(title: nil, msg: "Invalid phoneNumber", hasCancel: false, action: {})
                return
            }
            let areaCode = String(phoneNumberInput.country.code)
            let numberString = number.numberString
            let phoneNumber = "+" + areaCode + " " + numberString
            
            if AiTmed.hasCredential(for: phoneNumber) {//has credential
                mode = .login
            } else { //no credential
                button.startAnimating()
                AiTmed.sendOPTCode(args: AiTmedSDK1.SendOPTCodeArgs(phoneNumber: phoneNumber)) { (result) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                        button.endAnimating()
                        
                        switch result {
                        case .failure(let error):
                            self.displayAlert(title: "Error", msg: error.localizedDescription, hasCancel: false, action: {})
                        case .success(_):
                            let OPTCodeController = OPTCodeViewController(phoneNumber: phoneNumber, action: { (code) in
                                AiTmed.retrieveCredential(args: AiTmedSDK1.RetrieveCredentialArgs(phoneNumber: phoneNumber, code: code), completion: { (result) in
                                    switch result {
                                    case .failure(.apiResultFailed(.userNotExist)):
                                        self.mode = .signin(Int32(code) ?? 0)
                                    case .failure(let error):
                                        self.displayAlert(title: "Error", msg: error.localizedDescription, hasCancel: false, action: {})
                                    case .success(_):
                                        self.mode = .login
                                    }
                                })
                            })
                            self.present(OPTCodeController, animated: true, completion: nil)
                        }
                    })
                }
            }
        } else if mode == .login {
            guard let number = phoneNumberInput.phoneNumber else {
                displayAlert(title: nil, msg: "Invalid phoneNumber", hasCancel: false, action: {})
                return
            }
            
            let areaCode = String(phoneNumberInput.country.code)
            let numberString = number.numberString
            let phoneNumber = "+" + areaCode + " " + numberString
            
            let password = passwordInput.text ?? ""
            
            AiTmed.login(args: AiTmedSDK1.LoginArgs(phoneNumber: phoneNumber, password: password)) { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.displayAlert(title: "Error", msg: error.localizedDescription, hasCancel: false, action: {})
                    }
                case .success(_):
                    Storage.default.retrieveNotebooks(completion: { (result) in
                        switch result {
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.displayAlert(title: error.message, msg: nil)
                            }
                        case .success(_):
                            Storage.default.retrieveNotebooks(completion: { (result) in
                                switch result {
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        self.displayAlert(title: error.message, msg: nil)
                                    }
                                case .success(_):
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(MasterController(), animated: false)
                                    }
                                }
                            })
                        }
                    })
                }
            }
        } else if case let Mode.signin(code) = mode {
            guard let number = phoneNumberInput.phoneNumber else {
                displayAlert(title: nil, msg: "Invalid phoneNumber", hasCancel: false, action: {})
                return
            }
            
            let areaCode = String(phoneNumberInput.country.code)
            let numberString = number.numberString
            let phoneNumber = "+" + areaCode + " " + numberString
            let password = passwordInput.text ?? ""
            
            AiTmed.createUser(args: AiTmedSDK1.CreateUserArgs(phoneNumber: phoneNumber, password: password, code: code)) { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.displayAlert(title: "Error", msg: error.localizedDescription, hasCancel: false, action: {})
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(MasterController(), animated: false)
                    }
                }
            }
        }
    }
    
    @objc func backButtonTapped(button: UIButton) {
        if let lastMode = lastModes.last {
            mode = lastMode
        }
    }
}

extension StartViewController {
    private func changeLayout(from oldMode: Mode, to newMode: Mode) {
        guard oldMode != newMode else { return }
        
        switch newMode {
        case .initial:
            container.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.top.equalTo(LoginOrSignUpLabel.snp.bottom).offset(28)
            }
            
            view.endEditing(true)
            
            UIView.animate(withDuration: 0.35, animations: {
                self.backButton.alpha = 0
                self.baseView.alpha = 1
                self.view.layoutIfNeeded()
            })
        case .second:
            container.snp.remakeConstraints { (make) in
                make.top.equalTo(stateBar.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            
            passwordInput.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(60)
            }
            
            UIView.animate(withDuration: 0.35, animations: {
                self.backButton.alpha = 1
                self.baseView.alpha = 0
                self.stateLabel.alpha = 0
                self.passwordInput.alpha = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                let _ = self.phoneNumberInput.becomeFirstResponder()
            }
        case .login:
            passwordInput.snp.remakeConstraints { (make) in
                make.top.equalTo(phoneNumberInput.snp.bottom).offset(12)
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
            
            continueButton.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(44)
                make.top.equalTo(passwordInput.snp.bottom).offset(24)
            }
            
            stateLabel.text = "Log in"
            
            UIView.animate(withDuration: 0.35, animations: {
                self.view.layoutIfNeeded()
                self.passwordInput.alpha = 1
                self.stateLabel.alpha = 1
            }) { (_) in
                let _ = self.passwordInput.becomeFirstResponder()
            }
            
        case .signin:
            passwordInput.snp.remakeConstraints { (make) in
                make.top.equalTo(phoneNumberInput.snp.bottom).offset(12)
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
            
            continueButton.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(44)
                make.top.equalTo(passwordInput.snp.bottom).offset(24)
            }
            
            stateLabel.text = "Sign up"
            
            UIView.animate(withDuration: 0.35, animations: {
                self.view.layoutIfNeeded()
                self.passwordInput.alpha = 1
                self.stateLabel.alpha = 1
            }) { (_) in
                let _ = self.passwordInput.becomeFirstResponder()
            }
        }
    }
    
    private func initializeViews() {
        backButton.alpha = 0
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        stateLabel.alpha = 0
        
        phoneNumberInput.labelText = "Phone Number"
        phoneNumberInput.delegate = self
        
        passwordInput.labelText = "Password"
        passwordInput.alpha = 0

        nameInput.labelText = "Nick Name"
        nameInput.alpha = 0
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.ty.roundedCorner(with: 4)
        continueButton.backgroundColor = UIColor.ty.lightBlue
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        //container
        let container = UIView()
        self.container = container
        view.addSubview(container)
        
        //phone number input
        let phoneNumberInput = TYInput(frame: .zero, type: .phoneNumber)
        self.phoneNumberInput = phoneNumberInput
        container.addSubview(phoneNumberInput)
        
        //password input
        let passwordInput = TYInput(frame: .zero, type: .password(hide: true))
        self.passwordInput = passwordInput
        container.addSubview(passwordInput)

        //name input
        let nameInput = TYInput(frame: .zero, type: .normal)
        self.nameInput = nameInput
        container.addSubview(nameInput)
        
        //continue button
        let continueButton = TYButton(type: .system)
        self.continueButton = continueButton
        container.addSubview(continueButton)
        
        container.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(LoginOrSignUpLabel.snp.bottom).offset(28)
        }
        
        phoneNumberInput.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        passwordInput.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }

        nameInput.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        continueButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(phoneNumberInput.snp.bottom).offset(24)
        }
    }
}

extension StartViewController: TYInputDelegate {
    func textFieldShouldBeginEditing(_ input: TYInput) -> Bool {
        switch mode {
        case .initial:
            mode = .second
        case .login, .signin:
            mode = .second
        case .second:
            break
        }
        
        return true
    }
}
