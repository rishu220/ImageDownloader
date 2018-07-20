
import  UIKit


class ImageDownloadManager {
    static let shared = ImageDownloadManager()

    let operationQueue: OperationQueue!
    var map:[Int: NetworkOperation]!

    private init () {
        self.map = [:]
        self.operationQueue = OperationQueue()
    }

    func fetchImageWith(urlString: NSString, row: Int, completionHandler: @escaping CompletionHandler) {
        if map[row] == nil {
            let operation = NetworkOperation(url: urlString , completionHandler: completionHandler)
            operation.qualityOfService = .userInteractive
            operationQueue.addOperation(operation)
        }else {
            if let task = map[row] {
                task.qualityOfService = .userInteractive
                if let task2 = map[row-15] {
                    reducePriority(row: row-15)
                }

            }
        }
    }

    func reducePriority(row: Int) {
        if let task = map[row]  {
            task.qualityOfService = .background
        }
    }
}

class NetworkOperation: Operation {

    let url : NSString!
    let completionHandler: (_ image: UIImage?) -> Void

    init(url : NSString, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        self.url = url
        self.completionHandler = completionHandler
    }

    override func main() {

        guard let url = URL(string: self.url as String) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpRespose = response as? HTTPURLResponse, httpRespose.statusCode == 200 {
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        self.completionHandler(image)
                    }
                }
            } else {
                print("HTTP  Error: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
        }
        task.resume()
    }
}
