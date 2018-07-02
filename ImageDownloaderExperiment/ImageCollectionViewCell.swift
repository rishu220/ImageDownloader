//
//  ImageCollectionViewCell.swift
//  ImageDownloaderExperiment
//
//  Created by Rishu Goel on 30/06/18.
//  Copyright © 2018 Rishu Goel. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "ic_doctor_placeholder.png")
    }
}
