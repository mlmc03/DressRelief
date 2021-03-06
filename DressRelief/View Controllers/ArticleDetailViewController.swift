//
//  ArticleDetailViewController.swift
//  bFashionIster
//
//  Created by Mary Martinez on 12/22/16.
//  Copyright © 2016 Mary Martinez. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UITableViewController {
    
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var textureLabel: UILabel!

    var article: Article!
    var editButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ArticleDetailViewController.didTapEditButton))
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ArticleDetailViewController.didTapCancelButton))
        
        navigationItem.setRightBarButton(editButton, animated: true)
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        
        guard article != nil else {
            return
        }
        
        categoryLabel.text = article.category
        colorLabel.text = article.color
        textureLabel.text = article.texture
        Helper.set(article: article, in: articleImageView)
    }
    
    func didTapEditButton() {
        performSegue(withIdentifier: ArticleSegue.FromDetailToEditArticle.rawValue, sender: nil)
    }
    
    func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ArticleSegue.FromDetailToEditArticle.rawValue {
            let articleEditViewController = segue.destination as! ArticleEditViewController
            articleEditViewController.entryPoint = ArticleEntryPoint.edit.rawValue
            articleEditViewController.articleImage = articleImageView.image
            articleEditViewController.article = article
            articleEditViewController.articleType = article.articleType
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 15.0
        }
    }
}
