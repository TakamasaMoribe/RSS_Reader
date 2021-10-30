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

        @IBOutlet weak var tableView: UITableView!

//        let feedUrl = URL(string:"https://news.yahoo.co.jp/rss/topics/top-picks.xml")!
        let feedUrl = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=%E6%96%B0%E5%AE%BF")! //新宿
        var feedItems = [FeedItem]()
        
        var currentElementName:String! // パース中に、読み出している項目名
        
        //var searchList:[(address:String,longitude:String,latitude:String)] = [] // タプルに入れてみる
        
        let ITEM_ELEMENT_NAME = "address"
        

        var flagAddress : Bool = false
        var flagLongitude : Bool = false
        var flagLatitude : Bool = false

        // １階層目のタグを覚えておく変数を用意する
        var XMLtag1:String! = ""
        var XMLtag2:String! = "" // ２階層目
        
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
        
//        //タグの最初が見つかったとき呼ばれる
//        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//            //self.currentElementName = nil // 初期化
//
//            // タグが results ならば 「resultsタグ」に入ったことを、XMLtag1に覚えておく
//            if elementName == "results" { XMLtag1 = "results" }
//            // タグが candidate ならば 「candidateタグ」に入ったことを、XMLtag2に覚えておく
//            if elementName == "candidate" { XMLtag2 = "candidate" }
//            // タグが address ならば
//            if elementName == "address" { flagAddress = true
//
//            }
//            // タグが longitude ならば
//            if elementName == "longitude" { flagLongitude = true }
//            // タグが latitude ならば
//            if elementName == "latitude" { flagLatitude = true }
//
//            // タグ1が「results」で、タグ2が「candidate」に入った状態ならば、そのデータを取り出す
////            if XMLtag1 == "results" && XMLtag2 == "candidate" {
////
////                //print("elementName:\(elementName)")//
////            }
//        }
        
        //タグの最初が見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            self.currentElementName = nil // 初期化
            if elementName == "address" {
                currentElementName = "address"//???????????
                self.feedItems.append(FeedItem())
            } else {
                currentElementName = elementName
            }
        }
        
        
            
        // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
         func parser(_ parser: XMLParser, foundCharacters string: String) {
             
             if self.feedItems.count > 0 {
                 let lastItem = self.feedItems[self.feedItems.count - 1]
                 
                 switch self.currentElementName {
                 case "address":
                     let tmpString = lastItem.address
                     lastItem.address = (tmpString != nil) ? tmpString! + string : string
                     print("lastItem.address:\(tmpString)")
                     print(string)
                 case "longitude":
                     let tmpString = lastItem.longitude
                     lastItem.longitude = (tmpString != nil) ? tmpString! + string : string
                 case "latitude":
                     let tmpString = lastItem.latitude
                     lastItem.latitude = (tmpString != nil) ? tmpString! + string : string
                 default:
                     break
                 }
                 
             }
             
             
//             if (flagAddress == true)  { print("Address:\(string)")
//                 address = string
//                 self.feedItems.append(FeedItem()) // tableViewのデータに対応している？
//                 print(feedItems)
//             }
//
//             if (flagLongitude == true)  { print("Longitude:\(string)")
//                 longitude = string
//             }
//             if (flagLatitude == true)  { print("Latitude:\(string)")
//                 latitude = string
//             }
             
             //let item = (address,longitude,latitude)
             //print("item:\(item)")
             
             flagAddress = false
             flagLongitude = false
             flagLatitude = false
         }
        
        // タグの終わりが見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

            // タグが"results"ならば、タグが閉じられたので、XMLtag1,2をリセットする
            if elementName == "results" {
                print("おわり:")//確認ok
             XMLtag1 = ""
             XMLtag2 = ""
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

        // セルへの表示の準備
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            let feedItem = self.feedItems[indexPath.row]
//            cell.textLabel?.text = feedItem.title
                        cell.textLabel?.text = feedItem.address
            return cell
        }
    }

// 変更する？？？
    class FeedItem {
        var address: String!
        var longitude: String!
        var latitude: String!
    }

