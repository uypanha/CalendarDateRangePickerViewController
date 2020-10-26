//
//  CalendarDatePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2018 Phanha. All rights reserved.
//

import UIKit

public protocol CalendarDatePickerViewControllerDelegate {
    func didCancelPickingDateRange()
    func didPickDate(date: Date?)
}

public class CalendarDatePickerViewController: UICollectionViewController {
    
    let cellReuseIdentifier = "CalendarDateRangePickerCell"
    let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    public var delegate: CalendarDatePickerViewControllerDelegate?
    
    let itemsPerRow = 7
    let itemHeight: CGFloat = 40
    let collectionViewInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    
    public var yearCountFromMinimumDate: Int = 10
    public var minimumDate: Date!
    public var maximumDate: Date! {
        didSet {
            self.endOfMonthMaximumDate = self.maximumDate.endOfMonth()
        }
    }
    
    fileprivate var endOfMonthMaximumDate: Date!
    
    public var selectedDate: Date? {
        didSet {
            self.validateSelectedDates()
        }
    }
    
    public var titleText = "Select Date"

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.titleText
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = CalendarDateRangeAppearance.appearance.backgroundColor
        
        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.contentInset = collectionViewInsets
        
        if minimumDate == nil {
            minimumDate = Date()
        }
        
        if maximumDate == nil {
            maximumDate = Calendar.current.date(byAdding: .year, value: yearCountFromMinimumDate, to: minimumDate)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.didTapCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didTapDone))
        self.validateSelectedDates()
        
        DispatchQueue.main.async {
            self.shouldScroolToSelectedDate()
        }
    }
    
    private func validateSelectedDates () {
        self.navigationItem.rightBarButtonItem?.isEnabled = self.selectedDate != nil
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.shouldScroolToSelectedDate()
    }
    
    @objc func didTapCancel() {
        delegate?.didCancelPickingDateRange()
    }
    
    @objc func didTapDone() {
        if selectedDate == nil {
            return
        }
        delegate?.didPickDate(date: self.selectedDate)
    }
}

extension CalendarDatePickerViewController {
    
    // UICollectionViewDataSource
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.getNumberSection(from: self.minimumDate, to: self.endOfMonthMaximumDate)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        cell.reset()
        
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 {
            cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
            cell.dayOfWeekAppearance = CalendarDateRangeAppearance.appearance.dayOfWeekAppearance
        } else if indexPath.item < 7 + blankItems {
            cell.label.text = ""
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.label.text = "\(dayOfMonth)"
            
            if isBefore(dateA: date, dateB: self.minimumDate) || isAfter(dateA: date, dateB: self.maximumDate) {
                cell.disable()
            }
            
            if selectedDate != nil && areSameDay(dateA: date, dateB: selectedDate!) {
                cell.select()
            } else if (self.areSameDay(dateA: date, dateB: Date())) { // Highlight Today
                cell.highlightToday()
            }
        }
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension CalendarDatePickerViewController: UICollectionViewDelegateFlowLayout {
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 + blankItems { // Day of week and empty cells
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        if (cell.date == nil) {
            return
        }
        if isBefore(dateA: cell.date!, dateB: self.minimumDate) || isAfter(dateA: cell.date!, dateB: self.maximumDate) {
            return
        }
        selectedDate = cell.date
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension CalendarDatePickerViewController {
    
    // Helper functions
    
    func getNumberSection(from date1: Date, to date2: Date) -> Int {
        let difference = Calendar.current.dateComponents([.month], from: date1, to: date2)
        return difference.month! + 1
    }
    
    func getFirstDateForSection(section: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: section, to: minimumDate.startOfMonth())!
    }
    
    func getMonthLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.weekday = weekday
        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CalendarDateRangeAppearance.appearance.dayOfWeekAppearance.format
        return dateFormatter.string(from: date!)
    }
    
    func getWeekday(date: Date) -> Int {
        return Calendar.current.dateComponents([.weekday], from: date).weekday!
    }
    
    func getNumberOfDaysInMonth(date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return Calendar.current.date(from: components)!
    }
    
    func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }
    
    func isBefore(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }
    
    func isAfter(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedDescending
    }
    
    fileprivate func shouldScroolToSelectedDate() {
        var section = 0
        if self.selectedDate != nil {
            section = self.getNumberSection(from: self.minimumDate, to: self.selectedDate!.endOfMonth()) - 1
        } else if !CalendarDateRangeAppearance.appearance.displayFirstDate {
            section = self.getNumberSection(from: self.minimumDate, to: Date()) - 1
        }
        
        if let collectionView = self.collectionView, (self.numberOfSections(in: collectionView)) < section {
            return
        }
        
        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: section), at: .centeredVertically, animated: false)
    }
}
