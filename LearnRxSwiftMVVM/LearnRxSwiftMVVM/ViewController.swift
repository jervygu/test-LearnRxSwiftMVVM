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
        
        self.title = "Users"
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(onTapAdd))
        self.navigationItem.rightBarButtonItem = addButton
        self.view.addSubview(tableView)
        
        viewModel.fetchUsers()
        
        bindTableView()
        
        // add navigation controller
        
        
    }
    
    @objc func onTapAdd() {
        guard var users = try? self.viewModel.users.value() else { return }
        
        
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            let textField = (alert.textFields?[0])! as UITextField
            let userToAdd = User(id: users.count+1, name: textField.text ?? "-")
            self.viewModel.addUser(user: userToAdd)
            
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    
    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.users.bind(to: tableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = "\(item.id)"
            cell.detailTextLabel?.text = item.name
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe { indexPath in
            let alert = UIAlertController(title: "Note", message: "Edit User", preferredStyle: .alert)
            alert.addTextField { textField in
                
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                let textField = (alert.textFields?[0])! as UITextField
                print(textField.text)
                
                self.viewModel.updateUser(index: indexPath.row, name: textField.text ?? "-")
                
                
            }))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            
        }.disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe { [weak self] indexPath in
            guard let self = self else { return }
            self.viewModel.deleteUser(index: indexPath.row)
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
    
    func addUser(user: User) {
        guard var users = try? users.value() else { return }
        
        users.insert(user, at: users.count)
        self.users.on(.next(users))
        
    }
    
    func updateUser(index: Int, name: String) {
        guard var users = try? users.value() else { return }
        
        users[index].name = name
        self.users.on(.next(users))
    }
    
    func deleteUser(index: Int) {
        guard var users = try? users.value() else { return }
        
        users.remove(at: index)
        self.users.on(.next(users))
        
    }
    
}





// MARK: - UserElement
struct User: Codable {
    let id: Int
    var name: String
//    let username: String
//    let email: String
//    let address: Address
//    let phone, website: String
//    let company: Company
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
