//
//  ViewController.swift
//  taskapp
//
//  Created by Teruo Yamamoro on 2023/03/19.
//

import UIKit
//UITableViewDelegate, UITableViewDataSourceを入れることで、ViewControllerをUITableViewの問い合わせ先に指定。
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //データを表示していない部分に罫線を表示するコード
        tableView.fillerRowHeight = UITableView.automaticDimension
        //ViewControllerに「UITableViewでアクションが起きたよー」というのを知らせる。
        tableView.delegate = self
        //ViewController側でセルの高さやサイズの計算など、動的にセルに関するデータを定義する処理を委譲する
        tableView.dataSource = self
    }
    // データの数（＝セルの数）を返すメソッド, セルは何個必要？
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 0
            }
    
    // 各セルの内容を返すメソッド、どんなセルが必要？
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // 再利用可能な cell を得る
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            return cell
            }

    // 各セルを選択した時に実行されるメソッド
    //セルをタップした時に呼ばれるメソッド（セルをタップした時にタスク入力画面に遷移させる）
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segueのIDを指定して遷移させる
        performSegue(withIdentifier: "cellSegue",sender: nil)
        }

    // セルが削除が可能なことを伝えるメソッド
    //セルが削除可能かどうか、並び替えが可能かどうかなどどのように編集ができるかを返す(今回は削除を可能に.delete）
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
            return .delete
        }

    //Deleteボタンが押された時に呼ばれるメソッド
    //セルが削除されるときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        }
}

