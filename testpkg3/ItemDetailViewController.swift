//
//  ItemDetailViewController.swift
//  testpkg3
//
//  Created by Tianbo Qiu on 3/27/23.
//

import UIKit

class ItemDetailViewController: UITableViewController {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    let item: ChecklistItem
    
    init(item: ChecklistItem) {
        self.item = item
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        title = String(item.title.truncatePrefix(16)) // a copy
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "task name"
            cell.detailTextLabel?.text = item.title
        } else {
            cell.textLabel?.text = "due date"
            cell.detailTextLabel?.text = dateFormatter.string(from: item.date)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // task name
            let changeTaskNameAlert = UIAlertController(title: "edit name",
                                                        message: "what should this task be called?",
                                                        preferredStyle: .alert)
            changeTaskNameAlert.addTextField { [weak self] textField in
                guard let self = self else { return }
                
                textField.text = self.item.title
                textField.placeholder = "task name"
            }
            
            changeTaskNameAlert.addAction(UIAlertAction(title: "save", style: .default, handler: { [weak self] _ in
                guard let self = self,
                      let newTitle = changeTaskNameAlert.textFields?.first?.text,
                      !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else { return }
                
                self.item.title = newTitle
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }))
            
            changeTaskNameAlert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(changeTaskNameAlert, animated: true, completion: nil)
        } else {
            // due date
            let pickerController = CalendarPickerViewController(baseDate: item.date) { [weak self] date in
                guard let self = self else  { return }
                
                self.item.date = date
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            }
            
            present(pickerController, animated: true, completion: nil)
        }
    }
}
