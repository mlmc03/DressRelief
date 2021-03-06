//
//  ArticleCollectionView.swift
//  bFashionIster
//
//  Created by Mary Martinez on 12/19/16.
//  Copyright © 2016 Mary Martinez. All rights reserved.
//

import UIKit
import RealmSwift

class ArticleCollectionView: MeuItemViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    var articles: Results<Article>!
    var items: Results<Article>!
    var subscription: NotificationToken?
    
    let itemsPerRow: CGFloat = 3
    let itemsPerCol: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    var selectedItem: Article!
    
    var editButton: UIBarButtonItem!
    var isEditingArticles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ArticleCell")
        
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(MyFavsViewController.didTapEditButton))
        navigationItem.setLeftBarButton(editButton, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        toggleHidden()
        toggleEditing(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toggleEditing(true)
    }
    
    func toggleHidden() {
        emptyImageView.isHidden = (items?.count == 0) ? false : true
    }
    
    func didTapEditButton() {
        isEditingArticles = !isEditingArticles
        editButton.title = isEditingArticles ? "Done" : "Edit"
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    func toggleEditing(_ willDisappear: Bool?) {
        let shouldHide = (items.count ?? 0) == 0 ? true : false
        
        if isEditingArticles {
            // there are no more items
            if shouldHide {
                isEditingArticles = false
                shouldDisplayEditButton(false)
                toggleHidden()
                return
            }

            // there still are items but I am leaving the view
            if let willDisappear = willDisappear {
                if willDisappear {
                    didTapEditButton()
                    return
                }
            }
            
            // there still are items and I am editing - do nothing
            
        } else {
            if !shouldHide {
                shouldDisplayEditButton(true)
            } else {
                shouldDisplayEditButton(false)
            }
        }
    }

    func shouldDisplayEditButton(_ shouldDisplay: Bool) {
        editButton.title = shouldDisplay ? "Edit" : ""
        editButton.isEnabled = shouldDisplay ? true : false
    }
    
    func animateEditing(cell: ArticleCollectionViewCell) {
        if isEditingArticles {
            UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                cell.closeButton.alpha += 1.0
            }, completion: nil)
            cell.wobble()
            
        } else {
            UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                cell.closeButton.alpha = 0
            }, completion: nil)
            cell.stopWobbling()
        }
    }
    
    func removeArticle(item: Article) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(item)
        }
    }
    
    // Mark: - Realm Subscription
    func notificationSubscription(for bottoms: Results<Article>) -> NotificationToken {
        return bottoms.addNotificationBlock({ [weak self] (changes: RealmCollectionChange<Results<Article>>) in
            self?.updateUI(with: changes)
        })
    }
    
    func updateUI(with changes: RealmCollectionChange<Results<Article>>) {
        switch changes {
        case .initial(_):
            print("article collection initial load")
            collectionView.reloadData()
        case .update(_, let deletions , let insertions, let modifications):
            print("article collection updates ... \ndel:\(deletions.count) \ninsert:\(insertions.count) \nmod:\(modifications.count)")
            collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                self.collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                self.collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
            }, completion: { _ in
                self.collectionView.reloadData()
            })
            break
        case let .error(error):
            print(error.localizedDescription)
        }
    }
}

// Mark: – UICollectionViewDataSource
extension ArticleCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard items != nil else {
            print("items are nil")
            return 0
        }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCollectionViewCell
        
        cell.item = items[indexPath.row]
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        self.animateEditing(cell: cell)
        
        return cell
    }
}
    
// Mark: - UICollectionViewDelegateFlowLayout
extension ArticleCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = self.sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        let availableHeight = view.frame.height - paddingSpace - 64.0 // navBar space
        let heightPerItem = availableHeight / itemsPerCol
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ArticleCollectionViewCell
        self.selectedItem = cell.item
        
        if isEditingArticles {
            // prompt to delete this favorite outfit
            let alertController = UIAlertController(title: "Delete Item?", message: "This will remove the item from your collection.", preferredStyle: UIAlertControllerStyle.alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result: UIAlertAction) -> Void in
                self.removeArticle(item: self.selectedItem)
                self.toggleEditing(nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
                print("canceled")
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let segueIdentifier = selectedItem.articleType == ArticleType.top.rawValue ? ArticleSegue.ToDetailFromTops.rawValue : ArticleSegue.ToDetailFromBottoms.rawValue
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
}
