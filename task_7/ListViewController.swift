//
//  ListViewController.swift
//  task_7
//
//  Created by Artem Sulzhenko on 26.01.2023.
//

import UIKit

class ListViewController: UIViewController {

    let table = UITableView()
    var values = [String: String]()
    var keysArray = [String]()
    var delegate: MainViewControllerDelegate?
    private lazy var resetButton = UIBarButtonItem(title: "Сбросить", style: .plain, target: self,
                                                     action: #selector(resetButtonTapped))
    var text = String()
    var index = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let navigationBar = navigationController?.navigationBar
        navigationBar?.overrideUserInterfaceStyle = .unspecified
        let navBarAppearance = UINavigationBarAppearance()
        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Выберите значение"
        navigationItem.rightBarButtonItem = resetButton

        table.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.cellIdentifier)
        table.dataSource = self
        table.delegate = self
        view.addSubview(table)

        table.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }

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

    func fetchDictionary(dictionary: [String: String], text: String) {
        values = dictionary
        self.text = text
        table.reloadData()
    }

    @objc func resetButtonTapped() {
        var titleButton = "Выбрать значение..."
        delegate?.updateTitleButton(value: titleButton, key: "")
        table.deselectRow(at: index, animated: false)
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
        cell.label.text = values[currentKey]
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
