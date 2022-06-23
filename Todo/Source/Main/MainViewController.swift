//
//  MainViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/01/12.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var calendarDateLabel: UILabel!
    @IBOutlet weak var CalendarCollectionView: UICollectionView!
    @IBOutlet weak var CalendarCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var todoListTableView: UITableView!
    
    let todoCalendar = TodoCalendar()
    let todoDate = TodoDate()
    let realm = try! Realm()
    var list: Results<TodoList>!
    var realmNotificationToken: NotificationToken?
    
    var weeks: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    var addTodoListCellExist = false
    var selectedRow = 0
    var selectedDateConfirmed = false
    var selectedDate = ""
    var editedTodoListDate = ""
    var newSelectedDate = ""
    
    func initialSetup() {
        CalendarCollectionView.delegate = self
        CalendarCollectionView.dataSource = self
        
        todoListTableView.delegate = self
        todoListTableView.dataSource = self
        
        todoListTableView.dragInteractionEnabled = true
        todoListTableView.dragDelegate = self
        todoListTableView.dropDelegate = self
        
        CalendarCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCollectionViewCell")
        todoListTableView.register( UINib(nibName: "TodoListTableViewCell", bundle: nil), forCellReuseIdentifier: "TodoListTableViewCell")
        todoListTableView.register(UINib(nibName: "AddTodoListTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTodoListTableViewCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addTodoListCellExist = false
        todoListTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        print(self)
        self.initialSetup()
        todoCalendar.initCalendar()
        todoListTableView.layer.cornerRadius = 10
        addTodoListCellExist = false
        calendarDateLabel.setupTitleLabel(text: todoCalendar.CalendarTitle())
        nextMonthButton.isHidden = Constant.isWeekType!
        previousMonthButton.isHidden = Constant.isWeekType!
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Constant.reloadBookmark, object: nil)
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayMonth())
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        realmNotification()
        super.viewDidLoad()
    }
    
    @objc func reload() {
        self.todoListTableView.reloadData()
    }
    
    func realmNotification() {
        realmNotificationToken = realm.observe { [self] (notification, realm) in
            todoListTableView.reloadData()
            CalendarCollectionView.reloadData()
        }
    }
    
    func changeCalendar(_ calendarType: Bool) {
        todoCalendar.initCalendar()
        changeCalendarLayout(calendarType: calendarType)
        if calendarType {
            createWeeklySelectedDate()
        }
        else {
            createMonthlySelectedDate()
        }
        rearrangeCalendar()
    }
    
    func changeCalendarLayout(calendarType: Bool) {
        Constant.isWeekType = !calendarType
        nextMonthButton.isHidden = !calendarType
        previousMonthButton.isHidden = !calendarType
        calendarDateLabel.setupTitleLabel(text: todoCalendar.CalendarTitle())
    }
    
    @IBAction func changeCalendarType(_ sender: Any) {
        changeCalendar(Constant.isWeekType!)
    }
    
    @IBAction func addTodoList(_ sender: Any) {
        addTodoListCellExist = true
        todoListTableView.reloadData()
        DispatchQueue.main.async(execute: {
            self.todoListTableView.scrollToBottom()
            self.todoListTableView.becomeFirstResponderTextField()
        })
    }
    
    @IBAction func toDetailVC(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func toSearchVC(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController")
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @IBAction func toSettingVC(_ sender: Any) {
        print("push SettingViewController")
//        print(UINavigationController(nibName: "MainNavigarionController", bundle: nil))
        print(self)
        print(self.navigationController)
//        let a = self.navigationController
//
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController")as! SettingViewController
//        a?.pushViewController(vc, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func rearrangeCalendar() {
        list = realm.objects(TodoList.self).filter("date == %@", selectedDate).sorted(byKeyPath: "order", ascending: true)
        CalendarCollectionView.reloadData()
        CalendarCollectionViewHeight.constant = CalendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        todoListTableView.reloadData()
        view.setNeedsLayout()
    }
    
    @IBAction func toPreviousMonth(_ sender: Any) {
        todoCalendar.moveCalendarMonth(value: -1, calendarTitleLabel: calendarDateLabel)
        createMonthlySelectedDate()
        rearrangeCalendar()
    }
    
    @IBAction func toNextMonth(_ sender: Any) {
        todoCalendar.moveCalendarMonth(value: 1, calendarTitleLabel: calendarDateLabel)
        createMonthlySelectedDate()
        rearrangeCalendar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CalendarCollectionViewHeight.constant = CalendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        view.setNeedsLayout()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            if Constant.isWeekType! {
                return todoCalendar.daysInWeekType.count
            }
            else {
                return todoCalendar.daysInMonthType.count
            }
        }
    }
    
    func createMonthlySelectedDate() {
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayMonth())
        selectedDate = "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)/"
        selectedDate += newSelectedDate
    }
    
    func createWeeklySelectedDate() {
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayMonth())
        selectedDate = "\(todoCalendar.checkWeekTypeCategory(weekTypeCategory: todoCalendar.weekTypeCategory))/"
        selectedDate += newSelectedDate
    }
    
    func createSelectedDate(indexPath: IndexPath, calendarType: Bool) {
        if calendarType {
            newSelectedDate = "\(todoCalendar.daysInWeekType[indexPath.item])"
            selectedDate = "\(todoCalendar.checkWeekTypeCategory(weekTypeCategory: todoCalendar.weekTypeCategory))/"
            selectedDate += newSelectedDate
        }
        else {
            newSelectedDate =  "\(todoCalendar.daysInMonthType[indexPath.item])"
            selectedDate = "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)/"
            selectedDate += newSelectedDate
        }
        print("-> ",selectedDate)
    }
    
    func selectCalendarCell(indexPath: IndexPath, calendarType: Bool) {
        createSelectedDate(indexPath: indexPath, calendarType: calendarType)
        CalendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CalendarCollectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
        var daysInAccordanceWithType = ""
        
        if indexPath.section == 0 {
            cell.initWeekdayCell(text: weeks[indexPath.item])
            return cell
        }
        
        if Constant.isWeekType! {     // MARK: Week Type
            let weekTypeDate = todoCalendar.checkWeekTypeCategory(weekTypeCategory: todoCalendar.weekTypeCategory)
            daysInAccordanceWithType = todoCalendar.daysInWeekType[indexPath.item]
            cell.initDayCell(currentDay: daysInAccordanceWithType, isTodayDate: todoCalendar.checkCurrentDayMonth(), date: weekTypeDate)
        }
        else {      // MARK: Month Type
            daysInAccordanceWithType = todoCalendar.daysInMonthType[indexPath.item]
            cell.initDayCell(currentDay: daysInAccordanceWithType, isTodayDate: todoCalendar.checkCurrentDayMonth(), date: "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)")
        }
        
        if newSelectedDate == daysInAccordanceWithType {
            cell.isSelected = true
            selectCalendarCell(indexPath: indexPath, calendarType: Constant.isWeekType!)
        }
        else {
            cell.isSelected = false
            cell.DateLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        createSelectedDate(indexPath: indexPath, calendarType: Constant.isWeekType!)
        todoListTableView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CalendarCollectionView.frame.size.width / 7 - 5
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list = realm.objects(TodoList.self).filter("date == %@", selectedDate).sorted(byKeyPath: "order", ascending: true)
        
        if addTodoListCellExist {
            return list.count + 1
        }
        return list.count
    }
    
    func extractDateFromSelectedDate(selectedDate: String) -> String {
        let editedDateArray = selectedDate.components(separatedBy: "/")
        return editedDateArray[editedDateArray.count-1]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        editedTodoListDate = extractDateFromSelectedDate(selectedDate: selectedDate)
        if indexPath.row == list.count && addTodoListCellExist {
            let addCell = todoListTableView.dequeueReusableCell(withIdentifier: "AddTodoListTableViewCell", for: indexPath) as! AddTodoListTableViewCell
            addCell.initAddCell(selectedDate: selectedDate, date: editedTodoListDate, order: list.count, id: Constant.todoPrimaryKey)
            Constant.todoPrimaryKey += 1
            addCell.newListDelegate = self
            // TODO: 메인 화면에서 함수 호출 -> cell 안에서 작동하게 하는 방법 찾기
            textFieldShouldReturn(addCell.AddTodoListTextField)
            addTodoListCellExist = false
            
            return addCell
        }
        
        let listCell = todoListTableView.dequeueReusableCell(withIdentifier: "TodoListTableViewCell", for: indexPath) as! TodoListTableViewCell
        list = realm.objects(TodoList.self).filter("date == %@", selectedDate).sorted(byKeyPath: "order", ascending: true)
        let currentTodoList = list[indexPath.row]
        listCell.initTodoCell(todolistDone: currentTodoList.checkbox, todoListContent: currentTodoList.todoContent, bookmarkCheck: currentTodoList.bookmark, alarmCheck: currentTodoList.alarm, todoId: currentTodoList.id)
        return listCell
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        todoListTableView.estimatedRowHeight = todoListTableView.frame.width * 1/5
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) as? TodoListTableViewCell) != nil {
            guard let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditTodoListViewController") as? EditTodoListViewController else {return}
            selectedRow = indexPath.row
            editedTodoListDate = extractDateFromSelectedDate(selectedDate: selectedDate)
            // TODO: 데이터 전달 확인
            vc.todoContent = list[indexPath.row].todoContent
            vc.editTodoDelegate = self
            vc.todoId = list[indexPath.row].id
            vc.todoBookmark = list[indexPath.row].bookmark
            vc.todoAlarm = list[indexPath.row].alarm
            vc.todoAlarmTime = list[indexPath.row].alarmTime
            vc.todoSelectedDate = list[indexPath.row].date
            vc.date = editedTodoListDate
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = .black.withAlphaComponent(0.7)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceList = list[sourceIndexPath.row]
            let destinationList = list[destinationIndexPath.row]
            let destinationListOrder = destinationList.order
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    list[index].order -= 1
                }
            }
            else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    list[index].order += 1
                }
            }
            sourceList.order = destinationListOrder
        }
    }
}

extension MainViewController: NewTodoListDelegate, EditTodoDelegate {
    func alertAlarmComplete(date: String) {
        self.presentBottomAlert(message: "알림이 설정되었습니다")
        newSelectedDate = todoDate.changeEditedDayStatus(editedDate: date)
    }
    
    func reorderDeletedList(date: String) {
        let endIndex = list.count
        let startIndex = selectedRow
        try! realm.write {
            for index in startIndex..<endIndex {
                list[index].order -= 1
            }
        }
        newSelectedDate = todoDate.changeEditedDayStatus(editedDate: date)
    }
    
    func makeNewTodoList(date: String) {
        newSelectedDate = todoDate.changeEditedDayStatus(editedDate: date)
    }
    
    func revokeAddCell(date: String) {
        addTodoListCellExist = false
        newSelectedDate = todoDate.changeEditedDayStatus(editedDate: date)
        todoListTableView.reloadData()
    }
}
