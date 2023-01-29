//
//  MainViewController.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import UIKit
import SnapKit

protocol MainViewControllerDelegate: AnyObject {
    func updateTitleButton(value: String, key: String)
}

class MainViewController: UIViewController, MainViewControllerDelegate {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        return tableView
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()

    private lazy var overlayActivityView = UIView()
    private lazy var activityIndicatorView = UIActivityIndicatorView()

    private lazy var titleButton = "Выбрать значение..."
    private lazy var tagButton = 0
    private lazy var buffer = ""

    private lazy var numericRegex = "^(([1-9][0-9]{0,2}|10[0-1][0-9]|102[0-3])([.,][0-9])?|1024([.,][0])?)$"
    private lazy var textRegex = "^([а-яё]*|[А-ЯЁ]*|[a-z]*|[A-Z]*|[0-9]*)$"

    private lazy var dataToSend = [String: [String]]()
    private var formConstructor: Form?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ViewBackgroundColor")

        setTableView()
        addSubviewElement()
        setConstraint()
        fetchData()
    }

    private func setNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.overrideUserInterfaceStyle = .unspecified
        let navBarAppearance = UINavigationBarAppearance()
        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = formConstructor?.title
    }

    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.cellIdentifier)
        tableView.register(MainTableFooter.self, forHeaderFooterViewReuseIdentifier: MainTableFooter.identifier)
    }

    private func addSubviewElement() {
        view.addSubview(backgroundImageView)
        view.addSubview(tableView)
    }

    private func setConstraint() {
        backgroundImageView.snp.makeConstraints { maker in
            maker.centerX.centerY.equalToSuperview()
            maker.width.equalTo(200)
            maker.height.equalTo(18)
        }
        tableView.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }
    }

    private func fetchData() {
        let group = DispatchGroup()

        group.enter()
        startActivityView()
        NetworkManager.fetchFormConstructor { [weak self] form, image in
            self?.formConstructor = form
            self?.backgroundImageView.image = image
            group.leave()
        }

        group.notify(queue: .main) {
            self.backgroundImageView.isHidden = false
            self.setNavigationBar()
            self.tableView.reloadData()
            self.stopActivityView()
        }
    }

    private func startActivityView() {
        overlayActivityView.backgroundColor = .gray.withAlphaComponent(0.7)
        overlayActivityView.frame = view.frame
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.color = .white
        activityIndicatorView.center = CGPoint(x: overlayActivityView.bounds.width / 2,
                                               y: overlayActivityView.bounds.height / 2)
        overlayActivityView.addSubview(activityIndicatorView)
        view.addSubview(overlayActivityView)
        activityIndicatorView.startAnimating()
    }

    func stopActivityView() {
        activityIndicatorView.stopAnimating()
        overlayActivityView.removeFromSuperview()
    }

    func updateTitleButton(value: String, key: String) {
        titleButton = value
        if key == "" {
            removeElementInDataToSend(nameField: NameField.list.rawValue)
        } else {
            addElementInDataToSend(value: key, nameField: NameField.list.rawValue)
        }
        let selectedIndexPath = IndexPath(row: tagButton, section: 0)
        tableView.reloadRows(at: [selectedIndexPath], with: .none)
    }

    @objc func showList(sender: UIButton) {
        guard let fields = formConstructor?.fields else { return }

        for element in fields {
            let dictionary = element.values ?? ["": ""]
            for (key, value) in dictionary where value == sender.currentTitle {
                buffer = key
            }
        }

        let list = ListViewController()
        list.delegate = self
        list.fetchDictionary(dictionary: formConstructor?.fields[sender.tag].values ?? ["": ""],
                             text: sender.currentTitle ?? "")
        tagButton = sender.tag

        let navigationController = UINavigationController(rootViewController: list)
        navigationController.modalPresentationStyle = .pageSheet

        if UIDevice.current.orientation.isLandscape {
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = true
            }
        } else {
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = false
            }
        }
        present(navigationController, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let formConstructor = formConstructor else { return 0 }
        return formConstructor.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.cellIdentifier,
                                                       for: indexPath) as? MainTableViewCell else {
            return MainTableViewCell()
        }
        let defaultTitleButton = "Выбрать значение..."

        if let formConstructor = formConstructor?.fields[indexPath.row] {
            cell.dataInCell(field: formConstructor, indexPath: indexPath.row)
            cell.settingTextField().delegate = self
            cell.settingButton().setTitle(titleButton, for: .normal)
            if cell.settingButton().currentTitle != defaultTitleButton {
                cell.settingButton().layer.borderColor = UIColor(named: "Green")?.cgColor
            } else {
                cell.settingButton().layer.borderColor = UIColor(named: "ButtonShowList")?.cgColor
            }
            cell.settingButton().addTarget(self, action: #selector(showList(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MainTableFooter.identifier) as? MainTableFooter

        footer?.settingSendButton().addTarget(self, action: #selector(sendButtonTap), for: .touchUpInside)
        if formConstructor != nil {
            footer?.settingSendButton().isHidden = false
        }
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }

    @objc func sendButtonTap() {
        startActivityView()
        var convertDataToSend: [String: String] = [:]
        for (key, value) in dataToSend {
            var convertValueToString = ""
            for element in value {
                convertValueToString += "\(element) "
            }
            convertDataToSend[key] = convertValueToString
        }

        let resultConvertDataToSend: [String: [String: String]] = ["form": convertDataToSend]
        NetworkManager.sendData(parametrs: resultConvertDataToSend, completion: { [weak self] responseFromServer in
            var responseFromServerString = String()
            for (_, value) in responseFromServer {
                responseFromServerString = value
            }

            let alert = UIAlertController(title: "Ответ с сервера", message: responseFromServerString,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))

            self?.stopActivityView()
            self?.present(alert, animated: true, completion: nil)
        })

    }
}

