//
//  HXAxisRenderer.swift
//  ChartsDemo
//
//  Created by Aleksandar Angelov on 10/27/18.
//  Copyright © 2018 Aleksandar Angelov. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class HXAxisRenderer: XAxisRenderer {
    
    override func renderLimitLines(context: CGContext) {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        var limitLines = xAxis.limitLines
        
        if limitLines.count == 0
        {
            return
        }
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            let maxPosition = CGPoint(x: CGFloat(l.limit+25), y: 0).applying(trans)
            renderLimitLineGradient(context: context, limitLine: l, position: position)
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset, maxPosition: maxPosition)
            
        }
    }
    
    func renderLimitLineLabel(context: CGContext, limitLine: ChartLimitLine, position: CGPoint, yOffset: CGFloat, maxPosition: CGPoint) {
        // if drawing the limit-value label is enabled
        let label = limitLine.label
        guard limitLine.drawLabelEnabled && label.count > 0 else {
            return
        }
        
        let labelLineHeight = limitLine.valueFont.lineHeight
        let labelWidth = label.size(withAttributes: [NSAttributedString.Key.font: limitLine.valueFont]).width
        
        let availableSpace = ((maxPosition.x-labelWidth) - position.x) - 20
        if (availableSpace < labelWidth){
            //TODO smaller?
        }
        let centerViewPosition = viewPortHandler.offsetLeft + 0.5*viewPortHandler.chartWidth - 0.5*labelWidth//constant value
        let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset
        var centerRelativeToAvailableSpace = (centerViewPosition - (position.x + 10)) / availableSpace //translate and normalize
        //move point to edge if outside
        if(centerRelativeToAvailableSpace < 0){
            centerRelativeToAvailableSpace = 0
        }
        if (centerRelativeToAvailableSpace > 1 ){
            centerRelativeToAvailableSpace = 1
        }
        //use 1/6 to speed up/down
        centerRelativeToAvailableSpace *= 10.0
        if (centerRelativeToAvailableSpace < 1){
            centerRelativeToAvailableSpace = CGFloat(QuadraticEaseIn(Float(centerRelativeToAvailableSpace)))
        }
        if (centerRelativeToAvailableSpace > 9){
            centerRelativeToAvailableSpace = CGFloat(QuadraticEaseOut(Float((centerRelativeToAvailableSpace-9.0))))+9.0
        }
        centerRelativeToAvailableSpace /= 10.0
        var adjustedPosition = position
        adjustedPosition.x = adjustedPosition.x - xOffset + centerRelativeToAvailableSpace * availableSpace + 5
        
        if limitLine.labelPosition == .rightTop
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x + xOffset,
                                    y: viewPortHandler.contentTop + yOffset),
                                align: .left,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else if limitLine.labelPosition == .rightBottom
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x + xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .left,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else if limitLine.labelPosition == .leftTop
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x - xOffset,
                                    y: viewPortHandler.contentTop + yOffset),
                                align: .right,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
        else
        {
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(
                                    x: adjustedPosition.x - xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .right,
                                attributes: [NSAttributedString.Key.font: limitLine.valueFont, NSAttributedString.Key.foregroundColor: limitLine.valueTextColor])
        }
    }
    
    func renderLimitLineGradient(context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
        
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [limitLine.lineColor.withAlphaComponent(0.5).cgColor,
                      limitLine.lineColor.withAlphaComponent(0.01).cgColor]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: colorspace,
                                  colors: colors as CFArray, locations: locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        
        startPoint.x = position.x
        startPoint.y = viewPortHandler.contentTop
        endPoint.x = position.x+viewPortHandler.contentWidth/2.0;
        endPoint.y = viewPortHandler.contentTop
        context.saveGState()
        context.addRect(CGRect(x: position.x, y: viewPortHandler.contentTop, width: viewPortHandler.contentWidth/2.0, height: viewPortHandler.contentHeight))
        context.clip()
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint,options: [])
        context.restoreGState()
    }
    
    fileprivate func  QuadraticEaseIn(_ p:Float)->Float
    {
        return p * p;
    }
    
    fileprivate func QuadraticEaseOut(_ p:Float)->Float
    {
        return -(p * (p - 2));
    }
    
}
