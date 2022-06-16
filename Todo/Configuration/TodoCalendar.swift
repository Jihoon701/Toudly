//
//  TodoCalendar.swift
//  Todo
//
//  Created by 김지훈 on 2022/05/06.
//

import Foundation
import UIKit

class TodoCalendar {
    let cal = Calendar.current
    let currentDate = Date()
    var firstDayOfCurrentMonth = Date()
    var calendarComponents = DateComponents()
    var calendarMonth = 0
    var calendarYear = 0
    var calendarDay = 0
    var selectedTodoDate = ""
    var weekTypeCategory = ""
    var weekTypePrevDayCount = 0
    var weekTypeNextDayCount = 0
    
    var daysInWeekType: [String] = []
    var daysInMonthType: [String] = []
    
    func initCalendar() {
        calendarComponents.year = currentDate.year
        calendarComponents.month = currentDate.month
        calendarComponents.day = 1
        
        calendarYear = currentDate.year
        calendarMonth = currentDate.month
        calendarDay = currentDate.day
        
        selectedTodoDate = "\(currentDate.year)/\(currentDate.month)/\(currentDate.day)"
        calculateCalendarDate()
        print(checkCurrentDayMonth())
    }
    
    func calculateCalendarDate() {
        let firstDayOfCurrentMonth = cal.date(from: calendarComponents)
        calendarYear = cal.component(.year, from: firstDayOfCurrentMonth!)
        calendarMonth = cal.component(.month, from: firstDayOfCurrentMonth!)
        calendarDay = cal.component(.day, from: firstDayOfCurrentMonth!)
        
        let weekdayOfFirstDayInCurrentMonth = cal.component(.weekday, from: firstDayOfCurrentMonth!)
        let currentWeekday = cal.component(.weekday, from: Date())
        
        let daysCountInPrevMonth = cal.range(of: .day, in: .month, for: numberOfDaysInMonth(month: .prevMonth))!.count
        let daysCountInCurrentMonth = cal.range(of: .day, in: .month, for: numberOfDaysInMonth(month: .currentMonth))!.count
        let daysCountInNextMonth = cal.range(of: .day, in: .month, for: numberOfDaysInMonth(month: .nextMonth))!.count
        
        daysInWeekType = calculateDaysInWeekType(weekday: currentWeekday, daysCountInPrevMonth: daysCountInPrevMonth, daysCountInCurrentMonth: daysCountInCurrentMonth, daysCountInNextMonth: daysCountInNextMonth).map { String($0) }
        daysInMonthType = calculateDaysInMonthType(emptiedDaysInMonth: 2 - weekdayOfFirstDayInCurrentMonth, daysCountInMonth: daysCountInCurrentMonth)
        
    }
    
    enum Month {
        case prevMonth
        case currentMonth
        case nextMonth
    }
    
    public func CalendarTitle() -> String {
        print("\(calendarYear)년 \(calendarMonth)월")
        return "\(calendarYear)년 \(calendarMonth)월"
    }
    
    
    public func checkCurrentDayMonth() -> Bool {
        if calendarComponents.year! == currentDate.year {
            if calendarComponents.month! == currentDate.month {
                return true
            }
        }
        return false
    }
    
    public func moveCalendarMonth(value: Int, calendarTitleLabel: UILabel) {
        calendarComponents.month = calendarComponents.month! + value
        calculateCalendarDate()
        calendarTitleLabel.setupTitleLabel(text: CalendarTitle())
    }
    
    private func numberOfDaysInMonth(month: Month) -> Date {
        switch month {
        case .prevMonth:
            return cal.date(byAdding: .month, value: -1, to: cal.date(from: calendarComponents)!)!
        case .currentMonth:
            return cal.date(from: calendarComponents)!
        case .nextMonth:
            return cal.date(byAdding: .month, value: 1, to: cal.date(from: calendarComponents)!)!
        }
    }
    
    private func calculateDaysInMonthType(emptiedDaysInMonth: Int, daysCountInMonth: Int) -> Array<String> {
        var daysInMonthType: [String] = []
        for day in emptiedDaysInMonth...daysCountInMonth {
            if day < 1 {
                daysInMonthType.append("")
            } else {
                daysInMonthType.append(String(day))
            }
        }
        return daysInMonthType
    }
    
    public func checkWeekTypeCategory(weekTypeCategory: String) -> String {
        switch weekTypeCategory {
        case "prev":
            return "\(calendarYear)/\(calendarMonth-1)"
        case "next":
            return "\(calendarYear)/\(calendarMonth+1)"
        default:
            return "\(calendarYear)/\(calendarMonth)"
        }
    }
    
    private func createDays(startOfWeek: Int, endOfWeek: Int, initDaysInWeekType: inout Array<Int>, daysCountInFrontMonth: Int) -> Array<Int> {
        var daysCount = 0
        
        for i in startOfWeek...daysCountInFrontMonth {
            initDaysInWeekType[i-startOfWeek] = i
            daysCount += 1
        }
        
        weekTypePrevDayCount = daysCount
        weekTypeNextDayCount = 7 - daysCount
        
        for j in 1...endOfWeek {
            initDaysInWeekType[daysCount] = j
            daysCount += 1
        }
        return initDaysInWeekType
    }
    
    private func calculateDaysInWeekType(weekday: Int, daysCountInPrevMonth: Int, daysCountInCurrentMonth: Int, daysCountInNextMonth: Int) -> Array<Int> {
        var initDaysInWeekType: Array<Int> = Array(repeating: 0, count: 7)
        let todayDate = Date().day
        
        var startOfWeek = todayDate - weekday + 1
        var endOfWeek = todayDate - weekday + 7
        weekTypeCategory = "ordinary"
        // 달력 앞부분이 prevMonth와 합쳐질 때
        if startOfWeek < 1 {
            startOfWeek = daysCountInPrevMonth + startOfWeek
            weekTypeCategory = "prev"
            return createDays(startOfWeek: startOfWeek, endOfWeek: endOfWeek, initDaysInWeekType: &initDaysInWeekType, daysCountInFrontMonth: daysCountInPrevMonth)
        }
        
        // 달력 뒷부분이 nextMonth와 합쳐질 때
        if endOfWeek > daysCountInCurrentMonth {
            endOfWeek = endOfWeek - daysCountInCurrentMonth
            weekTypeCategory = "next"
            return createDays(startOfWeek: startOfWeek, endOfWeek: endOfWeek, initDaysInWeekType: &initDaysInWeekType, daysCountInFrontMonth: daysCountInCurrentMonth)
        }
        
        // prevMonth와 nextMonth와 겹치지 않을 때
        for i in startOfWeek...endOfWeek {
            initDaysInWeekType[i-startOfWeek] = i
        }
        return initDaysInWeekType
    }
}
