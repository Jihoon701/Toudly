//
//  SearchTableViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/20.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        setUI()
        super.awakeFromNib()
    }
    
    func setUI() {
        self.selectionStyle = .none
        contentLabel.font = .appRegularFont(14)
        dateLabel.font = .appRegularFont(12)
        dateLabel.textColor = .lightGray
    }
    
    func configureSearchCell(target: TodoList, searchLetter: String) {
        contentLabel.attributedText = changeAllOccurrence(entireString: target.todoContent, searchString: searchLetter)
        contentLabel.sizeToFit()
        dateLabel.text = target.date
        
        if Locale.current.languageCode == "en" {
            self.dateLabel.text = changeToEnglishDateFormat(date: target.date)
        }
    }
    
    func configureCell(target: TodoList) {
        contentLabel.text = target.todoContent
        contentLabel.sizeToFit()
        dateLabel.text = target.date
    }
    
    func changeAllOccurrence(entireString: String, searchString: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: entireString)
        let entireLength = entireString.count
        var range = NSRange(location: 0, length: entireLength)
        var rangeArr = [NSRange]()
        
        while (range.location != NSNotFound) {
            range = (attributedString.string as NSString).range(of: searchString, options: .caseInsensitive, range: range)
            rangeArr.append(range)
            
            if (range.location != NSNotFound) {
                range = NSRange(location: range.location + range.length, length: entireString.count - (range.location + range.length))
            }
        }
        
        rangeArr.forEach { (range) in
            attributedString.addAttributes([.font: UIFont.appExtraBoldFont(14), .foregroundColor: UIColor.burgundy], range: range)
        }
        
        return attributedString
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
