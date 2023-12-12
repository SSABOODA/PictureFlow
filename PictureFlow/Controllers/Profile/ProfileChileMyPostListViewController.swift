//
//  ProfileChileMyPostListViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileChileMyPostListViewController: UIViewController {
    
    let emptyView = ProfileChileMyPostListEmptyView()
    let mainView = ProfileChileMyPostListView()
    let viewModel = ProfileChileMyPostListViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        if self.viewModel.postList.isEmpty {
            view = emptyView
        } else {
            view = mainView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        emptyView.firstStartButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = NewPostWriteViewController()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
}
