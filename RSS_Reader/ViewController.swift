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
        var currentTagName : String! // RSSパース中の現在のタグの名前
        
        let ITEM_ELEMENT_NAME = "item"
//        let ITEM_ELEMENT_NAME = "address"
        let TITLE_ELEMENT_NAME = "title"
        let LINK_ELEMENT_NAME   = "link"
        let ADDRESS_ELEMENT_NAME = "address"
        let LONGITUDE_ELEMENT_NAME = "longitude"
        let LATITUDE_ELEMENT_NAME = "latitude"
        let CANDIDATE_ELEMENT_NAME = "candidate"

// ============================================================
        // １階層目のタグを覚えておく変数を用意する
        var XMLtag1:String! = ""
        // 表示するテキストを入れる変数
        var msg:String = ""
        // タグを入れる変数
        var tagName:String = ""
        
        //タグの最初が見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            //self.currentElementName = nil
            // タグが results ならば 「resultsタグ」に入ったことを、XMLtag1に覚えておく
            if elementName == "results" {
                XMLtag1 = "results"
            }
            // タグが「candidate」で、すでに「resultsタグ」に入った状態ならば、そのデータを取り出す
            if elementName == "candidate" && XMLtag1 == "results" {
                print(XMLtag1)//
                print(elementName)//
                
//                switch tagName {
//                case <#pattern#>:
//                    <#code#>
//                default:
//                    <#code#>
//                }
                // 属性「address」の文字を取り出してmsg変数に追加する
                if let addressName = attributeDict["address"]  {
                    msg += "住所:\(addressName)\n"
                    print(msg)
                }
                // 属性「longitude」の文字を取り出してmsg変数に追加する
                if let longitude = attributeDict["longitude"]  {
                    msg += "経度:\(longitude)\n"
                }
            }
        }
        
        // タグの終わりが見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            //self.currentElementName = nil
            // タグが"results"ならば、タグが閉じられたので、XMLtag1をリセットする
            if elementName == "results" {
             XMLtag1 = ""
                print(msg)
            }
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
        
//        // セルを選択したときに、webページを表示する
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let feedItem = self.feedItems[indexPath.row]
//            UIApplication.shared.open(URL(string: feedItem.url)!, options: [:], completionHandler: nil)
//        }
        
        
//        //タグの最初が見つかったとき呼ばれる
//        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//            self.currentElementName = nil
//            if elementName == ITEM_ELEMENT_NAME {
//                self.feedItems.append(FeedItem())
//            } else {
//                currentElementName = elementName
//            }
//        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if self.feedItems.count > 0 {
                let lastItem = self.feedItems[self.feedItems.count - 1]
                switch self.currentElementName {
//                case TITLE_ELEMENT_NAME:
//                    let tmpString = lastItem.title
//                    lastItem.title = (tmpString != nil) ? tmpString! + string : string
//                    print(lastItem.title) //
//                    print(feedItems)
//                case ADDRESS_ELEMENT_NAME:
//                    let tmpString = lastItem.title
//                    lastItem.title = (tmpString != nil) ? tmpString! + string : string
//                    print(lastItem.title) //
//                    print(feedItems)
                                    case ADDRESS_ELEMENT_NAME:
                                        let tmpString = lastItem.address
                                        lastItem.address = (tmpString != nil) ? tmpString! + string : string
                                        print(lastItem.address) //
                                        print(feedItems)
//                case LINK_ELEMENT_NAME:
//                    lastItem.url = string //
//                    print(lastItem.url)
                default: break
                }
            }
        }
        
//        // タグの終わりが見つかったとき呼ばれる
//        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//            self.currentElementName = nil
//        }
        
        func parserDidEndDocument(_ parser: XMLParser) {
            self.tableView.reloadData()
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            
            let parser: XMLParser! = XMLParser(contentsOf: feedUrl)
            parser.delegate = self
            parser.parse()
            print(feedUrl)//新宿をサーチした結果がある
            print(feedItems)
 
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    }

    class FeedItem {
 //       var title: String!
 //       var url: String!
        var address: String!
        var longitude: String!
        var latitude: String!
    }
