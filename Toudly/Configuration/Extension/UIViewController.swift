//
//  UIViewController.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/26.
//

import Foundation
import UIKit
import SnapKit

extension UIViewController {
    
    func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            let nav = UINavigationController(rootViewController: mainVC)
            window.rootViewController = nav
            nav.navigationBar.isHidden = true
        } else {
            self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
        }
    }
    
    func presentAlert(title: String, message: String? = nil, isCancelActionIncluded: Bool = false, preferredStyle style: UIAlertController.Style = .alert, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let actionDone = UIAlertAction(title: "OK".localized(), style: .default, handler: handler)
        alert.addAction(actionDone)
        if isCancelActionIncluded {
            let actionCancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alert.addAction(actionCancel)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(errorTitle: String, errorMessage: String) {
        let setAlarmErrorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK".localized(), style: .default)
        setAlarmErrorAlert.addAction(confirmAction)
        self.present(setAlarmErrorAlert, animated: true, completion: nil)
    }
    
    func presentBottomAlert(message: String, target: ConstraintRelatableTarget? = nil, offset: Double? = -12) {
        let alertSuperview = UIView()
        alertSuperview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertSuperview.layer.cornerRadius = 10
        alertSuperview.isHidden = true
        
        let alertLabel = UILabel()
        alertLabel.font = .appRegularFont(14)
        alertLabel.textColor = .white
        
        self.view.addSubview(alertSuperview)
        alertSuperview.snp.makeConstraints { make in
            make.bottom.equalTo(target ?? self.view.safeAreaLayoutGuide).offset(-12)
            make.centerX.equalToSuperview()
        }
        
        alertSuperview.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
        }
        
        alertLabel.text = message
        alertSuperview.alpha = 1.0
        alertSuperview.isHidden = false
        UIView.animate(
            withDuration: 2.0,
            delay: 1.0,
            options: .curveEaseIn,
            animations: { alertSuperview.alpha = 0 },
            completion: { _ in
                alertSuperview.removeFromSuperview()
            }
        )
    }
}
