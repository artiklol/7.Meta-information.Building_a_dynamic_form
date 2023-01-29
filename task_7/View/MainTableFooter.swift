//
//  MainTableFooter.swift
//  task_7
//
//  Created by Artem Sulzhenko on 28.01.2023.
//

import UIKit

class MainTableFooter: UITableViewHeaderFooterView {

    static let identifier = "MainTableFooter"

    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.setTitle("Отправить", for: .normal)
        button.isHidden = true
        return button
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        addSubviewElement()
        setConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func settingSendButton() -> UIButton {
        return sendButton
    }

    private func addSubviewElement() {
        contentView.addSubview(sendButton)
    }

    private func setConstraint() {
        sendButton.snp.makeConstraints { maker in
            maker.centerX.centerY.equalTo(contentView)
            maker.width.equalTo(180)
            maker.height.equalTo(35)
        }
    }

}
