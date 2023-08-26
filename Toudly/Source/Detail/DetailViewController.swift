//
//  DetailViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/19.
//

import UIKit
import XLPagerTabStrip

class DetailViewController: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var TitleLabel: UILabel!

//    var mainVC: MainViewController?
    var detailDelegate: SearchTodoListDelegate?
    
    @IBAction func backToHomeVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        TitleLabel.font = .appBoldFont(16)
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .black
        settings.style.selectedBarHeight = 1.5
        settings.style.buttonBarItemFont = .appBoldFont(16)
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.lightGray182
            newCell?.label.textColor = .black
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let monthlyVC = self.storyboard?.instantiateViewController(withIdentifier: "MonthlyDetailViewController") as! MonthlyDetailViewController
        let alarmVC = self.storyboard?.instantiateViewController(withIdentifier: "AlarmDetailViewController") as! AlarmDetailViewController
        let bookmarkVC = self.storyboard?.instantiateViewController(withIdentifier: "BookmarkDetailViewController") as! BookmarkDetailViewController
        let incompleteVC = self.storyboard?.instantiateViewController(withIdentifier: "IncompleteDetailViewController") as! IncompleteDetailViewController
        let completedVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletedDetailViewController") as! CompletedDetailViewController
        
        alarmVC.delegate = self
        bookmarkVC.delegate = self
        incompleteVC.delegate = self
        completedVC.delegate = self
        
        return [alarmVC, bookmarkVC, incompleteVC, completedVC]
    }
}

extension DetailViewController: MoveToMainDetailDelegate {
    func moveToMainDetail(selectedDate: String) {
        var array = [selectedDate]
        let selectedDateArray = selectedDate.components(separatedBy: "/")
        let month = Int(selectedDateArray[1])!
        let date = selectedDateArray[2]
        dismiss(animated: true, completion: nil)
        detailDelegate?.moveToSelectedList(selectedDate: selectedDate, month: month, date: date)
    }    
}

protocol MoveToMainDetailDelegate: AnyObject {
    func moveToMainDetail(selectedDate: String)
}
