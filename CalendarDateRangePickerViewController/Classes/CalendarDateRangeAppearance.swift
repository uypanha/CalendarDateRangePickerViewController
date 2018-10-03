//
//  CalendarDateRangeAppearance.swift
//  CalendarDateRangePickerViewController
//
//  Created by Phanha Uy on 10/3/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

public class CalendarDateRangeAppearance {
    
    public static let shared = CalendarDateRangeAppearance()
    
    public var selectedColor: UIColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    public var isSelectedCicular: Bool = true
    public var selectedCornerRadius: CGFloat = 0
    public var displayFirstDate: Bool = false
    public var font: UIFont? = UIFont(name: "HelveticaNeue", size: 15.0)
    
    private init() {}
}
