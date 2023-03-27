//
//  ItemListViewController.swift
//  testpkg3
//
//  Created by Tianbo Qiu on 3/27/23.
//

import UIKit

class ItemListViewController: UITableViewController {
    
    // MARK: diffable data source setup
    
    enum Section {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, ChecklistItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ChecklistItem>
    
    // MARK: properties
    
    private lazy var dataSource = makeDataSource()
    private lazy var items = ChecklistItem.exampleItems
    
    private var searchQuery: String? = nil {
        didSet {
            applySnapshot()
        }
    }
    
    // MARK: controller setup
    
    private lazy var searchController = makeSearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .automatic
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "checkmate"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .done,
            target: self,
            action: #selector(didTapNewItemButton))
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = "new item"
        
        tableView.register(ChecklistItemTableViewCell.self,
                           forCellReuseIdentifier: ChecklistItemTableViewCell.reuseIdentifier)
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applySnapshot(animatingDifferences: false)
    }
    
    @objc func didTapNewItemButton() {
        let newItemAlert = UIAlertController(title: "new item",
                                             message: "what would you like to do today?",
                                             preferredStyle: .alert)
        
        newItemAlert.addTextField {
            $0.placeholder = "item text"
        }
        
        newItemAlert.addAction(UIAlertAction(title: "create item", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let title = newItemAlert.textFields?.first?.text,
                  !title.isEmpty else {
                let errorAlert = UIAlertController(title: "error",
                                                   message: "you can't leave the title empty",
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            self.items.append(ChecklistItem(title: title, date: Date()))
            self.applySnapshot()
        })
        
        newItemAlert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(newItemAlert, animated: true, completion: nil)
    }
    
}

// MARK: table view methods

extension ItemListViewController {
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var items: [ChecklistItem] = self.items
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            items = items.filter{
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }
        
        items = items.sorted { $0.date < $1.date }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChecklistItemTableViewCell.reuseIdentifier,
                for: indexPath) as? ChecklistItemTableViewCell
            cell?.item = item
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // push to items detail view
        
        navigationController?.pushViewController(ItemDetailViewController(item: items[indexPath.row]), animated: true)
    }
    
    // MARK: contexual menus
    
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [weak self] _ in
            guard let self = self, let item = self.dataSource.itemIdentifier(for: indexPath)
            else { return nil }
            
            let deleteAction = UIAction(title: "Delete item",
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                self.items.removeAll { $0 == item }
                
                self.applySnapshot()
            }
            
            return UIMenu(title: item.title.truncatePrefix(12), image: nil, children: [deleteAction])
        })

        return configuration
    }
}

// MARK: search controller setup
extension ItemListViewController: UISearchResultsUpdating {
    
    func makeSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "search items"
        return controller
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        searchQuery = searchController.searchBar.text
    }
}
