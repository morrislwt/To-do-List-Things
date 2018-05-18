//
//  TableAnimation.swift
//  Todoey
//
//  Created by Morris on 2018/4/23.
//  Copyright © 2018年 Morris. All rights reserved.
//

import UIKit
extension UITableViewController{
    func animateTable(){
        tableView.reloadData()
        let cells = tableView.visibleCells
        
        
        let tableViewWidth = tableView.bounds.size.width
//        let tableviewHeight = tableView.bounds.size.height
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: tableViewWidth, y: 0)
        }
        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 0.8, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
extension UIColor{
    static func rgb(red:CGFloat,green:CGFloat,blue:CGFloat)->UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
