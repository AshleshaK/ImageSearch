//
//  FirstViewController.swift
//  ImageSearch
//
//  Created by Mac on 04/12/21.
//

import UIKit

class FirstViewController: UIViewController {

    var imagesArray = [Result]()
    var images: Result?
    var loading_pages: APIResponse?
    var total_pages = 1
    var current_page = 1
    var fetchingMore: Bool = false
    let searchbar = UISearchBar()
    
    private var collectionview: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        view.addSubview(searchbar)
        collectionviewProperties()
       
                
    }
    
//MARK: CollectionviewProperties Function
    
    func collectionviewProperties(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .systemBackground
        view.addSubview(collectionview)
        self.collectionview = collectionview
    }
 
//MARK: ViewDidLayoutSubview Mathod
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionview?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
    }
  
//MARK: API Parsing
    
    func fetchPhotos(query: String, page: Int) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=\(query)&client_id=pKMdscKBbuRyt0XzuzwfRa78JyIZtFSWY-zDY4vOYgk"
      
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                   
                    self.total_pages = json.total_pages
                    self.imagesArray.append(contentsOf: json.results)
                    self.collectionview?.reloadData()
                }
            }
            catch
            {
                print(error)
            }
        }
        task.resume()
    }
    

}

//MARK: UICollectionViewDataSource

extension FirstViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = imagesArray[indexPath.row].urls.regular
        if let cell = collectionview?.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell {
            cell.backgroundColor = .systemBackground
            cell.configure(with: imageURLString)
            return cell
        }
       return UICollectionViewCell()
    }
    
    
}

//MARK: UICollectionViewDelegate

extension FirstViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let text = searchbar.text
        if current_page < total_pages && indexPath.row == imagesArray.count - 1 {
           current_page = current_page + 1
            fetchPhotos(query: text!, page: current_page)
            print(current_page)
        }
    }
}

//MARK: UISearchBarDelegate

extension FirstViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        if let text = searchbar.text {
            imagesArray = []
            let load_page = loading_pages?.total_pages
            collectionview?.reloadData()
            fetchPhotos(query: text, page: load_page ?? 1 )
          
        }
    }
}
