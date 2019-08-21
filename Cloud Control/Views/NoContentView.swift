//
//  NoContentView.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 21/08/2019.
//  Copyright © 2019 Clément. All rights reserved.
//

import UIKit

class NoContentView: UIView {
    
    enum ViewType {
        case noRegionSelected
        case noInstance
        case error
        
        var title: String {
            switch self {
            case .noRegionSelected:
                return "No Region Selected"
            case .noInstance:
                return "No Instance"
            case .error:
                return "Error"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .noRegionSelected:
                return UIImage(named: "Region")?.withRenderingMode(.alwaysTemplate)
            case .error:
                return UIImage(named: "Error")?.withRenderingMode(.alwaysTemplate)
            case .noInstance:
                return UIImage(named: "EmptyBox")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    private let color: UIColor
    private let type: ViewType
    
    init(frame: CGRect = .zero, type: ViewType) {
        self.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.type = type
        super.init(frame: frame)
        commonInit()
    }
    
    override init(frame: CGRect) {
        self.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.type = .noInstance
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        let imageView = UIImageView(image: type.image)
        imageView.tintColor = color
        
        let label = UILabel()
        label.text = type.title
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 150, height: 90)
    }
}