extension MainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let index = NSIndexPath(row: textField.tag, section: 0)
        if let cell = tableView.cellForRow(at: index as IndexPath)as? MainTableViewCell {
            if cell.infoTypeField() == TypeField.text {
                if string.searchForMatches(regex: textRegex) {
                    textField.layer.borderColor = UIColor(named: "Green")?.cgColor
                } else {
                    textField.layer.borderColor = UIColor.red.cgColor
                }
            }
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        buffer = textField.text ?? ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = NSIndexPath(row: textField.tag, section: 0)
        if let cell = tableView.cellForRow(at: index as IndexPath)as? MainTableViewCell {
            guard let text = textField.text else { return }
            if cell.infoTypeField() == TypeField.numeric {
                if text.searchForMatches(regex: numericRegex) {
                    textField.layer.borderColor = UIColor(named: "Green")?.cgColor

                    if text.firstIndex(of: ".") == nil {
                        textField.text? += ".0"
                    }

                    if text.firstIndex(of: ",") != nil {
                        textField.text = replacingCommaWithDot(text: text)
                    }

                    addElementInDataToSend(value: textField.text ?? "", nameField: NameField.numeric.rawValue)
                } else {
                    textField.layer.borderColor = UIColor.red.cgColor
                    removeElementInDataToSend(nameField: NameField.numeric.rawValue)
                }
                if text.isEmpty {
                    textField.layer.borderColor = UIColor.black.cgColor
                }
            } else if cell.infoTypeField() == TypeField.text {
                if text.isEmpty {
                    textField.layer.borderColor = UIColor.black.cgColor
                }

                if textField.layer.borderColor == UIColor(named: "Green")?.cgColor {
                    addElementInDataToSend(value: text, nameField: NameField.text.rawValue)
                } else {
                    removeElementInDataToSend(nameField: NameField.text.rawValue)
                }
            }
        }
        print(dataToSend)
    }

    private func addElementInDataToSend(value: String, nameField: String) {
        if let data = dataToSend[nameField] {
            if let index = data.firstIndex(of: buffer) {
                var bufferData = data
                bufferData[index] = value
                dataToSend.updateValue(bufferData, forKey: nameField)
            } else {
                let buffer = data + [value]
                dataToSend.updateValue(buffer, forKey: nameField)
            }
        } else {
            dataToSend.updateValue([value], forKey: nameField)
        }
    }

    private func removeElementInDataToSend(nameField: String) {
        guard let data = dataToSend[nameField] else { return }

        if data.count >= 1 {
            if let index = data.firstIndex(of: buffer) {
                var bufferData = data
                bufferData.remove(at: index)
                if bufferData.isEmpty {
                    dataToSend = dataToSend.filter { $0.key != nameField }
                } else {
                    dataToSend.updateValue(bufferData, forKey: nameField)
                }
            }
        }
    }

    private func replacingCommaWithDot(text: String) -> String {
        var result = String()
        for char in text {
            if char == "," {
                result += "."
            } else {
                result += "\(char)"
            }
        }
        return result
    }
}

extension String {
    func searchForMatches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
