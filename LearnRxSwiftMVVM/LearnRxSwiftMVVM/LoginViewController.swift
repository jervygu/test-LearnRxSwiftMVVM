//
//  LoginViewController.swift
//  LearnRxSwiftMVVM
//
//  Created by Jeff Umandap on 3/23/23.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter email"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.white.withAlphaComponent(0.3), for: .highlighted)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        btn.backgroundColor = .systemBlue
        return btn
    }()
    
    var disposeBag = DisposeBag()
    
    private let loginViewModel = LoginViewModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createObservables()
    }
    
    private func createObservables() {
        emailTextField.rx.text.map({ $0 ?? "" }).bind(to: loginViewModel.email).disposed(by: disposeBag)
        passwordTextField.rx.text.map({ $0 ?? "" }).bind(to: loginViewModel.password).disposed(by: disposeBag)
        
        loginViewModel.isValidInput.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        loginViewModel.isValidInput.subscribe { [weak self] isValid in
            guard let self = self else { return }
            self.loginButton.backgroundColor = isValid ? .systemBlue : .systemRed
        }.disposed(by: disposeBag)

    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        
        // setup constraint
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 20),
            
            loginButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalTo: self.passwordTextField.widthAnchor),
            loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
        ])
    }
    
    @objc func didTapLogin() {
        
    }
    
    
}


class LoginViewModel {
    var email: BehaviorSubject<String> = BehaviorSubject(value: "")
    var password: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    var isValidEmail: Observable<Bool> {
        email.map { $0.isValidEmail() }
    }
    
    var isValidPassword: Observable<Bool> {
//        password.map { $0.count >= 8 }
        
        password.map { pw in
            return pw.count >= 8 ? true : false
        }
    }
    
    var isValidInput: Observable<Bool> {
        return Observable.combineLatest(isValidEmail, isValidPassword).map({ $0 && $1 })
    }
    
    
}

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
