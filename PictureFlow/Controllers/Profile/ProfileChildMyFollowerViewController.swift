//
//  ProfileChileMyFollowerViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/16/23.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileChildMyFollowerViewModel: ViewModelType {
    struct Input {}
    
    struct Output {
        let follwersObservable: PublishSubject<[UserInfo]>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    var initTokenObservable = PublishSubject<String>()
    var userProfile: UserProfileRetrieveResponse? = nil
    var follwersObservable = PublishSubject<[UserInfo]>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    
    var isFollow = BehaviorRelay(value: false)
    var userId: String = ""
    
    func transform(input: Input) -> Output {
        
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: UserProfileRetrieveResponse.self,
                    router: .userProfileRetrieve(accessToken: token)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.userProfile = data
                    guard let profile = owner.userProfile else { return }
                    owner.follwersObservable.onNext(profile.followers)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
            
        return Output(
            follwersObservable: follwersObservable,
            errorResponse: errorResponse
        )
    }
    
    func fetchDataSource() {
        let token = self.checkAccessToken()
        initTokenObservable.onNext(token)
    }
}

class ProfileChildMyFollowerView: UIView {
    let emptyLabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "아직 팔로워가 없어요..."
        return label
    }()
    
    let tableView = {
        let view = UITableView()
        view.register(
            ProfileChildMyFollowerListTableViewCell.self,
            forCellReuseIdentifier: ProfileChildMyFollowerListTableViewCell.description()
        )
        view.backgroundColor = UIColor(resource: .background)
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(tableView)
        tableView.addSubview(emptyLabel)
    }
    
    private func configureLayout() {
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}

final class ProfileChildMyFollowerViewController: UIViewController {
    let mainView = ProfileChildMyFollowerView()
    let viewModel = ProfileChildMyFollowerViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchDataSource()
    }
    
    private func bind() {
        
        let input = ProfileChildMyFollowerViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
        
        output.follwersObservable
            .subscribe(with: self) { owner, userInfo in
                owner.mainView.emptyLabel.isHidden = userInfo.isEmpty ? false : true
            }
            .disposed(by: disposeBag)
        
        output.follwersObservable
            .bind(to: mainView.tableView.rx.items(cellIdentifier: ProfileChildMyFollowerListTableViewCell.description(), cellType: ProfileChildMyFollowerListTableViewCell.self)) { (row, element, cell) in
                
                guard let userProfile = self.viewModel.userProfile else { return }
                let followingsIdList = userProfile.following.map { $0._id }
                let isFollowingStatus = followingsIdList.contains(element._id) ? true : false
                cell.configureCell(element: element, isFollowingStatus: isFollowingStatus)
                
                cell.followButton.rx.tap
                    .throttle(.seconds(1), scheduler: MainScheduler.instance)
                    .scan(isFollowingStatus)  { lastState, newState in !lastState }
                    .map { v -> Router in
                        let token = KeyChain.read(key: APIConstants.accessToken) ?? ""
                        return v ? .follow(accessToken: token, userId: element._id) : .unfollow(accessToken: token, userId: element._id)
                    }
                    .flatMap {
                        Network.shared.requestObservableConvertible(
                            type: FollowResponse.self,
                            router: $0
                        )
                    }
                    .subscribe(with: self) { owner, response in
                        switch response {
                        case .success(let data):
                            cell.configureCell(element: element, isFollowingStatus: data.followingStatus)
                        case .failure(let error):
                            owner.showAlertAction1(message: error.message)
                        }
                    }
                    .disposed(by: cell.disposeBag)

            }
            .disposed(by: disposeBag)
        
        viewModel.fetchDataSource()
    }
}
