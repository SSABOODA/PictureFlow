//
//  ProfileChileMyPostListView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import UIKit

final class ProfileChileMyPostListEmptyView: UIView {
    let firstStartButton = {
        let button = UIButton()
        button.setTitle("  첫 이야기를 시작해보세요...  ", for: .normal)
        button.backgroundColor = UIColor(resource: .background)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .tint).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        addSubview(firstStartButton)
    }
    func configureLayout() {
        firstStartButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(35)
        }
    }
}

final class ProfileChileMyPostListView: UIView {
    let tableView = {
        let view = UITableView()
        view.register(
            ProfileChileMyPostListTableViewCell.self,
            forCellReuseIdentifier: ProfileChileMyPostListTableViewCell.description()
        )
        view.backgroundColor = .orange
        view.rowHeight = 80
//        view.separatorStyle = .none
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        addSubview(tableView)
    }
    
    func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    
}
