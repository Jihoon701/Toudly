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
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var todoListTableView: UITableView!
    
    lazy var holidayDataManager = HolidayDataManager()
    let holidayCalendar = HolidayCalendar()
    let todoCalendar = TodoCalendar()
    let todoDate = TodoDate()
    let realm = try! Realm()
    var list: Results<TodoList>!
    var realmNotificationToken: NotificationToken?
    
    var weeks: [String] = ["Su".localized(), "M".localized(), "Tu".localized(),
                           "W".localized(), "Th".localized(), "F".localized(), "Sa".localized()]
    var addTodoListCellExist = false
    var selectedRow = 0
    var selectedDateConfirmed = false
    var selectedDate = ""
    var editedTodoListDate = ""
    var newSelectedDate = ""
    
    func initialSetup() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        todoListTableView.delegate = self
        todoListTableView.dataSource = self
        
        todoListTableView.dragInteractionEnabled = true
        todoListTableView.dragDelegate = self
        todoListTableView.dropDelegate = self
        
        calendarCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCollectionViewCell")
        todoListTableView.register( UINib(nibName: "TodoListTableViewCell", bundle: nil), forCellReuseIdentifier: "TodoListTableViewCell")
        todoListTableView.register(UINib(nibName: "AddTodoListTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTodoListTableViewCell")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        todoListTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        list = realm.objects(TodoList.self).filter("date == %@", selectedDate).sorted(byKeyPath: "order", ascending: true)
        addTodoListCellExist = false
        calendarCollectionView.reloadData()
        setUI()
        
        for indexPath in todoListTableView.indexPathsForVisibleRows ?? [] {
            if let cell = todoListTableView.cellForRow(at: indexPath) as? TodoListTableViewCell {
                cell.setUI()
            }
        }
    }
    
    override func viewDidLoad() {
        self.initialSetup()
        todoCalendar.initCalendar()
        addTodoListCellExist = false
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Constant.reloadBookmark, object: nil)
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayInMonth())
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        realmNotification()
        setUI()
        super.viewDidLoad()
    }
    
    func setUI() {
        todoListTableView.layer.cornerRadius = 10
        calendarDateLabel.setupTitleLabel(text: todoCalendar.CalendarTitle())
        nextMonthButton.isHidden = Constant.isWeekType!
        previousMonthButton.isHidden = Constant.isWeekType!
    }
    
    @objc func reload() {
        self.todoListTableView.reloadData()
    }
    
    func realmNotification() {
        realmNotificationToken = realm.observe { [self] (notification, realm) in
            todoListTableView.reloadData()
            calendarCollectionView.reloadData()
        }
    }
    
    func changeCalendar(_ calendarType: Bool) {
        todoCalendar.initCalendar()
        changeCalendarLayout(calendarType: calendarType)
        if calendarType {   // week -> month
            createMonthlySelectedDate()
        }
        else {        // month -> week
            createWeeklySelectedDate()
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
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.modalPresentationStyle = .fullScreen
        vc.detailDelegate = self
//        vc.mainVC = self
        present(vc, animated: true)
    }
    
    @IBAction func toSearchVC(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.searchTodoListDelegate = self
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @IBAction func toSettingVC(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func rearrangeCalendar() {
        list = realm.objects(TodoList.self).filter("date == %@", selectedDate).sorted(byKeyPath: "order", ascending: true)
        calendarCollectionView.reloadData()
        calendarCollectionViewHeight.constant = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
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
        calendarCollectionViewHeight.constant = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
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
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayInMonth())
        selectedDate = "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)/"
        selectedDate += newSelectedDate
    }
    
    func createWeeklySelectedDate() {
        newSelectedDate = todoDate.changeDayStatus(checkCurrentDayMonth: todoCalendar.checkCurrentDayInMonth())
        selectedDate = "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)/"
        selectedDate += newSelectedDate
    }
    
    func createSelectedDate(indexPath: IndexPath, calendarType: Bool) {
        if calendarType {
            newSelectedDate = "\(todoCalendar.daysInWeekType[indexPath.item])"
            selectedDate = "\(todoCalendar.checkWeekTypeCategory(weekTypeCategory: todoCalendar.weekTypeCategoryArray[indexPath.item]))/"
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
        calendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
        var daysInAccordanceWithType = ""
        
        if indexPath.section == 0 {
            cell.initWeekdayCell(text: weeks[indexPath.item])
            return cell
        }
        
        if Constant.isWeekType! {     // MARK: Week Type
            let weekTypeDate = todoCalendar.checkWeekTypeCategory(weekTypeCategory: todoCalendar.weekTypeCategoryArray[indexPath.item])
            daysInAccordanceWithType = todoCalendar.daysInWeekType[indexPath.item]
            cell.initDayCell(currentDay: daysInAccordanceWithType, haveTodayDate: true, date: weekTypeDate, haveHolidayDate: todoCalendar.checkHolidayInMonth())
        }
        else {      // MARK: Month Type
            daysInAccordanceWithType = todoCalendar.daysInMonthType[indexPath.item]
            cell.initDayCell(currentDay: daysInAccordanceWithType, haveTodayDate: todoCalendar.checkCurrentDayInMonth(), date: "\(todoCalendar.calendarYear)/\(todoCalendar.calendarMonth)", haveHolidayDate: todoCalendar.checkHolidayInMonth())
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
        let width = calendarCollectionView.frame.size.width / 7 - 5
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
        listCell.configureTodoCell(todoList: list[indexPath.row])
        
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

extension MainViewController: NewTodoListDelegate, EditTodoDelegate, SearchTodoListDelegate {
    func alertAlarmComplete(date: String) {
        self.presentBottomAlert(message: "Notification Set".localized())
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
    
    func moveToSelectedList(selectedDate: String, month: Int, date: String) {
        todoCalendar.moveCalendarToSpecificMonth(month: month, calendarTitleLabel: calendarDateLabel)
        self.newSelectedDate = date
        self.selectedDate = selectedDate
        rearrangeCalendar()
    }
}
