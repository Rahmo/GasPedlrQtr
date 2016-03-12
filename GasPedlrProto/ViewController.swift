//
//  ViewController.swift
//  GasPedlrProto
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import UIKit
import Parse

import Charts

class ViewController: UIViewController {
    
    var views: [String]!
    
    func setChart(dataPoints: [String], values: [Double]){
      
        barChartView.noDataText = "No User Activity to Report"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
        
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Touch Activity Reported")
        let chartData = BarChartData(xVals: views, dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.descriptionText = ""
        
        chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.labelPosition = .Bottom
        
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
    
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    
  
    
    @IBOutlet weak var barChartView: BarChartView!
    
    
    class RiderUIViewController: UIViewController{
        var browserCount: Int?
        var mapCount: Int?
        var gameCount: Int?
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        views = ["Browser", "Maps", "Games"]
        //let touchEvents = [browserCount, mapCount , gameCount]
         let touchEvents = [8.0, 9.0, 15.0]
        
        setChartData(months)
        
        setChart(views, values:touchEvents)
        
        self.lineChartView.descriptionText = "Tape node for details"
        self.lineChartView.descriptionTextColor = UIColor.whiteColor()
        self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
        self.lineChartView.noDataText = "No Ads Redeemed"
        
        
    }
    
    
    let months = ["Jan", "Feb","March","April","May","June","July","August","September","October","November","December"]
    let dollars = [132.0,53.0,61.0,343.0,52.0,52.0,54.0,52.5,342.0,13.0,351.0,31.9]
    
    func setChartData(months : [String]) {
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < months.count; i++ {
            yVals1.append(ChartDataEntry(value: dollars[i], xIndex: i))
        }
        
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "First Set")
        set1.axisDependency = .Left // Line will correlate with left axis values
        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.redColor()
        set1.highlightColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        //4 - pass our months in for our x-axis label value along with our dataSets
        let data: LineChartData = LineChartData(xVals: months, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        
        //5 - finally set our data
        self.lineChartView.data = data
    }
    
    
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    
    override func viewDidAppear(animated: Bool)
    {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn");
        if(!isUserLoggedIn)
        {
            self.performSegueWithIdentifier("logOut", sender: self);
            
        }
        
        
    }
    @IBAction func logoutButtonTapped(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(false,forKey: "isUserLoggedIn");
        
        NSUserDefaults.standardUserDefaults().synchronize();
        
        //self.performSegueWithIdentifier("LoginSuccess", sender: self);
        
    }
}
