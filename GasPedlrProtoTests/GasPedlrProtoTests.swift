//
//  GasPedlrProtoTests.swift
//  GasPedlrProtoTests
//
//  Created by Munib Ali on 10/10/15.
//  Copyright © 2015 GMG Developments. All rights reserved.
//

import XCTest
import UIKit

@testable import GasPedlrProto


class GasPedlrProtoTests: XCTestCase {
  
    
    func testCode(){
    
    
    let sum = 2
        
        XCTAssert(sum == 2 , "success")
        
    }
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testExample() {
////         This is an example of a functional test case.
////         Use XCTAssert and related functions to verify your tests produce the correct results.
//     TestRegister()   
//    }
//    
//    
//    func TestRegister()
//    {
//        let userEmail = "ddd@dffd.com";
//        let userPassword = "ran335";
//        let userName = "Rahmo";
//        let userVehicle = "Camry";
//        let userlicensePlate = "Rakfor";
//        //let userRepeatPassword = "ran335";
//        NSUserDefaults.standardUserDefaults().setObject(userName, forKey:"userName");
//        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey:"userEmail");
//        NSUserDefaults.standardUserDefaults().setObject(userPassword, forKey:"userPassword");
//        NSUserDefaults.standardUserDefaults().setObject(userVehicle, forKey:"userVehicle");
//        NSUserDefaults.standardUserDefaults().setObject(userlicensePlate, forKey:"userlicensePlate");
//        NSUserDefaults.standardUserDefaults().synchronize()
//            let userEmailStored = NSUserDefaults.standardUserDefaults().stringForKey("userEmail");
//         let userPwdStored = NSUserDefaults.standardUserDefaults().stringForKey("userPassword");
//        XCTAssert(userEmail == userEmailStored  && userPassword == userPwdStored)
//      
//    }
//    
//    func TestLogin()
//    {
//    
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
