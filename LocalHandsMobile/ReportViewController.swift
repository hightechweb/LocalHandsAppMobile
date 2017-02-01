//
//  ReportViewController.swift
//  LocalHandsMobile
//
//  Created by Daniel on 1/31/17.
//  Copyright © 2017 LocalHands. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class ReportViewController: UIViewController, IAxisValueFormatter {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var viewChart: BarChartView!
    
    var weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // #1 - Init chart
        self.initializeChart()
        
        // #2 - Load data to chart
        self.loadDataInChart()
        
    }
    
    func initializeChart() {
        
        viewChart.noDataText = "No Data"
        viewChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        viewChart.xAxis.labelPosition = .bottom
        viewChart.chartDescription?.text = ""
        viewChart.xAxis.valueFormatter = self
        
        
        viewChart.legend.enabled = false
        viewChart.scaleXEnabled = false
        viewChart.scaleYEnabled = false
        viewChart.pinchZoomEnabled = false
        viewChart.doubleTapToZoomEnabled = false
        
        viewChart.leftAxis.axisMinimum = 0.0
        viewChart.leftAxis.axisMaximum = 100.00
        viewChart.highlighter = nil
        viewChart.rightAxis.enabled = false
        viewChart.xAxis.drawGridLinesEnabled = false
        
    }
    
    func loadDataInChart() {
        
        APIManager.shared.getDriverRevenue { json in
            
            if json != JSON.null {
                
                let revenue = json["revenue"]
                
                var dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<self.weekdays.count {
                    let day = self.weekdays[i]
                    let dataEntry = BarChartDataEntry(x: Double(i), yValues: [revenue[day].double!])
                    dataEntries.append(dataEntry)
                }
                
                let chartDataSet = BarChartDataSet(values: dataEntries, label: "Revenue by day")
                chartDataSet.colors = ChartColorTemplates.material()
                
                let chartData = BarChartData(dataSet: chartDataSet)
                
                self.viewChart.data = chartData
                
            }
        }
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return weekdays[Int(value)]
    }
    
}
