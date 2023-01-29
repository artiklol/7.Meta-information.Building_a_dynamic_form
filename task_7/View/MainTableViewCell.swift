//
//  MainTableViewCell.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    static let cellIdentifier = "mainCell"

    private lazy var  label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(named: "BlackWhite")
        return label
    }()

    private lazy var  textField: UITextField = {
        let textField = UITextField()
        textField.isUserInteractionEnabled = true
        textField.textAlignment = .center
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        return textField
    }()

    private lazy var  button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "ButtonShowList")?.cgColor
        button.backgroundColor = UIColor(named: "ButtonShowList")
        button.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        return button
    }()

    private lazy var typeField = TypeField.text

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = UIColor(named: "ViewBackgroundColor")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dataInCell(field: Field, indexPath: Int) {
        typeField = field.type
        label.text = field.title

        button.tag = indexPath
        textField.tag = indexPath

        if field.type == TypeField.text {
            setupKeyboard(textField: textField, keyboardType: .namePhonePad)
            addSubviewElement(textField: textField, button: nil)
            setConstraint(textField: textField, button: nil)
        } else if field.type == TypeField.numeric {
            setupKeyboard(textField: textField, keyboardType: .decimalPad)
            addSubviewElement(textField: textField, button: nil)
            setConstraint(textField: textField, button: nil)
        } else if field.type == TypeField.list {
            addSubviewElement(textField: nil, button: button)
            setConstraint(textField: nil, button: button)
        }
    }

    func settingButton() -> UIButton {
        return button
    }

    func settingTextField() -> UITextField {
        return textField
    }

    func infoTypeField() -> TypeField {
        return typeField
    }

    private func addSubviewElement(textField: UITextField?, button: UIButton?) {
        contentView.addSubview(label)

        if let textField = textField {
            contentView.addSubview(textField)
        }

        if let button = button {
            contentView.addSubview(button)
        }
    }

    private func setConstraint(textField: UITextField?, button: UIButton?) {
        label.snp.makeConstraints { maker in
            maker.left.equalTo(contentView).inset(10)
            maker.centerY.equalTo(contentView)
            maker.width.equalTo(170)
        }

        textField?.snp.makeConstraints { maker in
            maker.right.equalTo(contentView).inset(10)
            maker.centerY.equalTo(contentView)
            maker.width.equalTo(150)
            maker.height.equalTo(30)
        }

        button?.snp.makeConstraints { maker in
            maker.right.equalTo(contentView).inset(10)
            maker.centerY.equalTo(contentView)
            maker.width.equalTo(150)
            maker.height.equalTo(30)
        }
    }

}

extension MainTableViewCell {
    private func setupKeyboard(textField: UITextField, keyboardType: UIKeyboardType) {
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no

        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Готово", style: .plain, target: self,
                                   action: #selector(donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        bar.items = [flexibleSpace, done]
        bar.sizeToFit()

        textField.inputAccessoryView = bar
    }

    @objc private func donePressed() {
        contentView.endEditing(true)
    }
}
