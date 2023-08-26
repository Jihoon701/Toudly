//
//  DetailTableViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/25.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var alarmImage: UIImageView!
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var boxImage: UIImageView!
    @IBOutlet weak var alarmSetTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI() {
        contentLabel.font = .appRegularFont(14)
        contentLabel.textColor = .black
        dateLabel.font = .appRegularFont(12)
        dateLabel.textColor = .lightGray
        alarmSetTimeLabel.font = .appRegularFont(12)
        alarmSetTimeLabel.textColor = .lightGray
        alarmSetTimeLabel.isHidden = true
    }
    
    func configureDetailCell(target: TodoList) {
        self.contentLabel.text = target.todoContent
        contentLabel.numberOfLines = 0
        self.contentLabel.sizeToFit()
        self.dateLabel.text = target.date
        
        if Locale.current.languageCode == "en" {
            self.dateLabel.text = changeToEnglishDateFormat(date: target.date)
        }
        
        self.selectionStyle = .none
        
        if target.alarm {
            alarmImage.image = UIImage(named: "alarm")
            alarmSetTimeLabel.isHidden = false
            alarmSetTimeLabel.text = target.alarmTime
        }
        else {
            alarmImage.image = UIImage(named: "alarmdisabled")
            alarmSetTimeLabel.isHidden = true
        }
        
        boxImage.image = target.checkbox ? UIImage(named: "checkBox"): UIImage(named: "emptyBox")
        
        bookmarkImage.image = target.bookmark ? UIImage.coloredBookmarkImage(bookmarkImage.image!)(): UIImage(named: "bookmark_gray")
    }
    
    func changeToEnglishDateFormat(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "d/M/yyyy"
        let resultString = dateFormatter.string(from: date!)
        print(resultString)
        return resultString
    }
}
