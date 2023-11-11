//
//  ViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import RxSwift
import RxCocoa

final class JoinViewController: UIViewController {
    
    let mainView = JoinView()
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        bind()
    }
    
    private func bind() {
        mainView.signUpButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = SignUpViewController()
                owner.transition(viewController: vc, style: .push)
            }
            .disposed(by: disposeBag)
        
        mainView.signInButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = SignInViewController()
                owner.transition(viewController: vc, style: .push)
            }
            .disposed(by: disposeBag)
    }
}

extension JoinViewController {
    private func setNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
}
