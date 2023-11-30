//
//  HomeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

final class PostListViewController: UIViewController {
    
    let mainView = PostListView()
    let viewModel = PostListViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, PostListViewController.description())
        navigationItem.title = "FLOW"
        bind()
        
        configureRefreshControl()
        setNavigationBarBackButtonItem(title: "뒤로", color: UIColor(resource: .tint))
        
        printAccessToken() // @Deprecated
    }
    
    func printAccessToken() {
//        let accessToken = KeyChain.read(key: "accessToken")!
//        print("accessToken: \(accessToken)")
//        let refreshToken = KeyChain.read(key: "refreshToken")!
//        print("refreshToken: \(refreshToken)")
    }
    
    func configureRefreshControl() {
        mainView.refreshControl.endRefreshing()
        mainView.tableView.refreshControl = mainView.refreshControl
        
        mainView.refreshControl.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    owner.viewModel.updateDateSource()
                    owner.mainView.refreshControl.endRefreshing()
                    owner.viewModel.refreshLoading.accept(true)
                }
            }
            .disposed(by: disposeBag)
    }

    private func bind() {
        let input = PostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                print("postListVC error: \(error.message) \(error.statusCode)")
            }
            .disposed(by: disposeBag)
        
        output.postListItem
            .bind(to: mainView.tableView.rx.items(cellIdentifier: PostListTableViewCell.description(), cellType: PostListTableViewCell.self)) { (row, element, cell) in
                cell.configureCell(with: element)
            }
            .disposed(by: disposeBag)
        
        output.refreshLoading
            .bind(to: mainView.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        
        Observable.zip(
            mainView.tableView.rx.itemSelected,
            mainView.tableView.rx.modelSelected(PostList.self)
        )
            .map {
                let item = $0.1
                return PostList(_id: item._id, likes: item.likes, image: item.image, title: item.title, content: item.content, time: item.time, productID: item.productID, creator: item.creator, comments: item.comments)
            }
            .subscribe(with: self) { owner, value in
                let vc = PostDetailViewController()
                vc.viewModel.postList = value
                owner.transition(viewController: vc, style: .push)
            }
            .disposed(by: disposeBag)
    }
}

