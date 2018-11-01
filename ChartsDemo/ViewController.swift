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
    
    let dayMinutes = 60*24

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        xAxis.gridLineDashLengths = [0, 0]
        xAxis.drawGridLinesEnabled = false
        xAxis.gridLineDashPhase = 0
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0.0
        
        chartView.drawGridBackgroundEnabled = true
        chartView.gridBackgroundColor = UIColor.white
        chartView.xAxis.valueFormatter = self
        let leftAxis = chartView.leftAxis
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.gridLineDashLengths = [3, 3]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.gridLineDashPhase = 100
        leftAxis.axisMinimum = 0.0
        //leftAxis.labelPosition = .insideChart
        
        leftAxis.labelXOffset = 50
        leftAxis.granularityEnabled = true
        leftAxis.granularity = 1
        chartView.rightAxis.enabled = false
        
        let limitLine = ChartLimitLine(limit: 0, label: "First limit")
        let limitLine2 = ChartLimitLine(limit: 25, label: "Second limit")
        let limitLine3 = ChartLimitLine(limit: 50, label: "Third limit")
        let limitLine4 = ChartLimitLine(limit: 75, label: "Fourth limit")
        limitLine.labelPosition = .rightTop
        limitLine.lineColor = UIColor(red: 197.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7)
        limitLine2.labelPosition = .rightTop
        limitLine2.lineColor = UIColor(red: 197.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7)
        limitLine3.labelPosition = .rightTop
        limitLine3.lineColor = UIColor(red: 197.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7)
        limitLine4.labelPosition = .rightTop
        limitLine4.lineColor = UIColor(red: 197.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7)
        //xAxis.addLimitLine(limitLine)
        //xAxis.addLimitLine(limitLine2)
        //xAxis.addLimitLine(limitLine3)
        //xAxis.addLimitLine(limitLine4)
        
        //xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.valueFormatter = self
        //leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.setScaleMinima(2.5, scaleY: 1)
        
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
        setData()
        chartView.setVisibleXRangeMinimum(3)
    }
    
    fileprivate func setData() {
        let count = dayMinutes
        let range = ClosedRange<Double>(uncheckedBounds: (0, 100))
        let values = (0..<count).compactMap { (i) -> ChartDataEntry? in
            if Int.random(in: ClosedRange<Int>(uncheckedBounds: (0, 100))) > 1 && i != 0 {
                return nil
            }
            let val = Double.random(in: range) + 3
            return ChartDataEntry(x: Double(i), y: val, icon: NSUIImage(contentsOfFile: "icon"))
        }
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
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
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        chartView.xAxis.axisMaximum = data.xMax + 1
        chartView.data = data
    }
    
}

extension ViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var stringValue = ""
//        if (Int(value) % 5) != 0 {
//            print(Int(value))
//            return ""
//        }
        
        let intValue = Int(value)
        stringValue += "\(intValue/60):"
        let remainder = intValue % 60
        let remainderString = String(format: "%02d", remainder)
        //stringValue += remainderString
        return stringValue
    }
    
}
