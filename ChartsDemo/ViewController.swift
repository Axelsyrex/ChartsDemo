//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/24/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var chartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupLinechartView()
    }
    
    fileprivate func setupLinechartView() {
        chartView.chartDescription?.enabled = true
        chartView.dragEnabled = true
        chartView.scaleXEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.gridBackgroundColor = UIColor.blue
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = true
        chartView.xAxis.gridLineDashLengths = [10, 10]
        chartView.xAxis.gridLineDashPhase = 0
        chartView.xAxis.labelPosition = .bottom
        //chartView.xAxis.valueFormatter = self
        let leftAxis = chartView.leftAxis
        leftAxis.drawBottomYLabelEntryEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.gridLineDashLengths = [10, 10]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.setScaleMinima(2.0, scaleY: 1)
        chartView.legend.form = .line
        let l = chartView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        //chartView.animate(xAxisDuration: 2.5)
        
        setData()
    }
    
    fileprivate func setData() {
        let count = 100
        let range = ClosedRange<Double>(uncheckedBounds: (0, 100))
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double.random(in: range) + 3
            return ChartDataEntry(x: Double(i), y: val, icon: NSUIImage(contentsOfFile: "icon"))
        }
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        set1.drawIconsEnabled = false
        
        //set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.axisDependency = .left
        set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
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
        let data = LineChartData(dataSet: set1)
        chartView.xAxis.axisMaximum = data.xMax + 1
        chartView.data = data
    }
    
}

extension ViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(value)
    }
    
}
