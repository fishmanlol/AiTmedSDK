//
//  TYLabel.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/3/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class TYLabel: UILabel {
    
    private var ctFrame: CTFrame!
    private var clickableArray: [(Range<String.Index>, (String) -> Void)] = []
    var clickableAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.ty.lightBlue]
    private var clickable = false
    
    private var attributes: [NSAttributedString.Key: Any] = [:]
    
    //public functions
    public func makeClickable(at range: Range<String.Index>, handler: @escaping (String) -> Void) {
        guard let attributedText = attributedText, let text = text, let wholeRange = text.range(of: text) else { return }
        let clamped = range.clamped(to: wholeRange)
        clickableArray.append((clamped, handler))
        
        //attach attributes on clickable string
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let nsrange = NSRange(clamped, in: text)
        mutable.addAttributes(clickableAttributes, range: nsrange)
        self.attributedText = mutable
    }
    
    //overrides
    override var text: String? {
        get {
            return attributedText?.string
        }
        
        set {
            attributedText = NSAttributedString(string: newValue ?? "", attributes: attributes)
            setNeedsDisplay()
        }
    }
    
    override var textColor: UIColor! {
        get {
            guard let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor else { return super.textColor }
            return color
        }
        
        set {
            
            attributes[NSMutableAttributedString.Key.foregroundColor] = newValue
            updateText()
        }
    }
    
    override var font: UIFont! {
        get {
            guard let f = attributes[NSAttributedString.Key.font] as? UIFont else { return super.font }
            return f
        }
        
        set {
            attributes[NSMutableAttributedString.Key.font] = newValue
            updateText()
        }
    }
    
    var kern: CGFloat {
        get {
            guard let k = attributes[NSAttributedString.Key.kern] as? CGFloat else { return 0 }
            return k
        }
        
        set {
            attributes[NSMutableAttributedString.Key.kern] = newValue
            updateText()
        }
    }
    
    init(frame: CGRect, clickable: Bool = false) {
        self.clickable = clickable
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        if !clickable {
            super.draw(rect)
            return
        }
        guard let context = UIGraphicsGetCurrentContext(), let attributedText = attributedText else { return }
        
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)
        
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        for (range, _) in clickableArray {
            let nsrange = NSRange(range, in: attributedText.string)
            mutable.addAttributes(clickableAttributes , range: nsrange)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        switch textAlignment {
        case .center:
            paragraphStyle.alignment = .center
        case .justified:
            paragraphStyle.alignment = .justified
        case .left:
            paragraphStyle.alignment = .left
        case .natural:
            paragraphStyle.alignment = .natural
        case .right:
            paragraphStyle.alignment = .right
        @unknown default:
            paragraphStyle.alignment = .center
        }
        mutable.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text?.count ?? 0))
        
        let cfAttributedString = mutable as CFMutableAttributedString
        let frameSetter = CTFramesetterCreateWithAttributedString(cfAttributedString)
        var fitRange = CFRangeMake(0, 0)
        let suggested = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, mutable.length), nil, CGSize(width: bounds.width, height: .greatestFiniteMagnitude), &fitRange)
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: max(suggested.width, bounds.width), height: max(suggested.height, bounds.height)))
        ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path.cgPath, nil)
        
        CTFrameDraw(ctFrame, context)
    }
    
    private func indexAtPoint(_ point: CGPoint) -> Int? {
        let flipped = CGPoint(x: point.x, y: bounds.height - point.y)
        let lines = CTFrameGetLines(ctFrame) as NSArray
        var origins = Array<CGPoint>(repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &origins)
        for i in 0..<lines.count {
            if (flipped.y > origins[i].y) {
                let line = lines.object(at: i) as! CTLine
                return CTLineGetStringIndexForPosition(line, flipped) as Int
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let text = text else { return }
        let point = touch.location(in: self)
        print(point)
        if let index = self.indexAtPoint(point) {
            let stringIndex = text.index(text.startIndex, offsetBy: index)
            let clickableArrayCount = clickableArray.count
            for i in 0..<clickableArrayCount {
                let clickableRange = clickableArray[clickableArrayCount - i - 1].0
                let clickHandler = clickableArray[clickableArrayCount - i - 1].1
                if clickableRange.contains(stringIndex) {
                    let clickableString = String(text[clickableRange])
                    clickHandler(clickableString)
                    return
                }
            }
        } else {
            print("No index here")
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !clickable {
            return nil
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        kern = 1
    }
    
    private func updateText() {
        clickableArray.removeAll()
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
        if clickable {
            setNeedsDisplay()
        }
    }
}
