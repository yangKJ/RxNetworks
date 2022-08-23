//
//  HomeViewController.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks

class HomeViewController: UIViewController {

    private static let identifier = "homeCellIdentifier"
    private var viewModel: HomeViewModel = HomeViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0.00001
        tableView.sectionFooterHeight = 0.00001
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = view.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeViewController.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupDefault()
        self.setupUI()
    }
    
    func setupDefault() {
        NetworkConfig.baseURL = "https://www.httpbin.org"
        NetworkConfig.baseParameters = ["key": "RxNetworks"]
        NetworkConfig.addDebugging = true
        NetworkConfig.addIndicator = true
        NetworkConfig.injectionPlugins = [AuthPlugin.shared]
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.background
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element: ViewControllerType = self.viewModel.datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.identifier, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.textColor = UIColor.defaultTint
        cell.textLabel?.text = "\(indexPath.row + 1). " + element.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.cell_background?.withAlphaComponent(0.6)
        } else {
            cell.backgroundColor = UIColor.background
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = self.viewModel.datas[indexPath.row]
        let vc: UIViewController = type.viewController()
        vc.title = type.rawValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
