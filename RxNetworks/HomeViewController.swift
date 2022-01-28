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

    private static let identifier = "homeCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel: HomeViewModel = HomeViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 0.00001
        tableView.sectionFooterHeight = 0.00001
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeViewController.identifier)
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
        NetworkConfig.addDebugging = true
        NetworkConfig.addIndicator = true
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.background
        self.view.addSubview(self.tableView)
    }
    
    func setupBinding() {
        
        viewModel.datasObservable.bind(to: tableView.rx.items) { (tableView, row, element) in
            let indexPath = IndexPath(index: row)
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.identifier, for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.defaultTint
            cell.textLabel?.text = "\(row + 1). " + element.rawValue
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            if row % 2 == 0 {
                cell.backgroundColor = UIColor.cell_background?.withAlphaComponent(0.6)
            } else {
                cell.backgroundColor = UIColor.background
            }
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
