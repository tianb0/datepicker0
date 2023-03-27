//
//  ChecklistItemTableViewCell.swift
//  testpkg3
//
//  Created by Tianbo Qiu on 3/27/23.
//

import UIKit

class ChecklistItemTableViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityTraits = .button
        label.accessibilityHint = "double tap to open"
        label.isAccessibilityElement = true
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()
    
    lazy var completionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "square", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.systemBlue
        button.isUserInteractionEnabled = true
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        button.accessibilityLabel = "mark as completes"
        
        return button
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    
    var item: ChecklistItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            let subtitleText = dateFormatter.string(from: item.date)
            
            titleLabel.text = item.title
            subtitleLabel.text = subtitleText
            
            titleLabel.accessibilityLabel = "\(item.title)\n\(subtitleText)"
            
            updateCompletionStatusAccessibilityInformation()
        }
    }
    
    static let reuseIdentifier = String(describing: ChecklistItemTableViewCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        contentView.isUserInteractionEnabled = true
        addSubview(completionButton)
        
        completionButton.addTarget(self, action: #selector(userDidTouchCheckmarkBox), for: .touchUpInside)
        
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if traitCollection.horizontalSizeClass == .compact {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: 4),
                completionButton.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -4)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                completionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant:-16)
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: completionButton.leadingAnchor, constant: -5),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            completionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            completionButton.widthAnchor.constraint(equalToConstant: 30),
            completionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    @objc func userDidTouchCheckmarkBox() {
        guard let item = item else { return }
        
        item.completed.toggle()
        
        updateCompletionStatusAccessibilityInformation()
        
        UIView.transition(with: completionButton,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            
            let symbolName: String
            
            if item.completed {
                symbolName = "checkmark.square"
            } else {
                symbolName = "square"
            }
            
            let configuration = UIImage.SymbolConfiguration(scale: .large)
            
            let image = UIImage(systemName: symbolName, withConfiguration: configuration)
            self.completionButton.setImage(image, for: .normal)
        }, completion: nil)
    }
    
    private func updateCompletionStatusAccessibilityInformation() {
        if item?.completed == true {
            completionButton.accessibilityLabel = "mark as incomplete"
        } else {
            completionButton.accessibilityLabel = "mark as complete"
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutSubviews()
    }
}
