//
//  HomeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa

final class PostListViewController: UIViewController {
    
    let mainView = PostListView()
    let viewModel = PostListViewModel()
    var disposeBag = DisposeBag()
    let tableView = UITableView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        view.backgroundColor = .white
        
//        let accessToken = KeyChain.read(key: "accessToken")!
//        let refreshToken = KeyChain.read(key: "refreshToken")!
        
//        print("accessToken: \(accessToken)")
//        print("refreshToken: \(refreshToken)")
        
        bind()
    }
    
    private func bind() {
        let input = PostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.postListItem
            .subscribe(with: self) { owner, result in
                print("postListVC result: \(result)")
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                print("postListVC error: \(error.message) \(error.statusCode)")
            }
            .disposed(by: disposeBag)
        
    }
    
    func apiTest() {
        guard let token = KeyChain.read(key: "accessToken") else { return }
        Network.shared.requestConvertible(
            type: PostListResponse.self,
            router: .postList(accessToken: token, next: nil, limit: nil, product_id: nil)
        ) { response in
            switch response {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
        }
    }
}
