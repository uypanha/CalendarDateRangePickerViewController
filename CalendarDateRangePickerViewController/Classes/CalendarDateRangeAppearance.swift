//
//  CalendarDateRangeAppearance.swift
//  CalendarDateRangePickerViewController
//
//  Created by Phanha Uy on 10/3/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

public class CalendarDateRangeAppearance {
    
    public static let appearance = CalendarDateRangeAppearance()
    
    public var selectedColor: UIColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    public var todayHighlightColor: UIColor = UIColor.gray
    public var todayHighlightWidth: CGFloat = 1.5
    public var isSelectedCicular: Bool = true
    public var selectedCornerRadius: CGFloat = 0
    public var displayFirstDate: Bool = false
    public var headerFont: UIFont? = UIFont(name: "HelveticaNeue", size: 17.0)
    public var font: UIFont? = UIFont(name: "HelveticaNeue", size: 15.0)
    
    public var dayOfWeekAppearance: DayOfWeekAppearance = DayOfWeekAppearance()
    
    private init() {}
    
    public class DayOfWeekAppearance {
        
        public var format: String = "EEEEE"
        public var textColor: UIColor = UIColor.darkGray
        public var font: UIFont? = UIFont(name: "HelveticaNeue", size: 15.0)
        
        fileprivate init() {}
        
        public static func builder() -> DayOfWeekAppearance {
            return DayOfWeekAppearance()
        }
        
        public func with(format: String) -> DayOfWeekAppearance {
            self.format = format
            return self
        }
        
        public func with(font: UIFont) -> DayOfWeekAppearance {
            self.font = font
            return self
        }
        
        public func with(textColor: UIColor) -> DayOfWeekAppearance {
            self.textColor = textColor
            return self
        }
    }
}
