//
//  EventTableViewController.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
/*
class EventTableViewController: UITableViewController {

    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView setSeparatorColor:[UIColor.black]
        
        // Create some Taco Stands
        events.append(Event(name: "EE Club Meeting", organizer: "IEEE", food: "Tacos", location: "San Luis Obispo, CA 93407")!)
        events.append(Event(name: "Networking Session", organizer: "Cisco", food: "Pasta", location: "170 West Tasman Dr., San Jose, CA 95134")!)
        events.append(Event(name: "Hackathon", organizer: "UC San Diego", food: "Subway", location: "9500 Gilman Dr, La Jolla, CA 92093")!)
        events.append(Event(name: "Panel", organizer: "Google", food: "Burgers", location: "1600 Amphitheatre Pkwy, Mountain View, CA 94043")!)
        events.append(Event(name: "event5", organizer: "organizer5", food: "food5", location: "901 Cherry Ave. San Bruno, CA 94066")!)
        events.append(Event(name: "event6", organizer: "organizer6", food: "food6", location: "1 Hacker Way, Menlo Park, 94025")!)
        events.append(Event(name: "event7", organizer: "organizer7", food: "food7", location: "Hawthorne, California")!)
        events.append(Event(name: "event8", organizer: "organizer8", food: "food8", location: "6950 El Camino Real, Atascadero, CA 93422")!)
        events.append(Event(name: "event9", organizer: "organizer9", food: "food9", location: "Apple Campus, Cupertino, CA 95014")!)
        events.append(Event(name: "event10", organizer: "organizer10", food: "food10", location: "81226 Seattle, WA 98108-1226")!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EventTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EventTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let event = events[indexPath.row]
        
        cell?.eventLabel.text = event.name
        cell?.foodLabel.text = event.food
        cell?.locationLabel.text = event.location
        cell?.organizerLabel.text = event.organizer
        
        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showSelectedEvent" {
            let destinationVC = segue.destination as? UINavigationController
            let destVC = destinationVC?.viewControllers[0] as? ViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destVC?.dataFromTable = events[(selectedIndexPath?.row)!].location
        }
        
    }
    
    
    @IBAction func unwindFromDetail(segue:UIStoryboardSegue) {
        
    }
}
 */
