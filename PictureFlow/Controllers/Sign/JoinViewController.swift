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
        
        
        // TODO: api Test
//        mainView.testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        
        
        mainView.testButton.rx.tap
            .subscribe(with: self) { owner, _ in
                print("clicked")
            } onError: { owner, error in
                print("onError")
            } onCompleted: { owner in
                print("onCompleted")
            }
            .disposed(by: disposeBag)
    }
    
    // TODO: api test
    @objc func testButtonTapped() {
        let data = LoginRequest(email: "qwer12364@naver.com", password: "123456")
        Network.shared.requestConvertible(type: LoginResponse.self, router: .login(model: data)) { response in
            print(response)
            switch response {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error.errorDescription, error)
                switch error {
                case .missingRequireParameter:
                    let alert = UIAlertController(title: "\(error.errorDescription)", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .destructive) { _ in }
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                default:
                    print(456)
                    
                }
            }
        }
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
        let backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: nil
        )
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
}
