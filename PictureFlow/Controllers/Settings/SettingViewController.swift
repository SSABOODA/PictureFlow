//
//  SettingViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController {
    let mainView = SettingView()
    let viewModel = SettingViewModel()
    let disposeBag = DisposeBag()
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bind()
    }
    
    private func bind() {
        let input = SettingViewModel.Input()
        let output = viewModel.transform(input: input)
        output.settingItemListObservable
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: SettingTableViewCell.description(),
                cellType: SettingTableViewCell.self)) { row, element, cell  in
                    cell.configureCell(element: element)
                }
                .disposed(by: disposeBag)
        
        
        Observable.zip(
            mainView.tableView.rx.itemSelected,
            mainView.tableView.rx.modelSelected(SettingItem.self)
        )
        .subscribe(with: self) { owner, value in
            print("cell clicked")
            print(value.0, value.1)
            
            let row = value.0.row
            if 0...5 ~= row {
                owner.showAlertAction1(message: "추후 업데이트 예정입니다")
            } else if row == 6 { // 로그아웃
                owner.showAlertAction2(message: "로그아웃을 하시겠습니까?",  {
                    print("취소")
                }, {
                    print("로그아웃 gogo")
                    owner.removeUserInfo()
                    owner.changeRootViewController(
                        viewController: SignInViewController(),
                        isNav: false
                    )
                    
                })
            } else { // 회원 탈퇴
                owner.showAlertAction2(message: "정말 회원탈퇴를 하시겠습니까? 회원 탈퇴 시 모든 정보는 삭제되며 복구할 수 없습니다.",  {
                    print("취소")
                }, {
                    print("회원탈퇴 gogo")
                    owner.viewModel.isWithdraw.onNext(true)
                })
            }
        }
        .disposed(by: disposeBag)
        
        output.withdrawUserInfo
            .subscribe(with: self) { owner, withdrawUserInfo in
                owner.removeUserInfo()
                owner.changeRootViewController(
                    viewController: SignInViewController(),
                    isNav: false
                )
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
        
        viewModel.settingItemListObservable.onNext(viewModel.settingItemList)
    }
}

extension SettingViewController {
    private func configureNavigationBar() {
        navigationItem.title = "설정"
        self.setNavigationBarBackButtonItem(
            title: nil,
            color: UIColor(resource: .tint)
        )
    }
}
