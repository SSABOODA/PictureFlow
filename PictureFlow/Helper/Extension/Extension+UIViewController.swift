//
//  Extension+UIViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

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
    func changeRootViewController<T: UIViewController>(viewController: T) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        let vc = viewController
        let nav = UINavigationController(rootViewController: vc)
        sceneDelegate?.window?.rootViewController = nav
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
        completeTitle: String = "확인", _ completeHandler:(() -> Void)? = nil) {
            
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
        completeTitle: String = "확인",  _ cancelHandler: (() -> Void)? = nil, _ completeHandler: (() -> Void)? = nil) {
            
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
