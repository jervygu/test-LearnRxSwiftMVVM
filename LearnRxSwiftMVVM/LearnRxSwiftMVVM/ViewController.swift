//
//  ViewController.swift
//  LearnRxSwiftMVVM
//
//  Created by Jeff Umandap on 3/22/23.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UIScrollViewDelegate {
    
    private var viewModel = ViewModel()
    
    private let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.frame, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        
        viewModel.fetchPosts()
        bindTableView()
        
    }
    
    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.posts.bind(to: tableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = "\(item.id)"
            cell.detailTextLabel?.text = item.title
        }.disposed(by: disposeBag)
    }


}

extension ViewController: UITableViewDelegate {
    
}


class ViewModel {
    var posts = BehaviorSubject(value: [Post]())
    
    func fetchPosts() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode([Post].self, from: data)
                self.posts.on(.next(responseData))
                
                print("responseData: \(responseData)")
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
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
