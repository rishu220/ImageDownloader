//
//  ViewController.swift
//  ImageDownloaderExperiment
//
//  Created by Rishu Goel on 30/06/18.
//  Copyright © 2018 Rishu Goel. All rights reserved.
//

import UIKit

fileprivate let itemsPerRow: CGFloat = 3

class ViewController: UIViewController,UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var seacrhBar: UISearchBar!
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    var lastQuery = ""
    var dataSource: [String] = []
    var lastPage = 0
    var totalResults = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard  let text = searchBar.text else {
            return
        }
        if lastQuery != text {
            dataSource = []
            getImageSearchModel(text: text)
            collectionView.reloadData()
        }
        lastQuery = text
    }

    func getImageSearchModel(text: String, page: Int = 1) {
        lastPage = page
        let urlString = "https://flickr.com/services/rest/?method=flickr.photos.search&tags=\(text)&api_key=8bed04e178177e9bbdbed5ec569de99a&format=json&nojsoncallback=1&per_page=15&page=\(page)"
        guard let url = URL(string: urlString) else {
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                return
            }
            do {
                let response = try JSONDecoder().decode(ImageSearchModel.self, from: data!)
                self.totalResults = Int(response.photos?.total ?? "") ?? 0
                self.addImages(response)
            }catch
            {
                print("error")
            }
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }

    func addImages(_ model: ImageSearchModel) {
        guard let photos = model.photos?.photo else { return }
        for photo in photos {
                dataSource.append(photo.imageURL())
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.setImageWithUrl(dataSource[indexPath.row]+"m.jpg", placeholderImage: UIImage(named: "ic_doctor_placeholder.png"), row: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        let controoler = ImageDisplayViewController.getController(thumbnail:cell.imageView.image, url: dataSource[indexPath.row])
        self.navigationController?.pushViewController(controoler, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= dataSource.count - 1  && dataSource.count < totalResults {
            getImageSearchModel(text: lastQuery, page: lastPage+1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


}

extension ViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

