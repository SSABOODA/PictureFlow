//
//  SettingViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SettingItem {
    let name: String
    let image: UIImage?
}

final class SettingViewModel: ViewModelType {
    struct Input {}
    struct Output {}
    
    var disposeBag = DisposeBag()
    
    
    let settingItemList = [
        SettingItem(name: "로그아웃", image: nil),
        SettingItem(name: "회원탈퇴", image: nil),
    ]
    
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

final class SettingViewController: UIViewController {
    let mainView = SettingView()
    let viewModel = SettingViewModel()
    
    
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
}

extension SettingViewController {
    private func configureNavigationBar() {
        navigationItem.title = "설정"
        self.setNavigationBarBackButtonItem(color: UIColor(resource: .text))
    }
}
