//
//  CalendarDateRangePickerCell.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerCell: UICollectionViewCell {
    
    private let defaultTextColor = CalendarDateRangeAppearance.appearance.dayOfWeekAppearance.textColor
    private let highlightedColor = CalendarDateRangeAppearance.appearance.highlightedColor
    private var disabledColor = CalendarDateRangeAppearance.appearance.dayOfWeekAppearance.disabledTextColor
    
    var date: Date?
    var selectedView: UIView?
    var halfBackgroundView: UIView?
    var roundHighlightView: UIView?
    
    var label: UILabel!
    
    var dayOfWeekAppearance: CalendarDateRangeAppearance.DayOfWeekAppearance? {
        didSet {
            guard let appearance = self.dayOfWeekAppearance else {
                return
            }
            
            self.disabledColor = appearance.disabledTextColor
            self.label.textColor = appearance.textColor
            self.label.font = appearance.font
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initLabel()
    }
    
    func initLabel() {
        label = UILabel(frame: frame)
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        label.font = CalendarDateRangeAppearance.appearance.font?.withSize(15.0)
        label.textColor = defaultTextColor
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    func reset() {
        self.dayOfWeekAppearance = nil
        self.backgroundColor = UIColor.clear
        label.textColor = defaultTextColor
        label.backgroundColor = UIColor.clear
        label.font = CalendarDateRangeAppearance.appearance.font?.withSize(15.0)
        if selectedView != nil {
            selectedView?.removeFromSuperview()
            selectedView = nil
        }
        if halfBackgroundView != nil {
            halfBackgroundView?.removeFromSuperview()
            halfBackgroundView = nil
        }
        if roundHighlightView != nil {
            roundHighlightView?.removeFromSuperview()
            roundHighlightView = nil
        }
    }
    
    func select(_ isFirstSelectedDate: Bool? = nil) {
        let width = self.frame.size.width
        let height = self.frame.size.height
        selectedView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        
        let cornerOptions: UIRectCorner!
        if isFirstSelectedDate == true {
            cornerOptions = [.bottomLeft, .topLeft]
        } else if isFirstSelectedDate == false {
            cornerOptions = [.bottomRight, .topRight]
        } else {
            cornerOptions = [.allCorners]
        }
        
        let cornerRadius = CalendarDateRangeAppearance.appearance.isSelectedCicular ? height / 2 : CalendarDateRangeAppearance.appearance.selectedCornerRadius
        
        let maskPath = UIBezierPath(roundedRect: selectedView!.bounds,
                                    byRoundingCorners: cornerOptions,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        selectedView?.layer.mask = shape
        selectedView?.backgroundColor = CalendarDateRangeAppearance.appearance.selectedColor
        //selectedView?.layer.cornerRadius = height / 2
        self.addSubview(selectedView!)
        self.sendSubviewToBack(selectedView!)
        
        label.textColor = UIColor.white
    }
    
    func highlightRight() {
        // This is used instead of highlight() when we need to highlight cell with a rounded edge on the left
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: width / 2, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        self.addSubview(halfBackgroundView!)
        self.sendSubviewToBack(halfBackgroundView!)
        
        addRoundHighlightView()
    }
    
    func highlightLeft() {
        // This is used instead of highlight() when we need to highlight the cell with a rounded edge on the right
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        self.addSubview(halfBackgroundView!)
        self.sendSubviewToBack(halfBackgroundView!)
        
        addRoundHighlightView()
    }
    
    func highlightToday() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        selectedView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        selectedView?.layer.borderColor = CalendarDateRangeAppearance.appearance.todayHighlightColor.cgColor
        selectedView?.layer.borderWidth = CalendarDateRangeAppearance.appearance.todayHighlightWidth
        selectedView?.layer.cornerRadius = height / 2
        self.addSubview(selectedView!)
        self.sendSubviewToBack(selectedView!)
    }
    
    func addRoundHighlightView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        roundHighlightView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        roundHighlightView?.backgroundColor = highlightedColor
        roundHighlightView?.layer.cornerRadius = height / 2
        self.addSubview(roundHighlightView!)
        self.sendSubviewToBack(roundHighlightView!)
    }
    
    func highlight() {
        self.backgroundColor = highlightedColor
    }
    
    func disable() {
        label.textColor = disabledColor
    }
    
}
