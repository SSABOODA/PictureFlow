//
//  OtherUserPostBottomSheetViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/13/23.
//

import UIKit
import RxSwift
import RxCocoa

final class OtherUserPostBottomSheetViewController: BottomSheetViewController {
    let blockButton = {
        let button = UIButton()
        button.setTitle("차단", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor(resource: .postStatusModify)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    let reportButton = {
        let button = UIButton()
        button.setTitle("신고", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor(resource: .postStatusModify)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        bind()
    }
    
    private func configureHierarchy() {
        bottomSheetView.addSubview(blockButton)
        bottomSheetView.addSubview(reportButton)
    }
    
    private func configureLayout() {
        blockButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(blockButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(blockButton.snp.width)
            make.height.equalTo(blockButton.snp.height)
        }
    }
    
    private func bind() {
        blockButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showAlertAction1(message: "추후 업데이트 예정이에요 😀")
            }
            .disposed(by: disposeBag)
            
        reportButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showAlertAction1(message: "추후 업데이트 예정이에요 😀")
            }
            .disposed(by: disposeBag)
    }
}
