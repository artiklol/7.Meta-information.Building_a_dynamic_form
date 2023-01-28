//
//  MainTableViewCell.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    static let cellIdentifier = "mainCell"

    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.isUserInteractionEnabled = true
        textField.textAlignment = .center
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        return textField
    }()

    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.backgroundColor = .gray
        return button
    }()

    let numericRegex = "^(([1-9][0-9]{0,2}|10[0-1][0-9]|102[0-3])([.][0-9]{1,2})?|1024([.][0]{1,2})?)$"
    let textRegex = "^([а-яё]*|[А-ЯЁ]*|[a-z]*|[A-Z]*|[0-9]*)$"

    var typeField = TypeField.text

    func dataInCell(field: Field) {
        typeField = field.type
        label.text = field.title

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

extension String {
    func searchForMatches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
