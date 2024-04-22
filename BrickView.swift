//
//  BrickView.swift
//  BreakBricks
//
//  Created by Linda Guo on 2024/3/9.
//

import Foundation
import UIKit

class Brick: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBrick()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBrick()
    }
    
    private func setupBrick() {
        backgroundColor = UIColor.blue
        layer.cornerRadius = 3
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
