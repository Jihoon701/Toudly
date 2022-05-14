//
//  EditTodoListViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/01/17.
//

import UIKit
import RealmSwift
import UserNotifications

protocol EditTodoDelegate: AnyObject {
    func reorderDeletedList()
    func alertAlarmComplete()
}

class EditTodoListViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var todoListContentTextField: UITextField!
    @IBOutlet weak var bookmarkSwitch: UISwitch!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var alarmPickerView: UIPickerView!
    @IBOutlet weak var alarmTimeSetLabel: UILabel!

    let pickerViewRows = 10000
    let alarmHour: [Int] = Array(0...24)
    let alarmMinute: [Int] = Array(0...59)
    var pickerViewHourMiddle = 0
    var pickerViewMinuteMiddle = 0
    var timeSetHour = 0
    var timeSetMinute = 0
    
    private let realm = try! Realm()
    let userNotiCenter = UNUserNotificationCenter.current()
    weak var editTodoDelegate: EditTodoDelegate?
    var currentTimeComponent = Calendar.current.dateComponents([.hour, .minute], from: Date())
    var currentComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    var todoContent = ""
    var todoDate = ""
    var todoId = 0
    var todoBookmark = false
    var todoAlarm = false
    var todoAlarmTime = ""
    
    override func viewDidLoad() {
        bookmarkSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        alarmSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        todoListContentTextField.text = todoContent
        todoListContentTextField.font = .NanumSR(.regular, size: 14)
        backButton.setupButtonTitleLabel(text: "뒤로가기")
        saveButton.setupButtonTitleLabel(text: "저장하기")
        deleteButton.setupButtonTitleLabel(text: "삭제")
        bookmarkLabel.setupLabel(text: "북마크")
        alarmLabel.setupLabel(text: "알림")
        alarmTimeSetLabel.font = .NanumSR(.bold, size: 12)
        alarmTimeSetLabel.textColor = .darkGray
        
        timeSetHour = Calendar.current.component(.hour, from: Date())
        timeSetMinute = Calendar.current.component(.minute, from: Date())
        alarmTimeSetLabel.text = "\(timeSetHour):\(timeSetMinute)"
        
        alarmPickerView.delegate = self
        alarmPickerView.dataSource = self
        todoListContentTextField.delegate = self
        alarmPickerView.isHidden = true
        alarmTimeSetLabel.isHidden = true
        
        pickerViewHourMiddle = pickerViewRows * alarmHour.count / 2
        pickerViewMinuteMiddle = pickerViewRows * alarmMinute.count / 2
        
        if let row = rowForHourValue(value: timeSetHour) {
            alarmPickerView.selectRow(row, inComponent: 0, animated: false)
        }
        
        if let row = rowForMinuteValue(value: timeSetMinute) {
            alarmPickerView.selectRow(row, inComponent: 1, animated: false)
        }
        
        bookmarkSwitch.setOn(todoBookmark, animated: false)
        alarmSwitch.setOn(todoAlarm, animated: false)
        alarmTimeSetLabel.isHidden = !todoAlarm
        alarmTimeSetLabel.text = todoAlarmTime
        
        self.view.layer.cornerRadius = 15
        super.viewDidLoad()
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    enum AlarmTimeStatus {
        case past
        case present
        case future
    }
    
    func alarmTimeComparedToCurrentTime() -> AlarmTimeStatus {
        if dateCompare() > 0 {
            return .future
        }
        else if timeSetHour == currentTimeComponent.hour! && timeSetMinute > currentTimeComponent.minute!  {
            return .present
        }
        else if timeSetHour > currentTimeComponent.hour! {
            return .present
        }
        else {
            return .past
        }
    }
    
    func saveTodoList() {
        if alarmSwitch.isOn {
            switch alarmTimeComparedToCurrentTime() {
            case .past:
                presentErrorAlert(errorTitle: "알림", errorMessage: "이미 지난 시간에는 알람을 설정할 수 없습니다\n시간을 다시 설정해주세요")
                removeNofiticaion(identifier: "todoAlarm_\(todoId)")
            case .present:
                saveAlarm()
            case .future:
                saveAlarm()
            }
        }
        else {
            todoAlarm = false
            todoAlarmTime = ""
            try! realm.write {
                realm.create(TodoList.self, value: ["id": todoId, "todoContent": todoListContentTextField.text ?? "", "bookmark": todoBookmark, "alarm": todoAlarm, "alarmTime": todoAlarmTime], update: .modified)
            }
            userNotiCenter.removePendingNotificationRequests(withIdentifiers: ["todoAlarm_\(todoId)"])
            dismiss(animated: true, completion: nil)
        }
    }

    func saveAlarm() {
        todoAlarmTime = "\(timeSetHour):\(timeSetMinute)"
        todoAlarm = true
        requestSendNotification(todoContent: todoContent, todoId: todoId, todoDate: todoDate, notiHour: timeSetHour, notiMinute: timeSetMinute)
        editTodoDelegate?.alertAlarmComplete()
        
        try! realm.write {
            realm.create(TodoList.self, value: ["id": todoId, "todoContent": todoListContentTextField.text ?? "", "bookmark": todoBookmark, "alarm": todoAlarm, "alarmTime": todoAlarmTime], update: .modified)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveEditedTodoList(_ sender: Any) {
        saveTodoList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTodoList()
        return true
    }
    
    @IBAction func bookmarkSwitchTapped(_ sender: Any) {
        if bookmarkSwitch.isOn {
            todoBookmark = true
        }
        else {
            todoBookmark = false
        }
    }
    
    @IBAction func alarmSwitchTapped(_ sender: Any) {
        alarmPickerView.isHidden = true
        alarmTimeSetLabel.isHidden = true
        
        if alarmSwitch.isOn {
            // 알람 설정 날짜가 과거일 때
            if dateCompare() < 0 {
                let setAlarmErrorAlert = UIAlertController(title: "알람설정 실패", message: "이미 지난 시간에는 알람을 설정할 수 없습니다", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "확인", style: .default) { [self]
                    (action) in
                    alarmSwitch.setOn(false, animated: true)
                }
                
                setAlarmErrorAlert.addAction(confirmAction)
                self.present(setAlarmErrorAlert, animated: true, completion: nil)
                todoAlarm = false
                try! realm.write {
                    realm.create(TodoList.self, value: ["id": todoId, "alarm": todoAlarm], update: .modified)
                }
            }
            else {  // 알람 날짜는 가능
                checkAuthNotification() //MARK: false면 설정에서 알림 허용하게 만들기
                requestAuthNotification()
                alarmPickerView.isHidden = false
                alarmTimeSetLabel.isHidden = false
                todoAlarm = true
            }
        }
        else {  // switch is off
            todoAlarm = false
            try! realm.write {
                realm.create(TodoList.self, value: ["id": todoId, "alarm": todoAlarm], update: .modified)
            }
        }
    }
    
    @IBAction func deleteTodoList(_ sender: Any) {
        let TodoListToDelete = realm.objects(TodoList.self).filter("id == \(todoId)")
        try! realm.write {
            realm.delete(TodoListToDelete)
        }
        editTodoDelegate?.reorderDeletedList()
        dismiss(animated: true, completion: nil)
    }
    
    func dateCompare() -> Double {
        var date = Date()
        let dateString = todoDate.replacingOccurrences(of: "/", with: "-")
        date = dateString.stringToDate()!   // todo 작성한 날짜
        
        currentComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        currentComponent.timeZone = TimeZone(abbreviation: "UTC")
        let currentTime = Calendar.current.date(from: currentComponent)!   // 현재 날짜 시간까지
        
        let selectedDateInterval = date.timeIntervalSince1970  //선택한 날짜
        let currentDateInterval = currentTime.timeIntervalSince1970  //현재날짜
        return selectedDateInterval - currentDateInterval
    }
    
    func requestAuthNotification() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { [self] (didAllow, error) in
            if didAllow == false {
                print("requestAuthorization didAllow False")
                //                DispatchQueue.main.async {
                //                    bookmarkSwitch.setOn(false, animated: true)
                //                }
                
                //                bookmarkSwitch.setOn(false, animated: true)
                todoAlarm = false
                
            }
            if let error = error {
                print(#function, error)
            }
        }
    }
    
    // 초기에 알람설정 허용했는지 확인
    func checkAuthNotification() -> Bool {
        var authCheck = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if (granted) {
                authCheck = true
            } else {
                authCheck = false
            }
        })
        return authCheck
    }
    
    func requestSendNotification(todoContent: String, todoId: Int, todoDate: String, notiHour: Int, notiMinute: Int) {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "TODO 알림"
        notiContent.body = todoContent
        notiContent.badge = 1
        var date = Date()
        let dateString = todoDate.replacingOccurrences(of: "/", with: "-")
        date = dateString.stringToDate()!
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = notiHour
        dateComponents.minute = notiMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let strIdentifier = "todoAlarm_\(todoId)"
        let request = UNNotificationRequest(identifier: strIdentifier, content: notiContent, trigger: trigger)
        
        userNotiCenter.add(request) { (error) in
            print(#function, error)
        }
    }
    
    func removeNofiticaion(identifier: String) {
        userNotiCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

extension EditTodoListViewController: UNUserNotificationCenterDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .badge, .sound, .banner])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return pickerViewRows * alarmHour.count
        case 1:
            return pickerViewRows * alarmMinute.count
        default:
            return 0
        }
    }
    
    func rowForHourValue(value: Int) -> Int? {
        if let valueIndex = alarmHour.firstIndex(of: value) {
            return pickerViewHourMiddle + valueIndex
        }
        return nil
    }
    
    func rowForMinuteValue(value: Int) -> Int? {
        if let valueIndex = alarmMinute.firstIndex(of: value) {
            return pickerViewMinuteMiddle + valueIndex
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let newHourRow = pickerViewHourMiddle + (row % alarmHour.count)
            alarmPickerView.selectRow(newHourRow, inComponent: 0, animated: false)
            timeSetHour = alarmHour[row % alarmHour.count]
        case 1:
            let newMinuteRow = pickerViewMinuteMiddle + (row % alarmMinute.count)
            alarmPickerView.selectRow(newMinuteRow, inComponent: 1, animated: false)
            timeSetMinute = alarmMinute[row % alarmMinute.count]
            break
        default:
            break
        }
        alarmTimeSetLabel.text = "\(timeSetHour):\(timeSetMinute)"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let viewWidth = alarmPickerView.frame.size.width * 1/3
        let view = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth * 2/3))
        let alarmLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth * 2/3))
        alarmLabel.font = .NanumSR(.regular, size: 14)
        alarmLabel.textColor = .black
        alarmLabel.textAlignment = .center
        
        switch component {
        case 0:
            alarmLabel.text = String(alarmHour[row % alarmHour.count])
            break
        case 1:
            alarmLabel.text = String(alarmMinute[row % alarmMinute.count])
            break
        default:
            break
        }
        
        view.addSubview(alarmLabel)
        return view
    }
}
