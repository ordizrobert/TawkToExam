//
//  UsersView.swift
//  TawkTo
//
//  Created by robert ordiz on 7/5/20.
//  Copyright © 2020 robert ordiz. All rights reserved.
//

import Foundation
import UIKit

protocol UsersViewDelegate: class {
    func didSelectUser(_ sender: UsersView, model: UsersModel)
}

class UsersView: UIView {
    weak var delegate: UsersViewDelegate?
    private var tableView: UITableView = UITableView()
    private var since: Int! = 0
    private var users: [UsersModel] = [] {
        didSet {
            let jsonData = try? JSONEncoder().encode(users)
            AppCommonHandler().updateUserData(updatedData: jsonData, key: "user")
        }
    }
    private var tableUsers: [UsersModel] = []
    private var isRequestingForNextPage: Bool = true
    var searchText: String! = nil {
        didSet {
            if searchText.count > 0 {
                search(text: searchText)
            } else {
                tableUsers = users
                tableView.reloadData()
            }
        }
    }
    
    var userChangeNotes: UsersModel? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = true
        tableView.alwaysBounceVertical = true
        tableView.separatorColor = .lightGray
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsMultipleSelection = false
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellReuseID())
        self.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        requestUsers()
    }
    
    func requestUsers() {
        if Reachability.isConnectedToNetwork() {
            UserRequestHandler().getUsers(since: since) { (usersResponse) in
                self.users.append(contentsOf: usersResponse)
                self.tableUsers = self.users
                self.tableView.reloadData()
            }
        } else {
            if let data = AppCommonHandler().fetchUsersData()[0].value(forKey: "user") as? Data {
                let convertedData = try? JSONDecoder().decode([UsersModel].self, from: data)
                self.users = convertedData!
                self.tableUsers = self.users
            }
//            let checkListData: Data? = VCControllerStateManager.instance.getString()!.data(using: .utf8)
//            let convertedConfirmChecklistData = try? JSONDecoder().decode(VCSaveConfirmChecklistCodableModel.self, from: checkListData!)
        }
    }
    
    func search(text: String) {
        let searchUsers = self.users.filter({
            $0.login!.range(of: text, options: .caseInsensitive) != nil
        })
        
        if searchUsers.count > 0 {
            tableUsers = searchUsers
            tableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UsersView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserTableViewCell = (tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellReuseID(), for: indexPath) as? UserTableViewCell)!
        cell.tag = indexPath.row
        cell.user = tableUsers[indexPath.row]
        
//        let index = indexPath.row + 1
//        if index % 4 == 0 {
//            cell.userProfileImage.image = cell.userProfileImage.image?.invertedImage()
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Reachability.isConnectedToNetwork() {
            delegate?.didSelectUser(self, model: tableUsers[indexPath.row])
        } else {
            AppCommonHandler().topViewController().showSimpleAlert(withTitle: "Message", withMessage: "Please check internet connection.", withOKButtonTitle: "OK")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if Reachability.isConnectedToNetwork() {
            if self.tableView.visibleCells.count > 0 {
                let visibleRows = tableView.visibleCells
                let lastVisibleCell = visibleRows.last
                let path = tableView.indexPath(for: lastVisibleCell!)
                if path!.row == users.count - 1 {
                    if isRequestingForNextPage {
                        since += 1
                        isRequestingForNextPage = false
                        UserRequestHandler().getUsers(since: since) { (usersResponse) in
                            self.isRequestingForNextPage = true
                            self.users.append(contentsOf: usersResponse)
                            self.tableUsers = self.users
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
