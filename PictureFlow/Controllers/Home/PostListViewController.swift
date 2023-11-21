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

struct DataList {
    let name: String
    let content: String
}

final class PostListViewController: UIViewController {
    
    let mainView = PostListView()
    let viewModel = PostListViewModel()
    var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(
            PostListTableViewCell.self,
            forCellReuseIdentifier: PostListTableViewCell.description()
        )
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = UIColor(resource: .backgorund)
        return view
    }()
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, PostListViewController.description())
        navigationItem.title = "FLOW"
        configureHierarchy()
        bind()
        
        configureRefreshControl()
        printAccessToken() // @Deprecated

    }
    
    func printAccessToken() {
        let accessToken = KeyChain.read(key: "accessToken")!
        print("accessToken: \(accessToken)")
//        let refreshToken = KeyChain.read(key: "refreshToken")!
//        print("refreshToken: \(refreshToken)")
    }
    
    func configureRefreshControl() {
        refreshControl.endRefreshing()
        tableView.refreshControl = refreshControl
        
        let refreshLoading = PublishRelay<Bool>() // ViewModel에 있다고 가정
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] _ in
                // viewModel.updateDataSource()
                // 아래코드: viewModel에서 발생한다고 가정
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) { [weak self] in
//                    self?.refreshLoading.accept(true) // viewModel에서 dataSource업데이트 끝난 경우
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }

    private func bind() {
        let input = PostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
//         TODO: @deprecated 네트워크 통신 데이터 확인용 바인딩:
        output.postListItem
            .subscribe(with: self) { owner, result in
//                dump(result)
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                print("postListVC error: \(error.message) \(error.statusCode)")
            }
            .disposed(by: disposeBag)
        
        output.postListItem
            .bind(to: tableView.rx.items(cellIdentifier: PostListTableViewCell.description(), cellType: PostListTableViewCell.self)) { (row, element, cell) in
                cell.configureCell(with: element)
            }
            .disposed(by: disposeBag)
    }
}

