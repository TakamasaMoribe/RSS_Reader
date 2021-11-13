//
//  ViewController.swift
//  RssReader
//
//  Created by Kiyoshi Mizumoto on 2018/04/12.
//  Copyright © 2018年 Kiyoshi Mizumoto. All rights reserved.
//
//  Created by 森部高昌 on 2021/10/24.

    import UIKit

    class ViewController: UIViewController, UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
        
        @IBOutlet weak var searchText: UISearchBar!

        @IBOutlet weak var tableView: UITableView!

        // feedUrl：tableViewで選択したものを代入するようにする
        var feedUrl = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=%E6%96%B0%E5%AE%BF")! //新宿
//        var feedUrl:URL = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi")! //東大
        var feedItems = [FeedItem]() // tableViewの表示に使っている
        var currentElementName:String! // パース中に、読み出している項目名
        
// -------------------------------------------------------------------------------
        override func viewDidLoad() {
            super.viewDidLoad()
            
            searchText.delegate = self
            searchText.placeholder = "検索する地名を入力"

            print("パース開始")
            // このあと。検索結果を返す
            // 検索結果のアドレスは、以下のように得られている
            // 検索地名:戸田
            // feedUrl:https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=%E6%88%B8%E7%94%B0
            // tableView へは表示されない
            print("feedUrl初期値：\(feedUrl)") //初期値が表示される
            // パースの前に　検索結果のアドレスをfeedUrlへ代入する必要がある
//            let parser: XMLParser! = XMLParser(contentsOf: feedUrl) //feedUrlの中身をパースする？
//            parser.delegate = self
//            parser.parse()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
//-----------------------------------------------------------------------------
        // searchBarへの入力に対する処理
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            //キーボードを閉じる
            view.endEditing(true)
            if let searchWord = searchBar.text {
                print("検索地名:\(searchWord)") // キーボードからsearchBarに入力した地名の表示
            //入力されていたら、地名を検索する
                searchPlace(keyword: searchWord)
            }
        }
        // 地名の検索  searchPlace メソッド
        // 第一引数：keyword 検索したい語句
        func searchPlace(keyword:String) {
            // keyword をurlエンコードする
            guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            // keyword_encode を使って、リクエストurlを組み立てる
            guard let req_url = URL(string: "https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=\(keyword_encode)") else {
                return
            }
            
            // リクエストに必要な情報を生成する 正しく生成されている
            let req = URLRequest(url: req_url)
            feedUrl = req_url
            
            // 地名検索の結果（候補）は得られているので、これをtabaleViewに表示して、そこから目的地を選ぶようにする。
            let task = URLSession.shared.dataTask(with: req, completionHandler: {(data,response,error) in
                let parser: XMLParser! = XMLParser(contentsOf: self.feedUrl) //feedUrlの中身をパースする？
  //              let parser:XMLParser? = XMLParser(data:data!)
                parser!.delegate = self
                parser!.parse()//ここでエラー
            })

            // ダウンロード開始
            task.resume() // 入力された地名を検索する・・・OK
            print("feedUrl:\(feedUrl)")//入力されていたら、地名の検索結果があるアドレスを表示する。
        }
        
        //-----------------------------------------------------------------------------
        
        //-----------------------------------------------------------------------------
        //タグの最初が見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            self.currentElementName = nil // 初期化
            if elementName == "address" {
                currentElementName = "address" //
                self.feedItems.append(FeedItem()) // tableViewに表示する配列に追加
            } else {
               currentElementName = elementName
            }
        }
        
        // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド。stringが得られる
         func parser(_ parser: XMLParser, foundCharacters string: String) {
             
             if string != "\n" { // 改行でなければ読み取る
                 
                 if self.feedItems.count > 0 {
                     let lastItem = self.feedItems[self.feedItems.count - 1]
                     
                    switch self.currentElementName {
                     case "address":
                         let tmpString = lastItem.address
                         lastItem.address = (tmpString != nil) ? tmpString! + string : string
                         print("address:\(string)") // 確認用
                     case "longitude":
                         let tmpString = lastItem.longitude
                         lastItem.longitude = (tmpString != nil) ? tmpString! + string : string
                         print("longitude:\(string)") // 確認用
                     case "latitude":
                         let tmpString = lastItem.latitude
                         lastItem.latitude = (tmpString != nil) ? tmpString! + string : string
                         print("latitude:\(string)") // 確認用
                     default:
                         break
                    }
                }
             }
         }
        
        // タグの終わりが見つかったとき呼ばれる
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        }
 
        // sent when the parser has completed parsing. If this is encountered, the parse was successful.
        func parserDidEndDocument(_ parser: XMLParser) {
            self.tableView.reloadData() //ここでエラーが出る
            // UITableView.reloadData() must be used from main thread only
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

        // セルを選択したとき
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let feedItem = self.feedItems[indexPath.row]
            
            print("選択した地点:\(feedItem.address!)") //確認用
            print("選択した地点:\(feedItem.longitude!)") //確認用
            print("選択した地点:\(feedItem.latitude!)") //確認用
        }
        
    }


//
class FeedItem {
    var address: String!
    var longitude: String!
    var latitude: String!
    }

