//
//  Extension+UIViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import RxSwift

/*
 activity indicator
 */

extension UIViewController {
    func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s        
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
}

/*
 UISheetPresentationController
 */

extension UIViewController {
    func makeCustomSheetPresentationController(sheetVC: UIViewController) {
        if #available(iOS 16.0, *) {
            let _ = UISheetPresentationController.Detent.Identifier("customDetent")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { _ in
                return UIScreen.main.bounds.width * 0.45
            }
            
            if let sheet = sheetVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.detents = [customDetent, .medium()]
            }

        } else {
            if let sheet = sheetVC.sheetPresentationController {
//                sheet.prefersGrabberVisible = true
                sheet.detents = [.medium()]
            }
        }
        self.present(sheetVC, animated: true)
    }
}

/*
 화면 전환
 */
extension UIViewController {
    // 화면전환 메서드
    enum TransitionStyle {
        case present
        case presentNavigation
        case presentFullNavigation
        case push
    }
    
    func transition<T: UIViewController>(viewController: T, style: TransitionStyle) {
        let vc = viewController
        switch style {
        case .present:
            present(vc, animated: true)
        case .presentNavigation:
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        case .presentFullNavigation:
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Root ViewController
    func changeRootViewController<T: UIViewController>(viewController: T, isNav: Bool = false) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        let vc = isNav ? UINavigationController(rootViewController: viewController) : viewController
        sceneDelegate?.window?.rootViewController = vc
        sceneDelegate?.window?.makeKey()
    }
}

/*
 alert
 */
extension UIViewController {
    func showAlertAction1(
        preferredStyle: UIAlertController.Style = .alert,
        title: String = "",
        message: String = "",
        completeTitle: String = "확인",
        _ completeHandler:(() -> Void)? = nil
    ) {
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                
                let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                    completeHandler?()
                }
                
                alert.addAction(completeAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    
    
    func showAlertAction2(
        preferredStyle: UIAlertController.Style = .alert,
        title: String = "",
        message: String = "",
        cancelTitle: String = "취소",
        completeTitle: String = "확인",
        _ cancelHandler: (() -> Void)? = nil,
        _ completeHandler: (() -> Void)? = nil
    ) {
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                
                let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                    cancelHandler?()
                }
                
                let completeAction = UIAlertAction(title: completeTitle, style: .destructive) { action in
                    completeHandler?()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(completeAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
}


/*
 BackButtonItem
 */

extension UIViewController {
    func setNavigationBarBackButtonItem(title: String? = nil, color: UIColor) {
        let backBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: nil
        )
        backBarButtonItem.tintColor = color
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
}

/*
 User Info Delete
 */

extension UIViewController {
    func removeUserInfo() {
        KeyChain.delete(key: APIConstants.accessToken)
        KeyChain.delete(key: APIConstants.refreshToken)
        UserDefaultsManager.isLoggedIn = false
        UserDefaultsManager.userID = ""
    }
}

/*
 Rx Alert
 */

extension UIViewController {
    func showObservableAlert2(
        preferredStyle: UIAlertController.Style = .alert,
        title: String = "",
        message: String = "",
        cancelTitle: String = "취소",
        completeTitle: String = "확인",
        _ cancelHandler: (() -> Void)? = nil,
        _ completeHandler: (() -> Void)? = nil
    ) -> Observable<UIAlertController> {
        
        var alert = UIAlertController()
        DispatchQueue.main.async {
            alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancelHandler?()
            }
            
            let completeAction = UIAlertAction(title: completeTitle, style: .destructive) { action in
                completeHandler?()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(completeAction)
            self.present(alert, animated: true, completion: nil)
        }
        return Observable.just(alert)
    }
}


/*
 Hashtags
 */

extension UIViewController {
    func processHashtags(in text: String?) -> NSMutableAttributedString {
        guard let text = text else {
            return NSMutableAttributedString()
        }

        let attributedText = NSMutableAttributedString(string: text)
        
        do {

            // 해시태그에 대한 속성 설정
            let hashtagAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 17),
                .foregroundColor: UIColor.systemBlue
            ]
            
            // 일반 텍스트에 대한 속성 설정
            let regularTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor(resource: .text)
            ]
            
            // 해시태그와 일반 텍스트에 대해 각각 속성 적용
            let regex = try NSRegularExpression(pattern: "#(\\w+)")
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            // 기존 속성 초기화
            attributedText.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: attributedText.length))
            attributedText.addAttributes(regularTextAttributes, range: NSRange(location: 0, length: attributedText.length))
            
            for result in results {
                let hashtagRange = Range(result.range, in: text)!
                let nsRange = NSRange(hashtagRange, in: text)
                
                // 해시태그에 대한 속성 적용
                attributedText.addAttributes(hashtagAttributes, range: nsRange)
            }
            
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        return attributedText
    }
}


/*
 removeNotificationCenterObserver
 */

extension UIViewController {
    func removeNotificationCenterObserver(notificationName: String) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(notificationName),
            object: nil
        )
    }
}


/*
  tabbar
 */

extension UIViewController {
    func postViewControllerModalPresent(viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            let vc = NewPostWriteViewController()
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
            return false
        } else {
            return true
        }
    }
}
