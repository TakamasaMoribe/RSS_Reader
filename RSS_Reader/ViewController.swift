//
//  ViewController.swift
//  RssReader
//
//  Created by 森部高昌 on 2021/11/14.

    import UIKit

    class ViewController: UIViewController, UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
        
        @IBOutlet weak var searchText: UISearchBar!

        @IBOutlet weak var tableView: UITableView!

        // feedUrl：tableViewで選択したものを代入するようにする？？？？？ちがう？？
//        var feedUrl:URL = URL(string:"https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi")! //東大
        var feedUrl:URL = URL(string:"Dummy")! //初期化 何か入れていないとエラーになるのでDummyとした
        var feedItems = [FeedItem]() // tableViewの表示に使っている
        var currentElementName:String! // パース中に、読み出している項目名
        
// -------------------------------------------------------------------------------
        
        override func viewDidLoad() {
            super.viewDidLoad()
            searchText.delegate = self
            searchText.placeholder = "検索する地名を入力してください"
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
                print("①検索地名:\(searchWord)") // キーボードからsearchBarに入力した地名の表示 ①
            //入力されていたら、地名を検索する
                searchPlace(keyword: searchWord)
            }
        }
        
        // 地名の検索  searchPlaceメソッド 第一引数：keyword 検索したい語句
        func searchPlace(keyword:String) {
            // keyword をurlエンコードする
            guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            // keyword_encode を使って、リクエストurlを組み立てる
            guard let req_url = URL(string: "https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=\(keyword_encode)") else {
                return
            }
            
            feedUrl = req_url // パースするときに使っている
            print("②feedUrl:\(feedUrl)")//入力されていたら、地名の検索結果があるアドレスを表示する。②
            print("パース開始")
                let parser: XMLParser! = XMLParser(contentsOf: feedUrl) //feedUrlの中身をパースする
                parser.delegate = self
                parser.parse()
            self.tableView.reloadData() //tableViewへ表示
        }
        
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
            print("パース終了")
        }

        
//-----------------------------------------------------------------------------
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


// ============================================================//
class FeedItem {
    var address: String!
    var longitude: String!
    var latitude: String!
    }

