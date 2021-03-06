//
//  NamedTextField.swift
//  Formulary
//
//  Created by Fabian Canas on 1/17/15.
//  Copyright (c) 2015 Fabian Canas. All rights reserved.
//

import UIKit

/**
 * A subclass of `UITextField` whose placeholder text animated to a label.
 *
 * `NamedTextField` can take a Validation which will take the field's text value
 * as input, and show failure reasons on the field's label.
 */
class NamedTextField: UITextField {
    
    private let nameLabel = UILabel()
    
    var nameFont :UIFont = UIFont.systemFontOfSize(12) {
        didSet {
            nameLabel.font = nameFont
            validationLabel.font = nameFont
        }
    }
    
    var topMargin :CGFloat = 4
    var marginForContent :CGFloat {
        get {
            return (text ?? "").isEmpty ? 0 : 4
        }
    }
    
    override var placeholder :String? {
        didSet {
            nameLabel.text = placeholder
            nameLabel.sizeToFit()
        }
    }
    
    // MARK: Validation
    
    internal var hasEverResignedFirstResponder = false
    
    override func resignFirstResponder() -> Bool {
        hasEverResignedFirstResponder = true
        return super.resignFirstResponder()
    }
    
    internal let validationLabel = UILabel()
    
    var validationColor: UIColor = UIColor.redColor() {
        didSet {
            validationLabel.textColor = validationColor
        }
    }
    
    var validation: (String?) -> (Bool, String) = PermissiveValidation
    
    private func validate() {
        var accessibilityString = "\(placeholder ?? "")"
        let (valid, errorString) = validation(text)
        validationLabel.text = errorString
        validationLabel.sizeToFit()
        if (text ?? "").isEmpty {
            hideLabel(isFirstResponder(), label: nameLabel)
            if hasEverResignedFirstResponder && !valid {
                showLabel(true, label: validationLabel)
                accessibilityString += " \(errorString)"
            } else {
                hideLabel(isFirstResponder(), label: validationLabel)
            }
        } else {
            if let text = text {
                accessibilityString += ", \(text)"
            }
            if hasEverResignedFirstResponder && !valid {
                showLabel(true, label: validationLabel)
                accessibilityString += ", \(errorString)"
                hideLabel(true, label: nameLabel)
            } else {
                showLabel(isFirstResponder(), label: nameLabel)
                hideLabel(isFirstResponder(), label: validationLabel)
            }
        }
        accessibilityLabel = accessibilityString
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        validate()
    }
    
    private func showLabel(animated: Bool, label: UILabel) {
        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
            var f = label.frame
            f.origin.y = 3
            label.frame = f
            label.alpha = 1.0
        })
    }
    
    private func hideLabel(animated: Bool, label: UILabel) {
        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
            var f = label.frame
            f.origin.y = self.nameLabel.font.lineHeight
            label.frame = f
            label.alpha = 0.0
        })
    }
    
    override func textRectForBounds(bounds:CGRect) -> CGRect {
        var r = super.textRectForBounds(bounds)
        let top = ceil(nameLabel.font.lineHeight)
        r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top + topMargin + marginForContent, 0.0, -marginForContent, 0.0))
        return CGRectIntegral(r)
    }
    
    override func editingRectForBounds(bounds:CGRect) -> CGRect {
        var r = super.editingRectForBounds(bounds)
        let top = ceil(nameLabel.font.lineHeight)
        r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top + topMargin + marginForContent, 0.0, -marginForContent, 0.0))
        return CGRectIntegral(r)
    }
    
    // MARK: Appearance
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        nameLabel.textColor = tintColor
    }
    
    // MARK: Initialize
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        nameLabel.alpha = 0
        nameLabel.textColor = tintColor
        nameLabel.font = nameFont
        
        validationLabel.alpha = 0
        validationLabel.textColor = validationColor
        validationLabel.font = nameFont
        
        addSubview(nameLabel)
        addSubview(validationLabel)
        
        self.clipsToBounds = false
    }
    
}
