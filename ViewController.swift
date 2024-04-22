//
//  ViewController.swift
//  BreakBricks
//
//  Created by Linda Guo on 2024/3/6.
//

import UIKit

class ViewController: UIViewController {
    let radius: CGFloat = 10.0
    var panView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemMint
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.gray.cgColor
        view.frame.size.width = 140
        view.frame.size.height = 20
        return view
    }()
    
    var panGesture: UIPanGestureRecognizer?
    
    var ballLayer: CAShapeLayer!
    var displayLink: CADisplayLink!
    var startTime: CFTimeInterval = 0
    var lastTime: CFTimeInterval = 0
    var endTime: CFTimeInterval!
    let animationDuration = 30.0
    
    var speedX : CGFloat = 10
    var speedY : CGFloat = 40
    // how many points per seconds
    // duration * v = displayment under real time
    var minx: CGFloat = 0.0
    var maxx: CGFloat = 0.0
    var miny: CGFloat = 0.0
    var maxy: CGFloat = 0.0
    var timer: Timer?
    let initialPoint = CGPoint(x: 200 , y: 400)
    var ballView: BallView!
    var bricks = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Views
        view.addSubview(panView)
        panView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            panView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            panView.widthAnchor.constraint(equalToConstant: 100),
            panView.heightAnchor.constraint(equalToConstant: 20)])
        
//        ballView = BallView()
//        ballView.center = initialPoint
//        view.addSubview(ballView)
        let boundry = view.bounds
        let safeArea = view.safeAreaInsets
        minx = boundry.origin.x + safeArea.left - initialPoint.x
        maxx = boundry.origin.x + boundry.width - safeArea.right - initialPoint.x
        miny = boundry.origin.y + safeArea.top - initialPoint.y
        maxy = boundry.origin.y + boundry.height - safeArea.bottom - initialPoint.y
        
        
        ballLayer = drawBall(point: initialPoint)
        startAnimation()
        
        layoutBricks()
        
        // setup gestures
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handlePan(gesture:)))
        panGesture = gesture
        panView.addGestureRecognizer(gesture)
        panGesture?.delegate = self
        
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        print("gesture: \(gesture)")
        let gLoc = gesture.location(in: self.view)
        
        panView.frame.origin.x = gLoc.x
    }
    
    func drawBall(point: CGPoint) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter: point, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            let curPosition = ballLayer.position
            let nextX = curPosition.x + speedX
            let nextY = curPosition.y + speedY
            
            if(nextX < minx || nextX > maxx){
                speedX = -speedX
            }
            if(nextY < miny || nextY > maxy){
                speedY = -speedY
            }
            
            let ballRect = CGRect(x: nextX + initialPoint.x, y: nextY + initialPoint.y, width: radius, height: radius)
            let panRect = panView.frame
            if ballRect.intersects(panRect) {
                speedY = -speedY
            }
            
            for brick in self.bricks {
                if ballRect.intersects(brick.frame) {
                    brick.removeFromSuperview()
                    self.bricks.removeAll { $0 == brick } //
                    speedY = -speedY
                    break
                }
            }
            
            ballLayer.position = CGPoint(x: nextX, y: nextY)
            
            //            var ballFrame = self.ballView.frame
            //            let nextX = ballFrame.origin.x + speedX
            //            let nextY = ballFrame.origin.y + speedY
            //
            //            if nextX < minx || nextX > maxx {
            //                speedX = -speedX
            //            }
            //            if nextY < miny || nextY > maxy {
            //                speedY = -speedY
            //            }
            //
            //            for brick in self.bricks {
            //                if ballFrame.intersects(brick.frame) {
            //                    brick.removeFromSuperview()
            //                    self.bricks.removeAll { $0 == brick }
            //                    self.speedY = -self.speedY
            //                    break
            //                }
            //            }
            //
            //            self.ballView.frame = CGRect(x: nextX, y: nextY, width: ballFrame.size.width, height: ballFrame.size.height)
        }
    }
    
    
    @objc func handleAnimation(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        if lastTime == 0 {
            lastTime = currentTime
            return
        }
        let duration = currentTime - lastTime
        lastTime = currentTime
        let curPosition = ballLayer.position
        let nextPosition = calculatePosition(curPosition: curPosition, duration: duration)
        ballLayer.position = nextPosition
    }
    
    func calculatePosition(curPosition: CGPoint, duration: CFTimeInterval) -> CGPoint {
        let nextX = curPosition.x + speedX * duration
        let nextY = curPosition.y + speedY * duration
        
        if(nextX < minx || nextX > maxx){
            speedX = -speedX
        }
        if(nextY < miny || nextY > maxy){
            speedY = -speedY
        }
        
        return CGPoint(x: nextX, y: nextY)
    }
    
    func layoutBricks() {
        let brickWidth: CGFloat = 47
        let brickHeight: CGFloat = 30
        let numberOfRows = 5
        let numberOfColumns = 8
        let spacing: CGFloat = 2
        let xOffset = (view.bounds.width - CGFloat(numberOfColumns) * (brickWidth + spacing)) / 2
        print("\(xOffset)")
        let yOffset = 150
        
        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                let x = xOffset + CGFloat(column) * (brickWidth + spacing)
                let y = CGFloat(row) * (brickHeight + spacing) + CGFloat(yOffset)
                let brickView = Brick(frame: CGRect(x: x, y: y, width: brickWidth, height: brickHeight))
                view.addSubview(brickView)
                bricks.append(brickView)
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
        
    }
}
