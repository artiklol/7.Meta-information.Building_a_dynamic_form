//
//  ListViewController.swift
//  task_7
//
//  Created by Artem Sulzhenko on 26.01.2023.
//

import UIKit

class ListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset = .zero
        return tableView
    }()

    private lazy var values = [String: String]()
    private lazy var keysArray = [String]()
    private lazy var text = String()
    private lazy var index = IndexPath()

    var delegate: MainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setTableView()
        addSubviewElement()
        setConstraint()

        keysArray = Array(values.keys)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = true
            }
        } else {
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = false
            }
        }
    }

    private func setNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.overrideUserInterfaceStyle = .unspecified
        let navBarAppearance = UINavigationBarAppearance()
        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Выберите значение"
        let resetButton = UIBarButtonItem(title: "Сбросить", style: .plain, target: self,
                                                         action: #selector(resetButtonTapped))
        navigationItem.rightBarButtonItem = resetButton
    }

    private func setTableView() {
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func addSubviewElement() {
        view.addSubview(tableView)
    }

    private func setConstraint() {
        tableView.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }
    }

    func fetchDictionary(dictionary: [String: String], text: String) {
        values = dictionary
        self.text = text
        tableView.reloadData()
    }

    @objc func resetButtonTapped() {
        let defaultTitleButton = "Выбрать значение..."
        delegate?.updateTitleButton(value: defaultTitleButton, key: "")
        tableView.deselectRow(at: index, animated: false)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        values.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.cellIdentifier,
                                                       for: indexPath) as? ListTableViewCell else {
            return ListTableViewCell()
        }

        let currentKey = keysArray[indexPath.row]
        cell.settingLabel().text = values[currentKey]
        if values[currentKey] == text {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            index = indexPath
        }

        return cell
    }

}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentKey = keysArray[indexPath.row]
        delegate?.updateTitleButton(value: values[currentKey] ?? "", key: keysArray[indexPath.row])
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        dismiss(animated: true)
    }
}
