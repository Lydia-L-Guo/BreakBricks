//
//  BallView.swift
//  BreakBricks
//
//  Created by Linda Guo on 2024/3/7.
//

import UIKit

class BallView: UIView {
    static let radius: CGFloat = 20.0
    
    override init(frame: CGRect = CGRectZero) {
        super.init(frame: CGRect(x: 0, y: 0, width: BallView.radius, height: BallView.radius))
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.addEllipse(in: rect)
        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
    }
    
}
