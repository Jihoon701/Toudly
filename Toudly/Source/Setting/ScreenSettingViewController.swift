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
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var holidayDescriptionLabel: UILabel!
    
    let bookmarkColors = ["apricot", "green", "red", "turquoise", "yellow"]
    
    @IBAction func backToSettingVC(_ sender: Any) {
        NotificationCenter.default.post(name: Constant.reloadBookmark, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        setUI()
        super.viewDidLoad()
    }
    
    func setUI() {
        titleLabel.setupTitleLabel(text: "Screen")
        bookmarkSettingLabel.setupLabel(text: "Set Bookmark Color")
        // 공휴일 날짜 표시
        holidayLabel.setupLabel(text: "Show Holiday information")
        // 오늘 날짜를 기준으로 1년 전부터 1년 후까지의 공휴일 정보를 제공합니다.
        holidayDescriptionLabel.setupTextLabel(text: "Provides holiday information from a year\nago to a year later, based on today's date")
        holidayDescriptionLabel.numberOfLines = 0
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
