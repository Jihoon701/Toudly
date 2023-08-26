//
//  UILabel.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/25.
//

import Foundation
import UIKit

extension UILabel {
    
    func setupNoticeLabel(labelText: String) {
        self.numberOfLines = 0
        self.font = .appRegularFont(15)
        self.textColor = .lightGray
        let attrString = NSMutableAttributedString(string: labelText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
    
    func setupTitleLabel(text: String) {
        self.font = .appBoldFont(16)
        self.text = text
    }
    
    func setupLabel(text: String) {
        self.font = .appRegularFont(14)
        self.text = text
    }
}
