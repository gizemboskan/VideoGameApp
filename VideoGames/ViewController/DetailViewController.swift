//
//  DetailViewController.swift
//  VideoGames
//
//  Created by Gizem Boskan on 14.07.2021.
//

import UIKit
import CoreData
class DetailViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailTextView: UITextView!
    @IBOutlet var favoriteBarButtonItem: UIBarButtonItem!
    
    var game: VideoGameModel!
    var videoGame: VideoGame!
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = game.name
        
        if game.isFav {
            favoriteBarButtonItem.tintColor = UIColor.red
        }
        
        imageView.image = UIImage(named: "PosterPlaceholder")
        VideoGameClient.downloadGameImage(path: game.backgroundImage) { data, error in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            self.imageView.image = image
        }
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        VideoGameClient.getGameDetails(id: String(game.id)) {videoGameDetail, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showErrorAlert(message: "could not fetch the details")
                    return
                }
                if let videoGameDetail = videoGameDetail {
                    self.detailTextView.text =
                        ("\(videoGameDetail.nameOriginal)\n" + "Release Date: \(videoGameDetail.released)\n" + "Metacritic Rate: \(videoGameDetail.metacritic)\n" + "\(videoGameDetail.welcomeDescription)").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                }
            }
        }
    }
    // MARK: - Helpers
    
    @IBAction func favoriteBarButtonItemTapped(){
        if game.isFav {
            favoriteBarButtonItem.tintColor = UIColor.gray
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"FavoriteVideoGames")
            
            fetchRequest.predicate = NSPredicate(format: "favoriteGameId = %@", "\(game.id)")
            do
            {
                let fetchedResults =  try context.fetch(fetchRequest) as? [NSManagedObject]
                
                for entity in fetchedResults! {
                    
                    context.delete(entity)
                }
                try context.save()
            }
            catch _ {
                print("Could not be deleted!")
            }
        } else {
            favoriteBarButtonItem.tintColor = UIColor.red
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let context = appDelegate.persistentContainer.viewContext
            let newGame = NSEntityDescription.insertNewObject(forEntityName: "FavoriteVideoGames", into: context)
            
            newGame.setValue(game.id, forKey: "favoriteGameId")
            
            do {
                try context.save()
            } catch  {
                print("Could not be saved!")
            }
        }
        game.isFav.toggle()
    }
}



