//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/24/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var chartView: HLineChartView!
    
    var range: ClosedRange<Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let currentDate = Date()
        let startDate = currentDate.subtract(days: 2)!.resetHMSN()!
        let endDate = currentDate.add(days: 1)!.resetHMSN()!
        self.range = (Int(startDate.timeIntervalSince1970)...Int(endDate.timeIntervalSince1970))
        setupLinechartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //chartView.moveViewToAnimated(xValue: 5, yValue: 20, axis: .left, duration: 3.0)
        //chartView.zoomAndCenterViewAnimated(scaleX: 80, scaleY: 20, xValue: 0, yValue: 0, axis: .left, duration: 1.0)
        chartView.scaleYEnabled = false
        chartView.dragYEnabled = false
    }
    
    fileprivate func setupLinechartView() {
        chartView.chartDescription?.enabled = true
        chartView.dragEnabled = true
        chartView.scaleXEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = true
        let xAxis = chartView.xAxis
        xAxis.gridLineDashLengths = [5, 5]
        xAxis.drawGridLinesEnabled = false
        xAxis.gridLineDashPhase = 0
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0.0
        xAxis.axisLineColor = UIColor(hexString: "#cccccc")
        
        chartView.drawGridBackgroundEnabled = true
        chartView.gridBackgroundColor = UIColor.white
        let leftAxis = chartView.leftAxis
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.gridLineDashPhase = 100
        leftAxis.axisMinimum = 0.0
        leftAxis.gridColor = UIColor(hexString: "#cccccc")
        //leftAxis.xOffset = 1.0
        //leftAxis.yOffset = -5.0
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.zeroLineColor = UIColor.clear
        //leftAxis.labelPosition = .insideChart
        
        //leftAxis.labelXOffset = 50
        leftAxis.granularityEnabled = true
        leftAxis.granularity = 1
        chartView.rightAxis.enabled = false
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.valueFormatter = HChartDayTimeValueFormatter(chartView: chartView)
        xAxis.granularityEnabled = true
        xAxis.granularity = 1
        //chartView.setVisibleXRangeMaximum(50)
        chartView.scaleYEnabled = false
        chartView.legend.form = .line
        let l = chartView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        for day in 0..<ChartConstants.days {
            addDayLimitLine(startValue: range.lowerBound, for: day, xAxis: xAxis)
        }
        setData()
        chartView.setVisibleXRangeMaximum(ChartConstants.maxDisplayTime)
        chartView.setVisibleXRangeMinimum(ChartConstants.minDisplayTime)
    }
    
    fileprivate func chartdataSet(range: ClosedRange<Int>) -> ChartDataSet {
        let timevaluesRange = ClosedRange<Double>(uncheckedBounds: (0,1100))
        let values = (range).compactMap { (i) -> ChartDataEntry? in
            let addChartValue = Int.random(in: ClosedRange<Int>(uncheckedBounds: (0, 500)))
            if addChartValue > 0 && i != 0 {
                return nil
            }
            print(addChartValue)
            var val = Double.random(in: timevaluesRange) + 3
            if val > 70 {
                val = 20
            }
            else {
                val = 0
            }
            return ChartDataEntry(x: Double(i), y: val, icon: NSUIImage(contentsOfFile: "icon"))
        }
        
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        //set1.mode = .stepped
        set1.drawIconsEnabled = false
        
        //set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(UIColor.orange)
        //set1.setColor(UIColor(red: 0.0/255.0, green: 114.0/255.0, blue: 174.0/255.0, alpha: 1.0))
        set1.axisDependency = .left
        set1.setCircleColor(.orange)
        set1.lineWidth = 1
        set1.drawCircleHoleEnabled = true
        set1.circleHoleRadius = 5.0
        set1.circleHoleColor = UIColor.white
        set1.circleRadius = 4
        set1.circleHoleRadius = 2
        set1.drawCircleHoleEnabled = true
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        //set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        return set1
    }
    
    fileprivate func setData() {
        let set1 = chartdataSet(range: range.clamped(to: range.lowerBound...range.lowerBound+60*60*7))
        let set2 = chartdataSet(range: range.clamped(to: range.lowerBound+60*60*16...range.upperBound))
        //let set2 = chartdataSet(range: (dayMinutes/10...(dayMinutes-323)))
        let data = LineChartData(dataSets: [set1, set2])
        data.setDrawValues(false)
        
        chartView.xAxis.axisMinimum = Double(range.lowerBound)
        chartView.xAxis.axisMaximum = Double(range.upperBound + 1)
        chartView.data = data
    }
    
    func addDayLimitLine(startValue: Int,for day: Int, xAxis: XAxis) {
        let limitLine = ChartLimitLine(limit: Double(startValue+(ChartConstants.dayDuration*day)), label: "Day \(day+1)")
        limitLine.labelPosition = .rightTop
        limitLine.lineColor = UIColor(red: 197.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7)
        xAxis.addLimitLine(limitLine)
    }
    
}

extension Date {
    
    /**
     Subtract an amount of days to the current date
     */
    func subtract(days: Int, calendar: Calendar = Calendar(identifier: .gregorian), timezone: TimeZone = .autoupdatingCurrent) -> Date? {
        var dateComponents = calendar.dateComponents(in: timezone, from: self)
        guard let day = dateComponents.day else {
            return nil
        }
        dateComponents.day = day-days
        return calendar.date(from: dateComponents)
    }
    
    /**
     Add an amount of days to the current date
     */
    func add(days: Int, calendar: Calendar = Calendar(identifier: .gregorian), timezone: TimeZone = .autoupdatingCurrent) -> Date? {
        var dateComponents = calendar.dateComponents(in: timezone, from: self)
        guard let day = dateComponents.day else {
            return nil
        }
        dateComponents.day = day+days
        return calendar.date(from: dateComponents)
    }
    
    /**
     Reset the hours, minutes, seconds and nanoseconds to 0
     */
    func resetHMSN(_ calendar: Calendar = Calendar(identifier: .gregorian), timezone: TimeZone = .autoupdatingCurrent) -> Date? {
        var dateComponents = calendar.dateComponents(in: timezone, from: self)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        return calendar.date(from: dateComponents)
    }
    
}
