//
//  MainTableFooter.swift
//  task_7
//
//  Created by Artem Sulzhenko on 28.01.2023.
//

import UIKit

class MainTableFooter: UITableViewHeaderFooterView {
    static let identifier = "MainTableFooter"

    let sendButton = UIButton()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(sendButton)

        sendButton.backgroundColor = .black
        sendButton.layer.cornerRadius = 10
        sendButton.setTitle("Отправить", for: .normal)

        sendButton.snp.makeConstraints { maker in
            maker.centerX.centerY.equalTo(contentView)
            maker.height.equalTo(40)
            maker.width.equalTo(200)

        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
