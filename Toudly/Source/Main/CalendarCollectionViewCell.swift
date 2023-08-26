//
//  CalendarCollectionViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/01/12.
//

import UIKit
import RealmSwift

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var UnderLineView: UIView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var CircleImageView: UIImageView!
    
    let todoCalendar = TodoCalendar()
    let holidayCalendar = HolidayCalendar()
    let realm = try! Realm()
    var isHoliday = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                DateLabel.font = .appExtraBoldFont(15)
                DateLabel.textColor = UIColor.mainDarkGreen
//                DateLabel.textColor = UIColor.burnishedSlate
            }
            else {
                DateLabel.textColor = isHoliday ? UIColor.burgundy : UIColor.black
                DateLabel.font = .appRegularFont(13)
            }
        }
    }
    
    func initWeekdayCell(text: String) {
        isUserInteractionEnabled = false
        UnderLineView.isHidden = true
        CircleImageView.isHidden = true
        DateLabel.textColor = UIColor.black
        DateLabel.setupLabel(text: text)
    }
    
    // haveTodayDate: 해당 달에 오늘 날짜가 포함되어 있는지 확인하는 변수
    func initDayCell(currentDay: String, haveTodayDate: Bool, date: String, haveHolidayDate: Bool) {
        DateLabel.text = currentDay
        drawCircleOnTodayDate(haveTodayDate: haveTodayDate, checkingDate: currentDay)
        checkListExistingDate(date: "\(date)/\(currentDay)")
    }
    
    func checkListExistingDate(date: String) {
        if realm.objects(TodoList.self).filter("date == %@", date).count > 0 {
            UnderLineView.layer.cornerRadius = 1
            UnderLineView.isHidden = false
        }
        else {
            UnderLineView.isHidden = true
        }
        isUserInteractionEnabled = true
    }
    
    func drawCircleOnTodayDate(haveTodayDate: Bool, checkingDate: String) {
        if haveTodayDate && checkingDate == String(Date().day) {
            CircleImageView.isHidden = false
            CircleImageView.tintColor = UIColor.black
        }
        else {
            CircleImageView.isHidden = true
        }
    }
}
