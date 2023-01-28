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

    private lazy var table = UITableView()
    private var formConstructor: Form?
    private lazy var overlayActivityView = UIView()
    private lazy var activityIndicatorView = UIActivityIndicatorView()
    private lazy var titleButton = "Выбрать значение..."
    private lazy var dataToSend = [String: [String]]()
    private lazy var tag = 0
    private lazy var buffer = ""
    private lazy var refreshButton = UIBarButtonItem(title: "Обновить", style: .plain, target: self,
                                                     action: #selector(refreshButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        fetchData()
    }

    private func setNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.overrideUserInterfaceStyle = .unspecified
        let navBarAppearance = UINavigationBarAppearance()
        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = formConstructor?.title
        navigationItem.rightBarButtonItem = refreshButton
    }

    private func setTableView() {
        table.dataSource = self
        table.delegate = self
        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.cellIdentifier)
        table.register(MainTableFooter.self, forHeaderFooterViewReuseIdentifier: MainTableFooter.identifier)

        view.addSubview(table)

        table.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }
    }

    private func fetchData() {
        let group = DispatchGroup()

        group.enter()
        startActivityView()
        NetworkManager.fetchFormConstructor { form in
            self.formConstructor = form
            group.leave()
        }

        group.notify(queue: .main) {
            self.setNavigationBar()
            self.table.reloadData()
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
        addElementInDataToSend(value: key, nameField: NameField.list.rawValue)
        let selectedIndexPath = IndexPath(row: tag, section: 0)
        table.reloadRows(at: [selectedIndexPath], with: .none)
     }

    @objc func refreshButtonTapped() {
        print(dataToSend)
        print(dataToSend.count)
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
        list.fetchDictionary(dictionary: formConstructor?.fields[sender.tag].values ?? ["": ""])
        tag = sender.tag

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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let formConstructor = formConstructor else { return 0 }
        return formConstructor.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.cellIdentifier,
                                                       for: indexPath) as? MainTableViewCell else {
            return MainTableViewCell()
        }

        if let formConstructor = formConstructor?.fields[indexPath.row] {
            cell.dataInCell(field: formConstructor)
            cell.button.tag = indexPath.row
            cell.textField.tag = indexPath.row
            cell.textField.delegate = self
            cell.button.setTitle(titleButton, for: .normal)
            cell.button.addTarget(self, action: #selector(showList(sender:)), for: .touchUpInside)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: MainTableFooter.identifier)
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }

}

extension MainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let index = NSIndexPath(row: textField.tag, section: 0)
        if let cell = table.cellForRow(at: index as IndexPath)as? MainTableViewCell {
            if cell.typeField == TypeField.text {
                if string.searchForMatches(regex: cell.textRegex) {
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
        if let cell = table.cellForRow(at: index as IndexPath)as? MainTableViewCell {
            guard let text = cell.textField.text else { return }

            if cell.typeField == TypeField.numeric {
                if text.searchForMatches(regex: cell.numericRegex) {
                    textField.layer.borderColor = UIColor(named: "Green")?.cgColor
                    addElementInDataToSend(value: text, nameField: NameField.numeric.rawValue)
                } else {
                    textField.layer.borderColor = UIColor.red.cgColor
                    removeElementInDataToSend(nameField: NameField.numeric.rawValue)
                }
            } else if cell.typeField == TypeField.text {
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
}
