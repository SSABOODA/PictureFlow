//
//  SettingView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit

final class SettingView: UIView {
    let tableView = {
        let view = UITableView()
        view.register(
            SettingTableViewCell.self, 
            forCellReuseIdentifier: SettingTableViewCell.description()
        )
        view.estimatedRowHeight = UITableView.automaticDimension
        view.backgroundColor = UIColor(resource: .background)
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
            make.edges.equalToSuperview()
        }
    }
}

