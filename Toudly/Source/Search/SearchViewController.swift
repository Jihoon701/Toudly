//
//  SearchViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/17.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    let realm = try! Realm()
    weak var searchTodoListDelegate: SearchTodoListDelegate?
    var searchlist: Results<TodoList>!
    var searchingLetter: String?
    
    @IBAction func backToMainVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreOptionBtnTapped(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        setUI()
        setTextField()
        setTableView()
        super.viewDidLoad()
    }
    
    func setUI() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.font = .appBoldFont(14)
    }
    
    func setTextField() {
        searchTextField.setupLeftImage(imageName: "search")
        searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchlist = realm.objects(TodoList.self).filter("todoContent CONTAINS[c] %@", searchTextField.text ?? "").sorted(byKeyPath: "todoContent", ascending: true)
        searchingLetter = searchTextField.text ?? ""
        searchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(TodoList.self).filter("todoContent CONTAINS[c] %@", searchTextField.text ?? "").sorted(byKeyPath: "todoContent", ascending: true).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        
        if let letter = searchingLetter {
            cell.configureSearchCell(target: searchlist[indexPath.row], searchLetter: letter)
        }
        else {
            cell.configureCell(target: searchlist[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDate = searchlist[indexPath.row].date
        let selectedDateArray = selectedDate.components(separatedBy: "/")
        let month = Int(selectedDateArray[1])!
        let date = selectedDateArray[2]
        dismiss(animated: true, completion: nil)
        searchTodoListDelegate?.moveToSelectedList(selectedDate: selectedDate, month: month, date: date)
    }
}

protocol SearchTodoListDelegate: AnyObject {
    func moveToSelectedList(selectedDate: String, month: Int, date: String)
}
