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
//        let feedUrl = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi? addr=新宿")!
        let feedUrl = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=%E6%96%B0%E5%AE%BF")! //新宿

        var feedItems = [FeedItem]()

        var currentElementName : String! // RSSパース中の現在の要素名
//        var currentTagName : String! // RSSパース中の現在のタグの名前
        

        var flagAddress : Bool = false
        var flagLongitude : Bool = false
        var flagLatitude : Bool = false

// ============================================================
        // １階層目のタグを覚えておく変数を用意する
        var XMLtag1:String! = ""
        var XMLtag2:String! = "" // ２階層目
        // 表示するテキストを入れる変数
//        var msg:String! = ""
        // タグを入れる変数
//        var tagName:String! = ""
        
        //タグの最初が見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            //self.currentElementName = nil
            
            // タグが results ならば 「resultsタグ」に入ったことを、XMLtag1に覚えておく
            if elementName == "results" { XMLtag1 = "results" }
            // タグが candidate ならば 「candidateタグ」に入ったことを、XMLtag2に覚えておく
            if elementName == "candidate" { XMLtag2 = "candidate" }
            // タグが address ならば
            if elementName == "address" { flagAddress = true }
            // タグが longitude ならば
            if elementName == "longitude" { flagLongitude = true }
            // タグが latitude ならば
            if elementName == "latitude" { flagLatitude = true }
            
            // タグ1が「results」で、タグ2が「candidate」に入った状態ならば、そのデータを取り出す
            if XMLtag1 == "results" && XMLtag2 == "candidate" {
                
                print("elementName:\(elementName)")//
            }
        }
            
        // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
         func parser(_ parser: XMLParser, foundCharacters string: String) {
             //if (flagAddress == true) && (flagLongitude == true) && (flagLatitude == true) {
             if (flagAddress == true)  { print(string) }
             if (flagLongitude == true)  { print(string) }
             if (flagLatitude == true)  { print(string) }
             
             flagAddress = false
             flagLongitude = false
             flagLatitude = false
             
//             if XMLtag1 == "results" && XMLtag2 == "candidate" {
//             print(string) //要素を表示する
//             }
         }
        
        // タグの終わりが見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            //self.currentElementName = nil
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
        
        

        override func viewDidLoad() {
            super.viewDidLoad()
            print("パース開始")
            
            let parser: XMLParser! = XMLParser(contentsOf: feedUrl)
            parser.delegate = self
            parser.parse()

            //print("feedUrl:\(feedUrl)")//新宿をサーチした結果がある
            //print(feedItems)
 
        }

        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    }

    class FeedItem {

        var address: String!
        var longitude: String!
        var latitude: String!
    }
