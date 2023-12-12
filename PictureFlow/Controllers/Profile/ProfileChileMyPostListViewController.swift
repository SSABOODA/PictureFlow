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
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("profile chile vc viewDidLoad")
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        viewModel.fetchProfileMyPostListData()
    }
    
    private func emptyViewBind() {
        mainView.firstStartButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = NewPostWriteViewController()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        emptyViewBind()
        let input = ProfileChileMyPostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.myPostListObservable
            .subscribe(with: self) { owner, myPostList in
                owner.mainView.firstStartButton.isHidden = myPostList.isEmpty ? false : true
            }
            .disposed(by: disposeBag)
  
        output.myPostListObservable
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: PostListTableViewCell.description(),
                cellType: PostListTableViewCell.self)) { (row, element, cell) in
                    cell.configureCell(with: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.fetchProfileMyPostListData()
    }
}
