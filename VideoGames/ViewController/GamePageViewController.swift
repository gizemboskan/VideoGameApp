//
//  GamePageViewController.swift
//  VideoGames
//
//  Created by Gizem Boskan on 11.07.2021.
//

import UIKit

class GamePageView: UIImageView {
    func setImage(from urlString: String) {
        VideoGameClient.downloadGameImage(path: urlString){ data, error in
            DispatchQueue.main.async {
                guard let data = data else { return }
                self.image = UIImage(data: data)
            }
        }
    }
}

class GamePageViewController: UIPageViewController {
    fileprivate var items: [UIViewController] = []
    
    private var gameSource: [VideoGameModel]?
    private var currentIndex: Int?
    var index = 0
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        decoratePageControl()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goDetail(_:))))
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
    }
    
    func populateItems(gameSource: [VideoGameModel]) {
        self.gameSource?.removeAll()
        self.items.removeAll()
        self.gameSource = gameSource
        for game in gameSource {
            let c = UIViewController()
            let gameView = GamePageView(frame: view.frame)
            c.view.addSubview(gameView)
            gameView.setImage(from: game.backgroundImage)
            items.append(c)
        }
        
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    @objc func changeImage(){
        goToNextPage()
    }
    
    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
    }
    
    fileprivate func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [GamePageViewController.self])
        pc.currentPageIndicatorTintColor = .orange
        pc.pageIndicatorTintColor = .gray
    }
    
    @objc func goDetail(_ gesture: UITapGestureRecognizer) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "GameDetail") as? DetailViewController,
           let currentIndex = self.currentIndex,
           let gameSource = self.gameSource {
            vc.game = gameSource[currentIndex]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - DataSource
extension GamePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = items.firstIndex(of: firstViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
    }
    
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return items.last
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
            return items.first
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers?.first,
               let index = items.firstIndex(of: currentViewController) {
                currentIndex = index
            }
        }
    }
}

