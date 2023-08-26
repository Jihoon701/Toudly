//
//  UIFont.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/17.
//

import Foundation
import UIKit

extension UIFont {
    
    public enum NanumSquareRound: String {
        case light = "L"
        case regular = "R"
        case bold = "B"
        case extraBold = "EB"
    }
    
    static func NanumSRFont(_ type: NanumSquareRound, size: CGFloat) -> UIFont {
        return UIFont(name: "NanumSquareRoundOTF\(type.rawValue)", size: size)!
    }
    
    public enum Manrope: String {
        case extraLight = "ExtraLight"
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
        case extraBold = "ExtraBold"
    }
    
    static func ManropeFont(_ type: Manrope, size: CGFloat) -> UIFont {
        return UIFont(name: "Manrope-\(type.rawValue)", size: size)!
    }
}

class FontManager {
    enum SelectedFontType: String {
        case nanumSquareRound = "NanumSquareRound"
        case manrope = "Manrope"
    }
    
    static var selectedFontType: SelectedFontType {
        get {
            if let fontTypeRawValue = UserDefaults.standard.string(forKey: "SelectedFontType"),
               let fontType = SelectedFontType(rawValue: fontTypeRawValue) {
                return fontType
            }
            return .nanumSquareRound
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "SelectedFontType")
        }
    }
    
    static var selectedRegularFont: UIFont {
        get {
            switch selectedFontType {
            case .nanumSquareRound:
                return UIFont.NanumSRFont(.regular, size: UIFont.systemFontSize)
            case .manrope:
                return UIFont.ManropeFont(.regular, size: UIFont.systemFontSize)
            }
        }
    }
    
    static var selectedBoldFont: UIFont {
        get {
            switch selectedFontType {
            case .nanumSquareRound:
                return UIFont.NanumSRFont(.bold, size: UIFont.systemFontSize)
            case .manrope:
                return UIFont.ManropeFont(.medium, size: UIFont.systemFontSize)
            }
        }
    }
    
    static var selectedExtraBoldFont: UIFont {
        get {
            switch selectedFontType {
            case .nanumSquareRound:
                return UIFont.NanumSRFont(.extraBold, size: UIFont.systemFontSize)
            case .manrope:
                return UIFont.ManropeFont(.semiBold, size: UIFont.systemFontSize)
            }
        }
    }
}

extension UIFont {
    static func appRegularFont(_ size: CGFloat) -> UIFont {
        return FontManager.selectedRegularFont.withSize(size)
    }
    
    static func appBoldFont(_ size: CGFloat) -> UIFont {
        return FontManager.selectedBoldFont.withSize(size)
    }
    
    static func appExtraBoldFont(_ size: CGFloat) -> UIFont {
        return FontManager.selectedExtraBoldFont.withSize(size)
    }
}

