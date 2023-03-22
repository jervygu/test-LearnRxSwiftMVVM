//
//  ViewController.swift
//  LearnRxSwiftMVVM
//
//  Created by Jeff Umandap on 3/22/23.
//

import UIKit
import RxSwift
import RxCocoa

// part 1 - https://www.youtube.com/watch?v=dnmQ3X8o6Fs

class ViewController: UIViewController, UIScrollViewDelegate {
    
    private var viewModel = ViewModel()
    
    private let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.frame, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        
        viewModel.fetchUsers()
        bindTableView()
        
    }
    
    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.users.bind(to: tableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = "\(item.id)"
            cell.detailTextLabel?.text = item.name
        }.disposed(by: disposeBag)
    }


}

extension ViewController: UITableViewDelegate {
    
}


class ViewModel {
    var users = BehaviorSubject(value: [User]())
    
    func fetchUsers() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode([User].self, from: data)
                self.users.on(.next(responseData))
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}





// MARK: - UserElement
struct User: Codable {
    let id: Int
    let name, username, email: String
    let address: Address
    let phone, website: String
    let company: Company
}

// MARK: - Address
struct Address: Codable {
    let street, suite, city, zipcode: String
    let geo: Geo
}

// MARK: - Geo
struct Geo: Codable {
    let lat, lng: String
}

// MARK: - Company
struct Company: Codable {
    let name, catchPhrase, bs: String
}


// MARK: - Post
struct Post: Codable {
    let userID, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }
}
