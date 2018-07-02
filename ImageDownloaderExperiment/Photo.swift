import Foundation

struct Photo : Codable {
	let id : String
	let owner : String?
	let secret : String
	let server : String
	let farm : Int
	let title : String?
	let ispublic : Int?
	let isfriend : Int?
	let isfamily : Int?

    func imageURL(_ size:String = "s") -> String {
        let url =  "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_"
        return url
    }
}
