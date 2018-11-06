//
//  HLineChartView.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/27/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation

enum ChartConstants {
    static let dayDuration = 60*24
    static let totalDaysDuration = dayDuration*3
    static let maxDisplayTime = dayDuration*2
    static let minDisplayTime = 2
}

class HLineChartView: LineChartView {
    
    private let _hxAxis = HXAxis()
    
    override var xAxis: XAxis {
        return _hxAxis
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.xAxisRenderer = HXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: getTransformer(forAxis: .left))
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.xAxisRenderer = HXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: getTransformer(forAxis: .left))
    }
   
}
