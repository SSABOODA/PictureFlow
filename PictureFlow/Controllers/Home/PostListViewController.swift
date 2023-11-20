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

struct SectionModel {
    var header: String
    var items: [String]
}

extension SectionModel: SectionModelType {
    init(original: SectionModel, items: [String]) {
        self = original
        self.items = items
    }
}


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
        view.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.description())
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, PostListViewController.description())
        configureHierarchy()
        navigationItem.title = "FLOW"
//        let accessToken = KeyChain.read(key: "accessToken")!
//        let refreshToken = KeyChain.read(key: "refreshToken")!
//        print("accessToken: \(accessToken)")
//        print("refreshToken: \(refreshToken)")
//        apiTest()
        bind()
        
        
//        let sections: [SectionModel] = [
//            SectionModel(header: "Section 1", items: ["Item 1", "Item 2", "Item 3"]),
//            SectionModel(header: "Section 2", items: ["Item 4", "Item 5", "Item 6"])
//        ]
        
//        let dataSource = createTableViewDataSource()
        
        // TableView에 바인딩
//        Observable.just(sections)
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        
//        let data: [DataList] = [
//            DataList(name: "1", content: "123"),
//            DataList(name: "2", content: "456"),
//            DataList(name: "3", content: "789"),
//        ]
//        
//        let items = BehaviorSubject(value: data)
//    
//        items
//            .bind(to: tableView.rx.items(cellIdentifier: PostListTableViewCell.description(), cellType: PostListTableViewCell.self)) { (row, element, cell) in
////                cell.label.text = element.name
//            }
//            .disposed(by: disposeBag)

    }
    
    private func configureHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
//    private func createTableViewDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel> {
//        return RxTableViewSectionedReloadDataSource<SectionModel>(
//            configureCell: { (_, tableView, indexPath, sectionItem) in
//                print("RxTableViewSectionedReloadDataSource")
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.description(), for: indexPath) as! PostListTableViewCell
//                cell.configure(with: [sectionItem])
//                return cell
//            }
////            titleForHeaderInSection: { dataSource, sectionIndex in
////                return dataSource[sectionIndex].header
////            }
//        )
//    }
    
    private func bind() {
        let input = PostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.postListItem
            .subscribe(with: self) { owner, result in
                print("postListVC result: \(result)")
                dump(result)
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                print("postListVC error: \(error.message) \(error.statusCode)")
            }
            .disposed(by: disposeBag)
        
        output.postListItem
            .bind(to: tableView.rx.items(cellIdentifier: PostListTableViewCell.description(), cellType: PostListTableViewCell.self)) { (row, element, cell) in
                
                cell.nicknameLabel.text = element.creator.nick
                cell.contentLabel.text = element.content
            }
            .disposed(by: disposeBag)
        
        
    }
    private func apiTest() {
//        guard let token = KeyChain.read(key: "accessToken") else { return }
//        Network.shared.requestConvertible(
//            type: PostListResponse.self,
//            router: .postList(accessToken: token)
//        ) { response in
//            switch response {
//            case .success(let success):
//                print("apiTest")
//                dump(success)
//            case .failure(let error):
//                print("apiTest", error)
//            }
//        }
    }
}




