//
//  InstaFeedViewController.swift
//  Parstagram
//
//  Created by Roneil Sembrano on 3/20/20.
//  Copyright © 2020 Roneil Sembrano. All rights reserved.
//

import UIKit
import Parse

class InstaFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]//gets it from the Parse server
       // print("row is..........%@", indexPath.row)
        let comment = PFObject(className: "Comments")
        comment["text"] = "Great photo!"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")//array of comments, add this comment to the array
        post.saveInBackground { (success, error) in
            if success{
                print("comment saved")
            } else {
                print("error saving comment")
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        sceneDelegate.window?.rootViewController = loginViewController
    }
    
    
    @IBOutlet weak var feedTableView: UITableView!
    
     var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        //feedTableView.rowHeight = 300
        //used to work with the auto layout // put necessary constraints on name and comment label shift k
        feedTableView.rowHeight = UITableView.automaticDimension
        feedTableView.estimatedRowHeight = 50
        


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
     let query = PFQuery(className: "Posts")
     query.includeKeys(["author", "comments","comments.author"])
     query.limit = 20
     
     query.findObjectsInBackground { (posts, error) in
             if posts != nil {
             self.posts = posts!
            self.feedTableView.reloadData()
         }
     }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]//////
        let comments = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == 0{
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        
            let user = post["author"] as? PFUser//added ? for it to stop crashing
            cell.usernameLabel.text = user?.username!
        cell.captionLabel.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
       
        cell.photoView.af_setImage(withURL: url)
            
        return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
           // cell.heightAnchor.constraint(equalToConstant: 10.0)
            return cell
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
