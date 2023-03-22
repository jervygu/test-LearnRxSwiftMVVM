//
//  ViewController.swift
//  LearnRxSwiftMVVM
//
//  Created by Jeff Umandap on 3/22/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

// part 1 - https://www.youtube.com/watch?v=dnmQ3X8o6Fs
// part 4 - https://www.youtube.com/watch?v=IbRM3t5QUxk

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
        
        // old binding
//        viewModel.users.bind(to: tableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { row, item, cell in
//            cell.textLabel?.text = "\(item.id)"
//            cell.detailTextLabel?.text = item.name
//        }.disposed(by: disposeBag)
//
//        tableView.rx.itemSelected.subscribe { indexPath in
//            let alert = UIAlertController(title: "Note", message: "Edit User", preferredStyle: .alert)
//            alert.addTextField { textField in
//
//            }
//            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
//                let textField = (alert.textFields?[0])! as UITextField
//                print(textField.text)
//
//                self.viewModel.updateUser(index: indexPath.row, name: textField.text ?? "-")
//
//
//            }))
//
//            DispatchQueue.main.async {
//                self.present(alert, animated: true)
//            }
//
//        }.disposed(by: disposeBag)
//
//        tableView.rx.itemDeleted.subscribe { [weak self] indexPath in
//            guard let self = self else { return }
//            self.viewModel.deleteUser(index: indexPath.row)
//        }.disposed(by: disposeBag)
        
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>> { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
            
            cell.textLabel?.text = "\(item.id)"
            cell.detailTextLabel?.text = item.name
            
            return cell
        } titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }

        self.viewModel.users.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe { [weak self] indexPath in
            guard let self = self else { return }
            self.viewModel.deleteUser(indexPath: indexPath)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe { indexPath in
            let alert = UIAlertController(title: "Note", message: "Edit User", preferredStyle: .alert)
            alert.addTextField { textField in
                
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                let textField = (alert.textFields?[0])! as UITextField
                self.viewModel.updateUser(indexPath: indexPath, name: textField.text ?? "-")
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            
        }.disposed(by: disposeBag)
        
        

    }


}

extension ViewController: UITableViewDelegate {
    
}


class ViewModel {
//    var users = BehaviorSubject(value: [User]())
    var users = BehaviorSubject(value: [SectionModel(model: "", items: [User]())])
    
    func fetchUsers() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode([User].self, from: data)
//                self.users.on(.next(responseData))
                let sectionUser = SectionModel(model: "First", items: [User(id: 0, name: "Jervy")])
                
                let secondSection = SectionModel(model: "Second", items: responseData)
                self.users.on(.next([sectionUser, secondSection]))
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func addUser(user: User) {
//        guard var users = try? users.value() else { return }
        guard var sections = try? users.value() else { return }
        
        var currentSection = sections[0]
        currentSection.items.append(user)
        
        sections[0] = currentSection
        self.users.onNext(sections)
        
//        users.insert(user, at: users.count)
//        self.users.on(.next(users))
        
    }
    
    func updateUser(index: Int, name: String) {
        guard var users = try? users.value() else { return }
        
//        users[index].name = name
//        self.users.on(.next(users))
    }
    
    func updateUser(indexPath: IndexPath, name: String) {
        guard var sections = try? users.value() else { return }
        
        var currentSection = sections[indexPath.section]
        currentSection.items[indexPath.row].name = name
        sections[indexPath.section] = currentSection
        self.users.onNext(sections)
    }
    
    func deleteUser(index: Int) {
        guard var users = try? users.value() else { return }
        
//        users.remove(at: index)
//        self.users.on(.next(users))
        
    }
    
    func deleteUser(indexPath: IndexPath) {
        guard var sections = try? users.value() else { return }
        
        var currentSection = sections[indexPath.section]
        currentSection.items.remove(at: indexPath.row)
        sections[indexPath.section] = currentSection
        self.users.onNext(sections)
        
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
