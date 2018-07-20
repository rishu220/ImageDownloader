import UIKit

// MARK: ImageView extension -
extension UIImageView {
    func setImageWithUrl(_ urlString: String, placeholderImage: UIImage?, row: Int = 0) {
        self.image = placeholderImage
        self.tag = row
        let url = NSString(string: urlString)
        ImageDownloadManager.shared.fetchImageWith(urlString: url, row: row) { (image) in
            DispatchQueue.main.async {
                if image != nil, self.tag == row {
                    self.image = image
                }
            }
        }
    }

}

// MARK: - Caching mechanism -
typealias CompletionHandler = (_ image: UIImage?) -> Void

class ObjcetHandlerModel: NSObject {
    var instance: AnyObject
    var completionBlock: CompletionHandler

    init(withRequestingInstance instance: AnyObject, completionHandler: @escaping CompletionHandler) {
        self.instance = instance
        self.completionBlock = completionHandler
    }
}

class ImageObjectHandleModel: NSObject {
    var image: UIImage?
    var requestArray: Array<ObjcetHandlerModel> = []
}

class ImageCache: NSObject {

    static let sharedInstance: ImageCache = ImageCache()

    var objectUrlMapper: NSCache<AnyObject, NSString> = NSCache<AnyObject, NSString>()
    var urlImageMapper: NSCache<NSString, ImageObjectHandleModel> = NSCache<NSString, ImageObjectHandleModel>()

    func fetchImageWith(urlString: NSString, forInstance instance: AnyObject, row: Int, completionHandler: @escaping CompletionHandler) {
        // Object had requested for an image earlier and the task is not completed.
        if let _: NSString = objectUrlMapper.object(forKey: instance) {
            removeCompletionHandlerForInstance(instance: instance)
        }

        if let imageModel: ImageObjectHandleModel = urlImageMapper.object(forKey: urlString) {
            if imageModel.image != nil {
                // Image model exists but no pending requests, which implies that the image has been fetched
                completionHandler(imageModel.image)
            } else {
                // Image model exists with pending requests. Adding new request to array.
                objectUrlMapper.setObject(urlString, forKey: instance)
                imageModel.requestArray.append(ObjcetHandlerModel(withRequestingInstance: instance, completionHandler: completionHandler))
            }
        } else {
            if let imageUrl = URL(string: urlString as String ) {
                let imageObject: ImageObjectHandleModel = ImageObjectHandleModel()
                imageObject.requestArray = [ObjcetHandlerModel(withRequestingInstance: instance, completionHandler: completionHandler)]
                urlImageMapper.setObject(imageObject, forKey: urlString)
                objectUrlMapper.setObject(urlString, forKey: instance)
            } else {
                print("fetchImageWith(urlString:, forInstance, completionHandler) Error creating image url")
            }
        }
    }

    

    func didDownloadImage(image: UIImage?, forUrl imageUrl: URL) {
        let urlString: NSString = imageUrl.absoluteString as NSString

        if let imageModel: ImageObjectHandleModel = urlImageMapper.object(forKey: urlString) {
            imageModel.image = image
            for request in imageModel.requestArray {
                request.completionBlock(image)
            }
            var request: ObjcetHandlerModel? = imageModel.requestArray.first
            while request != nil {
                removeCompletionHandlerForInstance(instance: request!.instance)
                request = imageModel.requestArray.first
            }
        } else {
            let imageObject: ImageObjectHandleModel = ImageObjectHandleModel()
            urlImageMapper.setObject(imageObject, forKey: urlString)
        }
    }

    func removeCompletionHandlerForInstance(instance: AnyObject) {
        if let urlString: NSString = objectUrlMapper.object(forKey: instance) {
            objectUrlMapper.removeObject(forKey: instance)
            if let imageModel: ImageObjectHandleModel = urlImageMapper.object(forKey: urlString) {
                for request in imageModel.requestArray where request.instance.isEqual(instance) {
                    imageModel.requestArray.remove(at: imageModel.requestArray.index(of: request)!)
                    return
                }
            }
        }
    }
}
