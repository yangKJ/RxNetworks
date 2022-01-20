//
//  HomeViewController.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxNetworks

class HomeViewController: UIViewController {

    private static let homeCellIdentifier = "homeCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel: HomeViewModel = HomeViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 0.00001
        tableView.sectionFooterHeight = 0.00001
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeViewController.homeCellIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupDefault()
        self.setupUI()
        self.setupBinding()
    }
    
    func setupDefault() {
        NetworkConfig.setupDefault(
            host: "https://www.httpbin.org",
            parameters: ["key": "RxNetworks"]
        )
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
    }
    
    func setupBinding() {
        
        viewModel.datasObservable.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = UITableViewCell(style: .value1, reuseIdentifier: HomeViewController.homeCellIdentifier)
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = UIColor.blue
            cell.textLabel?.text = "\(row + 1). " + element.rawValue
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.detailTextLabel?.textColor = UIColor.blue.withAlphaComponent(0.5)
            cell.detailTextLabel?.text = element.title
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
            return cell
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ViewControllerType.self).subscribe (onNext: { type in
            let vc: UIViewController = type.viewController
            vc.title = type.rawValue
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
}
