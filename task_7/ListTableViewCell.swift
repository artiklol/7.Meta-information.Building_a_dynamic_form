//
//  ListTableViewCell.swift
//  task_7
//
//  Created by Artem Sulzhenko on 27.01.2023.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    static let cellIdentifier = "list"

    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)

        label.snp.makeConstraints { maker in
            maker.centerX.centerY.equalTo(contentView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
