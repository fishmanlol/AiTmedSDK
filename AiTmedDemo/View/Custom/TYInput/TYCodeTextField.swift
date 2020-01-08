//
//  TYCodeTextField.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class TYCodeTextField: UITextField {
    
    private var kern: CGFloat = 0 {
        didSet {
            defaultTextAttributes[NSAttributedString.Key.kern] = kern
        }
    }
    
    var digits: Int = 6 {
        didSet {
            if digits < 1 { return }
        }
    }
    
    var fontSize: CGFloat = UIFont.ty.middleFontSize {
        didSet {
            defaultTextAttributes[NSAttributedString.Key.font] = UIFont.ty.menlo(bold: fontBold, size: fontSize)
        }
    }
    
    var fontBold: UIFont.Weight = .regular {
        didSet {
            defaultTextAttributes[NSAttributedString.Key.font] = UIFont.ty.menlo(bold: fontBold, size: fontSize)
        }
    }
    
    private weak var _delegate: UITextFieldDelegate?
    override weak var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }

        set {
            _delegate = newValue
        }
    }
    
    var underLineHeight: CGFloat = 2
    var underLineWidth: CGFloat = 36
    var underLineColor: UIColor = UIColor.lightGray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.font = UIFont.ty.menlo(bold: fontBold, size: fontSize)
        self.textColor = UIColor.black
        self.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        self.keyboardType = .phonePad
        super.delegate = self
        if #available(iOS 12.0, *) {
            self.textContentType = .oneTimeCode
        }
    }
    
    private var defaultCharacterWidth: CGFloat {
        let attributedText = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.font: UIFont.ty.menlo(bold: fontBold, size: fontSize)])
        return attributedText.size().width
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var gapWidth = (rect.width - CGFloat(digits) * underLineWidth) / CGFloat(digits - 1)
        gapWidth = gapWidth < 0 ? 0 : gapWidth
        kern = underLineWidth + gapWidth - defaultCharacterWidth
        print("kern: \(kern)")
        
        let path = UIBezierPath()
        for i in 0..<digits {
            let startPoint = CGPoint(x: rect.minX + CGFloat(i) * (gapWidth + underLineWidth), y: rect.maxY)
            let endPoint = CGPoint(x: startPoint.x + underLineWidth, y: rect.maxY)
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            underLineColor.setStroke()
            path.lineWidth = underLineHeight
            path.stroke()
        }
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let dx = (underLineWidth - defaultCharacterWidth) * 0.5
        return CGRect(x: bounds.origin.x + dx, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let dx = (underLineWidth - defaultCharacterWidth) * 0.5
        return CGRect(x: bounds.origin.x + dx, y: bounds.origin.y, width: bounds.width * 2, height: bounds.height)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let _delegate = _delegate, _delegate.responds(to: aSelector) {
            return _delegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if let _delegate = _delegate, _delegate.responds(to: aSelector) {
            return true
        } else {
            return super.responds(to: aSelector)
        }
    }
    
    @objc private func valueChanged(sender: UITextField) {
        
        let count = sender.text?.count ?? 0
        
        if count > digits - 1 {
            let _ = resignFirstResponder()
        }
        
        if count == digits {
            self.text = sender.text
        }
    }
}

extension TYCodeTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isBackSpacePressed(string: string) {
            return true
        }
        
        if hasMaxDigits(textField: textField) {
            return false
        }
        
        // The string is valid, now let the real delegate decide
        if let _delegate = _delegate, _delegate.responds(to: #selector(textField(_:shouldChangeCharactersIn:replacementString:))) {
            return _delegate.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return true
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let nowCount = textField.text?.count ?? 0
        if nowCount == digits {
            textField.text?.removeLast()
        }

        if let _delegate = _delegate, _delegate.responds(to: #selector(textFieldShouldBeginEditing(_:))) {
            return _delegate.textFieldShouldBeginEditing!(textField)
        } else {
            return true
        }
    }
    
    private func isBackSpacePressed(string: String) -> Bool {
        if let char = string.cString(using: .utf8) { //allow backsapce
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        return false
    }
    
    private func hasMaxDigits(textField: UITextField) -> Bool {
        let nowDigits = textField.text?.count ?? 0
        return nowDigits < digits ? false : true
    }
}
