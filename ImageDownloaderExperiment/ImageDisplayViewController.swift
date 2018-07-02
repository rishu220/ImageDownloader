//
//  ImageDisplayViewController.swift
//  ImageDownloaderExperiment
//
//  Created by Rishu Goel on 02/07/18.
//  Copyright © 2018 Rishu Goel. All rights reserved.
//

import UIKit

class ImageDisplayViewController: UIViewController {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!

    var image : UIImage?
    var url: String!

    class func getController(thumbnail: UIImage?, url: String) -> ImageDisplayViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ImageDisplayViewController") as! ImageDisplayViewController
        controller.image = thumbnail
        controller.url = url
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.thumbnailView.image = image
        self.url = self.url + "b.jpg"
        self.mainImageView.setImageWithUrl(self.url, placeholderImage: nil)
        // Do any additional setup after loading the view.
    }

}
