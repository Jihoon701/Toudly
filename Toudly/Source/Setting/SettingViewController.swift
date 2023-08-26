//
//  SettingViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/19.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!
    
    @IBAction func BackToHomeVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingTableView.reloadData()
    }
    
    override func viewDidLoad() {
        titleLabel.setupTitleLabel(text: "Settings".localized())
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.allowsSelection = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        super.viewDidLoad()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let compseVC = MFMailComposeViewController()
            compseVC.mailComposeDelegate = self
            compseVC.setToRecipients(["kb5i701@gmail.com"])
            self.present(compseVC, animated: true, completion: nil)
        }
        else {
            let sendMailErrorAlert = UIAlertController(title: "Failed to send mail".localized(), message: "Please check the iPhone email settings and try again".localized(), preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK".localized(), style: .default)
            sendMailErrorAlert.addAction(confirmAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func rateThisApp() {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(1630140322)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil) } else { UIApplication.shared.openURL(reviewURL) } }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.initSettingCell(row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "TodoManualViewController") as! TodoManualViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "ScreenSettingViewController") as! ScreenSettingViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "DataSettingViewController") as! DataSettingViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "AlarmSettingViewController") as! AlarmSettingViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 4:
            sendEmail()
            
        case 5:
            rateThisApp()
            
//        case 6:
//            let vc = storyboard?.instantiateViewController(withIdentifier: "OpenSourceViewController") as! OpenSourceViewController
//            self.navigationController?.pushViewController(vc, animated: true)
            
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settingTableView.frame.width * 1/8
    }
}
