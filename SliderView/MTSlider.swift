//
//  MTSlider.swift
//  Slider
//
//  Created by EasyHoony on 2016/10/12.
//  Copyright © 2016年 EasyHoony. All rights reserved.
//
// 数据结构CGPoint表示在二维坐标系中一个点。数据结构CGRect中代表了一个矩形的位置和尺寸。数据结构CGSize代表宽度和高度的尺寸

import UIKit

private extension CATextLayer {
    
    var textSize: CGSize {
        
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        if let size = (string as? NSString)?.boundingRect(with: .zero, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attrs, context: nil).size {
            return size
        }
        return .zero
    }
    
}

class MTSlider: UIView {
    
    var sliderHandler: ((CGFloat, Int) -> Void)?
    // 最小值,监听在数值变化时的字符串变化
    var minValue: Int = 0 {
        didSet {
            _minTextLayer?.string = "\(minValue)m"
        }
    }
    // 最大值
    var maxValue: Int = 100 {
        didSet {
            _maxTextLayer?.string = "\(maxValue)m"
        }
    }
    // 当前值
    var currentValue: Int = 0 {
        didSet {
            // 所占百分比 = (current - min) / (max - min) * 100%
            _percent                 = CGFloat(currentValue - minValue) / CGFloat(maxValue - minValue)
            // 进度条结束值
            _progressLayer.strokeEnd = _percent
            let minX                 = _minTextLayer.frame.maxX + _curTextLayer.frame.width / 2
            let maxX                 = _maxTextLayer.frame.minX - _curTextLayer.frame.width / 2
            let curX                 = _percent * _backGroundProgressLayer.frame.width + _backGroundProgressLayer.frame.minX
            
            // 当前显示的数值
            _curTextLayer?.string    = "\(currentValue)m"
            // 当前显示 text 的位置
            _curTextLayer.position   = CGPoint(x: curX < minX ? minX : curX > maxX ? maxX : curX, y: _curTextLayer.position.y)
            // 写入block值
            sliderHandler?(_percent, currentValue)
        }
    }
    
    // 进度条颜色
    var progressColor: UIColor = UIColor(red:0.40, green:0.60, blue:0.99, alpha:1.00) {
        didSet {
            
        }
    }
    
    // 背景颜色
    var progressBackgroundColor: UIColor =  UIColor(red:0.85, green:0.84, blue:0.85, alpha:1) {
        didSet {
            
        }
    }
    
