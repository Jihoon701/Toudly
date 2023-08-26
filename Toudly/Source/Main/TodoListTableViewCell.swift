//
//  TodoListTableViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/01/16.
//

import UIKit
import RealmSwift

class TodoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkboxImage: UIImageView!
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var alarmImage: UIImageView!
    @IBOutlet weak var todoListLabel: UILabel!
    
    private let realm = try! Realm()
    var todoListContent = ""
    var todoId = 0
    var todolistDone = false
    
    override func awakeFromNib() {
        setUI()
        super.awakeFromNib()
    }
    
    func setUI() {
        self.selectionStyle = .none
        let checkboxTapGesture = UITapGestureRecognizer(target: self, action: #selector(PressCheckbox))
        checkboxImage.addGestureRecognizer(checkboxTapGesture)
        checkboxImage.isUserInteractionEnabled = true
        todoListLabel.font = .appBoldFont(13)
        alarmTimeLabel.font = .appBoldFont(12)
        alarmTimeLabel.textColor = .lightGray
    }
    
    func configureTodoCell(todoList: TodoList) {
        self.todolistDone = todoList.checkbox
        self.todoListContent = todoList.todoContent
        self.todoId = todoList.id
        
        if todolistDone {
            strikeThroughTodoList()
        }
        else {
            originalTodoList()
        }
        
        if todoList.alarm {
            alarmTimeLabel.text = todoList.alarmTime
            alarmTimeLabel.sizeToFit()
            alarmTimeLabel.isHidden = false
            alarmImage.isHidden = false
        }
        else {
            alarmTimeLabel.isHidden = true
            alarmImage.isHidden = true
        }
        
        todoListLabel.sizeToFit()
        bookmarkImage.isHidden = !todoList.bookmark
        
        self.layoutIfNeeded()
    }
    
    @objc func PressCheckbox(todoListDone: Bool) {
        if todolistDone {
            updateRealmCheckbox(id: todoId, checkbox: false)
            originalTodoList()
        }
        else {
            updateRealmCheckbox(id: todoId, checkbox: true)
            strikeThroughTodoList()
        }
    }
    
    func updateRealmCheckbox(id: Int, checkbox: Bool) {
        try! realm.write {
            realm.create(TodoList.self, value: ["id": id, "checkbox": checkbox], update: .modified)
        }
    }
    
    func strikeThroughTodoList() {
        checkboxImage.image = UIImage(named: "checkBox")
        let strikethroughlineAttribute: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
            .paragraphStyle: {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                return paragraphStyle
            }()
        ]
        let strikethroughlineAttributedString = NSAttributedString(string: todoListContent, attributes: strikethroughlineAttribute)
        
        todoListLabel.attributedText = strikethroughlineAttributedString
        bookmarkImage.image = UIImage(named: "bookmark_gray")
    }
    
    func originalTodoList() {
        checkboxImage.image = UIImage(named: "emptyBox")
        let attributeString = NSMutableAttributedString(string: todoListContent)
        attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributeString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributeString.length))
        
        todoListLabel.attributedText = attributeString
        bookmarkImage.image = UIImage.coloredBookmarkImage(bookmarkImage.image!)()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
