//
//  ViewController.swift
//  RssReader
//
//  Created by Kiyoshi Mizumoto on 2018/04/12.
//  Copyright © 2018年 Kiyoshi Mizumoto. All rights reserved.
//
//  Created by 森部高昌 on 2021/10/24.

    import UIKit

    class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
        
        @IBOutlet weak var longLabel: UILabel!
        
        @IBOutlet weak var latLabel: UILabel!
        
        @IBOutlet weak var tableView: UITableView!

        let feedUrl = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=%E6%96%B0%E5%AE%BF")! //新宿
        
        var feedItems = [FeedItem]() // tableViewの表示に使っている
        
        var currentElementName:String! // パース中に、読み出している項目名
        
        //var searchList:[(address:String,longitude:String,latitude:String)] = [] // タプルに入れてみる
        
        
// ----------------------------------------------------------------------------------
        override func viewDidLoad() {
            super.viewDidLoad()
            print("パース開始")
            let parser: XMLParser! = XMLParser(contentsOf: feedUrl) //feedUrlの中身をパースする？
            parser.delegate = self
            parser.parse()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
// ----------------------------------------------------------------------------------
        
        //タグの最初が見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            self.currentElementName = nil // 初期化
            if elementName == "address" {
                currentElementName = "address"//???????????
                self.feedItems.append(FeedItem())//???????????
            } else {
                currentElementName = elementName
            }
        }
        
        // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド。stringが得られる
         func parser(_ parser: XMLParser, foundCharacters string: String) {
             
             if string != "\n" {// 改行でなければ読み取る
                 
                 if self.feedItems.count > 0 {
                     let lastItem = self.feedItems[self.feedItems.count - 1]
                     
                    switch self.currentElementName {
                     case "address":
                         let tmpString = lastItem.address
                         lastItem.address = (tmpString != nil) ? tmpString! + string : string
                         print("address:\(string)")//
                     case "longitude":
                         let tmpString = lastItem.longitude
                         lastItem.longitude = (tmpString != nil) ? tmpString! + string : string
                         print("longitude:\(string)")//
                     case "latitude":
                         let tmpString = lastItem.latitude
                         lastItem.latitude = (tmpString != nil) ? tmpString! + string : string
                         print("latitude:\(string)")//
                     default:
                         break
                    }
                }
             }
         }
        
        // タグの終わりが見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

            // タグが"results"ならば、タグが閉じられた
            if elementName == "results" {
                print("おわり:")//確認ok
                
                let feedItem = self.feedItems

                print(feedItem[1].address!)//optionalになっている
                print(feedItem[1].longitude!)//optionalになっている
                print(feedItem[1].latitude!)//optionalになっている
            }
        }
 
        //
        func parserDidEndDocument(_ parser: XMLParser) {
            self.tableView.reloadData()
        }

        
// ============================================================
        // 行数の取得
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.feedItems.count
        }

        // セルへの表示
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            let feedItem = self.feedItems[indexPath.row]
                cell.textLabel?.text = feedItem.address // 検索結果　住所の表示
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let feedItem = self.feedItems[indexPath.row]
          //  let ad2 = feedItem
            
            longLabel.text = feedItem.longitude!
            latLabel.text = feedItem.latitude!
            print("選択した:\(feedItem.address!)")
            print("選択した:\(feedItem.longitude!)")
            print("選択した:\(feedItem.latitude!)")
        }
        
    }


//
    class FeedItem {
        var address: String!
        var longitude: String!
        var latitude: String!
    }

