//
//  HChartDayTimeValueFormatter.swift
//  ChartsDemo
//
//  Created by Aleksander Angelov on 11/7/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation

class HChartDayTimeValueFormatter: IAxisValueFormatter {
    
    unowned let chartView: HLineChartView
    
    private lazy var calendar: Calendar = {
        return Calendar(identifier: .gregorian)
    }()
    
    init(chartView: HLineChartView) {
        self.chartView = chartView
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        print(chartView.scaleX)
        let components = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        var stringValue = "\(hours)"
        if chartView.scaleX < 100 && minutes != 0 {
            stringValue = ""
        }
        if chartView.scaleX >= 100 {
            let minutesString = String(format: ":%02d", minutes)
            stringValue += minutesString
        }
        return stringValue
    }
    
}
