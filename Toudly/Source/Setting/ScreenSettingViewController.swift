//
//  ScreenSettingViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/05/31.
//

import UIKit

protocol ScreenSettingDelegate: AnyObject {
    func reloadBookmarkImage()
}

class ScreenSettingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkSettingLabel: UILabel!
    @IBOutlet weak var bookmarkColorCheckImage: UIImageView!
    @IBOutlet var bookmarkColorButtons: [UIButton]!

    let bookmarkColors = ["apricot", "green", "red", "turquoise", "yellow"]
    
    @IBAction func backToSettingVC(_ sender: Any) {
        NotificationCenter.default.post(name: Constant.reloadBookmark, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeToNanumFont(_ sender: Any) {
        FontManager.selectedFontType = .nanumSquareRound
        setUI()
    }
    
    @IBAction func changeToManropeFont(_ sender: Any) {
        FontManager.selectedFontType = .manrope
        setUI()
    }
    
    override func viewDidLoad() {
        setUI()
        super.viewDidLoad()
    }
    
    func setUI() {
        titleLabel.setupTitleLabel(text: "Display".localized())
        bookmarkSettingLabel.setupLabel(text: "Set Bookmark Color".localized())
        initColorButtons()
        bookmarkColorCheckImage.image = UIImage(named: "bookmark_gray")
        bookmarkColorCheckImage.image = UIImage.coloredBookmarkImage(bookmarkColorCheckImage.image!)()
    }
    
    func initColorButtons() {
        for colorButton in bookmarkColorButtons {
            colorButton.addTarget(self, action: #selector(bookmarkColorSelected(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func bookmarkColorSelected (sender: UIButton) {
        Constant.bookmarkColor = sender.titleLabel?.text!
        self.bookmarkColorCheckImage.image = UIImage.coloredBookmarkImage(self.bookmarkColorCheckImage.image!)()
    }
}
