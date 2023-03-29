//
//  ViewController.swift
//  taskapp
//
//  Created by Teruo Yamamoro on 2023/03/19.
//

import UIKit
import RealmSwift
import UserNotifications

//UITableViewDelegate, UITableViewDataSourceを入れることで、ViewControllerをUITableViewの問い合わせ先に指定。
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //データを表示していない部分に罫線を表示するコード
        tableView.fillerRowHeight = UITableView.automaticDimension
        //ViewControllerに「UITableViewでアクションが起きたよー」というのを知らせる。
        tableView.delegate = self
        //ViewController側でセルの高さやサイズの計算など、動的にセルに関するデータを定義する処理を委譲する
        tableView.dataSource = self
        //delegataプロパティに、このクラスを代入する
        searchField.delegate = self
        searchField.placeholder = "カテゴリー検索"
    }
    // データの数（＝セルの数）を返すメソッド, セルは何個必要？
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド、どんなセルが必要？
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
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
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //searchBar.resignFirstResponder()
    //}
    
    // 入力]画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    //検索する処理
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print (searchText)
        if searchText.isEmpty {
            taskArray = realm.objects(Task.self)
            tableView.reloadData()
        } else {
            let predicate = NSPredicate(format: "category CONTAINS[c] %@", searchText)
            taskArray = realm.objects(Task.self).filter(predicate)
            tableView.reloadData()
            
        }
    }
}
