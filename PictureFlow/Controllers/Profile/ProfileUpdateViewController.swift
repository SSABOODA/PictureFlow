//
//  ProfileUpdateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileUpdateViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

final class ProfileUpdateViewController: UIViewController {
    let mainView = ProfileUpdateView()
    let viewModel = ProfileUpdateViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
}

extension ProfileUpdateViewController {
    private func configureNavigationBar() {
        navigationItem.title = "프로필 편집"
        
        let updateCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = updateCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        let updateSuccessButton = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.rightBarButtonItem = updateSuccessButton
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
}
