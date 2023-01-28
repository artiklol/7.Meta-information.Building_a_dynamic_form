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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let navigationBar = navigationController?.navigationBar
        navigationBar?.overrideUserInterfaceStyle = .unspecified
        let navBarAppearance = UINavigationBarAppearance()
        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Выберите значение"

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

    func fetchDictionary(dictionary: [String: String]) {
        values = dictionary
        table.reloadData()
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

        return cell
    }

}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentKey = keysArray[indexPath.row]
        delegate?.updateTitleButton(value: values[currentKey] ?? "", key: keysArray[indexPath.row])
        dismiss(animated: true)
    }
}