    // 百分比
    private var _percent: CGFloat = 0
    // 显示最小值
    private var _minTextLayer: CATextLayer!
    // 显示最大值
    private var _maxTextLayer: CATextLayer!
    // 显示当前值
    private var _curTextLayer: CATextLayer!
    // 背景 layer
    private var _backGroundProgressLayer: CAShapeLayer!
    // 进度 layer
    private var _progressLayer: CAShapeLayer!
    // 圆块 layer
    private var _leftCircleLayer: CAShapeLayer!
    private var _rightCircleLayer: CAShapeLayer!
    private var _currentCircleLayer: CALayer!
    private var _smallCilcleLayer: CALayer!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        _initLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _initLayer() {
        
        let sliderBounds = CGRect(x: 0, y: 0, width: bounds.width - 40, height: 10)

        func maskLayer() -> CAShapeLayer {
            // layer 层
            let maskLayer  = CAShapeLayer()
            // 路径
            let maskPath   = CGMutablePath()
            maskPath.addArc(center: CGPoint(x: sliderBounds.height / 2,
                                            y: sliderBounds.height / 2),
                            radius: sliderBounds.height / 2,
                            startAngle: 0,
                            endAngle: CGFloat(M_PI) * 2,
                            clockwise: false)
            
            maskPath.addRect(CGRect(x: sliderBounds.height / 2,
                                    y: 0,
                                    width: sliderBounds.width - sliderBounds.height,
                                    height: sliderBounds.height))
            
            maskPath.addArc(center: CGPoint(x: sliderBounds.width - sliderBounds.height / 2,
                                            y: sliderBounds.height / 2),
                            radius: sliderBounds.height / 2,
                            startAngle: 0,
                            endAngle: CGFloat(M_PI) * 2,
                            clockwise: false)
            maskLayer.path = maskPath
            return maskLayer
        }
        
        //------------------------------背景层--------------------------------//
        _backGroundProgressLayer                 = CAShapeLayer()
        _backGroundProgressLayer.backgroundColor = progressBackgroundColor.cgColor
        // 背景在视图上的位置
        _backGroundProgressLayer.position        = CGPoint(x: bounds.width / 2, y: bounds.height / 2 )
        _backGroundProgressLayer.bounds          = CGRect(origin: .zero, size: sliderBounds.size)
        _backGroundProgressLayer.lineWidth       = sliderBounds.height
        _backGroundProgressLayer.mask            = maskLayer()
        layer.addSublayer(_backGroundProgressLayer)
        //-------------------------------进度条层-----------------------------//
        let path = UIBezierPath()
        path.move(to: CGPoint(x: sliderBounds.minX, y: sliderBounds.minY + sliderBounds.height / 2))
        path.addLine(to: CGPoint(x: sliderBounds.maxX, y: sliderBounds.minY + sliderBounds.height / 2))
        _progressLayer              = CAShapeLayer()
        _progressLayer.strokeColor  = progressColor.cgColor
        _progressLayer.lineWidth    = sliderBounds.height
        _progressLayer.strokeStart  = 0
        _progressLayer.strokeEnd    = 0.5
        _progressLayer.path         = path.cgPath
        _progressLayer.position     = CGPoint(x: _backGroundProgressLayer.position.x - _backGroundProgressLayer.bounds.width / 2,
                                              y: _backGroundProgressLayer.position.y - _backGroundProgressLayer.bounds.height / 2)
        
        _progressLayer.mask         = maskLayer()
        layer.addSublayer(_progressLayer)
        //-------------左圆----------//
        _leftCircleLayer                 = CAShapeLayer()
        _leftCircleLayer.fillColor       = UIColor.black.cgColor
        let leftPath                     = UIBezierPath(
            arcCenter: CGPoint(x: sliderBounds.height / 2 + 20,
                               y: bounds.height / 2),
            radius: CGFloat(sliderBounds.height / 3 ),
            startAngle: 0,
            endAngle: 2 * CGFloat(M_PI),
            clockwise: false)
        _leftCircleLayer?.path           = leftPath.cgPath
        layer.addSublayer(_leftCircleLayer)
        //------------右圆--------------//
        _rightCircleLayer                = CAShapeLayer()
        _rightCircleLayer.fillColor      = UIColor.black.cgColor
        let rightPath                    = UIBezierPath(
            arcCenter: CGPoint(x: sliderBounds.width + 20 - sliderBounds.height / 2,
                               y: bounds.height / 2),
            radius: CGFloat(sliderBounds.height / 3),
            startAngle: 0,
            endAngle: 2 * CGFloat(M_PI),
            clockwise: false)
        _rightCircleLayer.path           = rightPath.cgPath
        layer.addSublayer(_rightCircleLayer)
        //---------进度条大圆----------//
        _currentCircleLayer                  = CALayer()
        _currentCircleLayer.contentsScale    = UIScreen.main.scale
        _currentCircleLayer.bounds           = CGRect(origin: .zero, size: CGSize(width: sliderBounds.height * 1.5 , height: sliderBounds.height * 1.5))
        _currentCircleLayer.backgroundColor  = progressColor.cgColor
        _currentCircleLayer.cornerRadius     = sliderBounds.height * 1.5 / 2
        _currentCircleLayer.position         = CGPoint(x: bounds.height / 2, y:bounds.height / 2 )
        layer.addSublayer(_currentCircleLayer)
        //-------------进度条小圆-----------//
        _smallCilcleLayer                    = CALayer()
        _smallCilcleLayer.backgroundColor    = UIColor.black.cgColor
        _smallCilcleLayer.position           = CGPoint(x: _currentCircleLayer.bounds.height / 2, y: _currentCircleLayer.bounds.height / 2)
        _smallCilcleLayer.bounds             = CGRect(origin: .zero, size: CGSize(width: sliderBounds.height / 1.5 , height: sliderBounds.height / 1.5))
        _smallCilcleLayer.cornerRadius       = sliderBounds.height / 3
        _currentCircleLayer.addSublayer(_smallCilcleLayer)
        
        //------------textLayer最小值----------------//
        _minTextLayer                 = CATextLayer()
        _minTextLayer.string          = "minValue"
        _minTextLayer.fontSize        = 11
        _minTextLayer.foregroundColor = UIColor.black.cgColor
        _minTextLayer.bounds          = CGRect(origin: .zero, size: _minTextLayer.textSize)
        _minTextLayer.position        = CGPoint(x: _backGroundProgressLayer.frame.minX + _backGroundProgressLayer.bounds.height / 2, y: _backGroundProgressLayer.frame.minY + 30)
        layer.addSublayer(_minTextLayer)
        //------------textLayer最大值-------------//
        _maxTextLayer                 = CATextLayer()
        _maxTextLayer.string          = "maxValue"
        _maxTextLayer.fontSize        = 11
        _maxTextLayer.foregroundColor = UIColor.black.cgColor
        _maxTextLayer.bounds          = CGRect(origin: .zero, size: _maxTextLayer.textSize)
        _maxTextLayer.position        = CGPoint(x: _backGroundProgressLayer.frame.maxX - _backGroundProgressLayer.bounds.height / 2,y:  _minTextLayer.position.y)
        layer.addSublayer(_maxTextLayer)
        //----------------当前textLayer---------------//
        _curTextLayer                 = CATextLayer()
        _curTextLayer.string          = "currentValue"
        _curTextLayer.fontSize        = 11
        _curTextLayer.foregroundColor = progressColor.cgColor
        _curTextLayer.backgroundColor = UIColor.clear.cgColor
        // ----------------滑块的大小----------------//
        _curTextLayer.bounds          = CGRect(origin: .zero, size: CGSize(width:  _maxTextLayer.bounds.width + 10, height: _maxTextLayer.bounds.height ))
        _curTextLayer.position        = CGPoint(x: 0,y: _minTextLayer.position.y)
        _curTextLayer.masksToBounds   = true
        _curTextLayer.cornerRadius    = _curTextLayer.bounds.height / 2
        layer.addSublayer(_curTextLayer)
        let textLayerStyle = { (textLayer: CATextLayer) in
            textLayer.contentsScale   = UIScreen.main.scale
            textLayer.alignmentMode   = kCAAlignmentCenter
            textLayer.anchorPoint     = CGPoint(x: 0.5,y:  1)
        }
        textLayerStyle(_minTextLayer)
        textLayerStyle(_maxTextLayer)
        textLayerStyle(_curTextLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _calcTouchPoint(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        _calcTouchPoint(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _calcTouchPoint(touches: touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        _calcTouchPoint(touches: touches)
    }
    
    // touch调用
    private func _calcTouchPoint(touches: Set<UITouch>?) {
        // 捕捉第一响应touch点, 返回一个view的点
        
        if let touchPoint = touches?.first?.location(in: self) {
            let minX  = _backGroundProgressLayer.frame.minX
            let maxX  = _backGroundProgressLayer.frame.maxX
            let width = _backGroundProgressLayer.frame.width
            CATransaction.setDisableActions(true)
            var x: CGFloat = touchPoint.x
            x = x < minX + 5 ? minX + 5 : x > maxX - 5 ? maxX - 5 : x
            _currentCircleLayer.position = CGPoint(x: x , y: bounds.height / 2 )
            if touchPoint.x > minX {
            _leftCircleLayer.fillColor   = UIColor.white.cgColor
                
            }
            // 小于最左边的点
            if touchPoint.x < minX {
                _percent                   = 0
                _leftCircleLayer.fillColor = UIColor.black.cgColor
                // 大于最右边的点
            } else if touchPoint.x > maxX {
                _percent = 1
                _rightCircleLayer.fillColor = UIColor.white.cgColor
            } else {
                _rightCircleLayer.fillColor = UIColor.black.cgColor
                // 在范围的点, 百分比
                _percent                    = (touchPoint.x - minX) / width
            }
            // 实际的值, (当前 - 最小值) * 百分比 + 最小值
            currentValue = Int(CGFloat(maxValue - minValue) * _percent) + minValue
            CATransaction.setDisableActions(false)
        }
    }
}
