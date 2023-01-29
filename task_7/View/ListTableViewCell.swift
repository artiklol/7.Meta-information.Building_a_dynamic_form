//
//  ListTableViewCell.swift
//  task_7
//
//  Created by Artem Sulzhenko on 27.01.2023.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    static let cellIdentifier = "list"

    private lazy var label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        addSubviewElement()
        setConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviewElement() {
        contentView.addSubview(label)
    }

    private func setConstraint() {
        label.snp.makeConstraints { maker in
            maker.centerX.centerY.equalTo(contentView)
        }
    }

    func settingLabel() -> UILabel {
        return label
    }

}
