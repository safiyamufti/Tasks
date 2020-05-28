//
//  ViewController.swift
//  Tasks
//
//  Created by Safiya Mufti on 2020-05-05.
//  Copyright © 2020 Safiya Mufti. All rights reserved.
//
import UserNotifications
import UIKit

class ViewController: UIViewController {
    @IBOutlet var table: UITableView! // this outlet helps us control the table on storyboard
    
    var models = [MyReminder]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
        @IBAction func didTapAdd() {
            // show add vc
            guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
                return
            }
            vc.title = "New Task"
            vc.navigationItem.largeTitleDisplayMode = .never
            // next line brings content out of that controller
            vc.completion = { title, body, date in
                // next thing we want to do is dismiss the add controller on the main queue
                // since all UI related updates should happen on the main queue.
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(title: title, date: date, identifier: "id_\(title)")
                // add new to our model
                    self.models.append(new)
                    self.table.reloadData() // we have a new reminder we want to show it on the screen
                    // next step is to schedule this notification
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.sound = .default
                    content.body = body
                    
                    let targetDate = date
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                              from: targetDate),
                                                                repeats: false)
                    let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                        if error != nil {
                            print("something went wrong")
                            
                        }

                    })
                    
                }
                
            }
            // push animation
            navigationController?.pushViewController(vc, animated: true)
            
    }
        @IBAction func didTapTest() {
            // fire test notif
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
                if success {
                    // schedule test
                    self.scheduleTest()
                }
                else if error != nil {
                    print("error occurred")
                }
                
            })
        }
    func scheduleTest() {
        // NOTIF has 3 main parts. 1) Request Notif centre 2) Content parameter 3) Trigger (date)
        let content = UNMutableNotificationContent()
        content.title = "Hello There!"
        content.sound = .default
        content.body = "My test body"
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                  from: targetDate),
                                                    repeats: false)
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if error != nil {
                print("something went wrong")
                
            }
        })
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = models[indexPath.row].title
    let date = models[indexPath.row].date
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM, dd, YYYY at hh:mm a"
    cell.detailTextLabel?.text = formatter.string(from: date)
    
    return cell
    }
}

// struct to hold reminder objects
struct MyReminder {
    let title: String
    let date: Date
    let identifier: String
}
