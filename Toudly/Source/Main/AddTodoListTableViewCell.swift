//
//  AddTodoListTableViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/01/16.
//

import UIKit
import RealmSwift

protocol NewTodoListDelegate: AnyObject {
    func makeNewTodoList(date: String)
    func revokeAddCell(date: String)
}

class AddTodoListTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var AddTodoListTextField: UITextField!
    weak var newListDelegate: NewTodoListDelegate?
    private let realm = try! Realm()
    var selectedDate = ""
    var date = ""
    var order = 0
    var id = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // TODO: 데이터 전달 확인
    func initAddCell(selectedDate: String, date: String, order: Int, id: Int) {
        self.selectedDate = selectedDate
        self.date = date
        self.order = order
        self.id = id
        AddTodoListTextField.text = ""
        AddTodoListTextField.font = .appRegularFont(13)
        AddTodoListTextField.delegate = self
        AddTodoListTextField.returnKeyType = .done
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopAddingCell), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAddingCell), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func saveToRealm(_ contentText: String) {
        realm.beginWrite()
        let newTodoList = TodoList()
        newTodoList.todoContent = contentText
        newTodoList.date = selectedDate
        newTodoList.order = order
        newTodoList.id = id
        realm.add(newTodoList)
        try! realm.commitWrite()
        newListDelegate?.makeNewTodoList(date: date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = AddTodoListTextField.text
        if text != "" {
            saveToRealm(text!)
        }
        else {
            newListDelegate?.revokeAddCell(date: date)
        }
        return true
    }
    
    @objc func stopAddingCell() {
        AddTodoListTextField.text = ""
        textFieldShouldReturn(self.AddTodoListTextField)
    }
}
