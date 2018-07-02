import Foundation

struct Photos : Codable {
	let page : Int?
	let pages : Int?
	let perpage : Int?
	let total : String?
	let photo : [Photo]?

	enum CodingKeys: String, CodingKey {

		case page = "page"
		case pages = "pages"
		case perpage = "perpage"
		case total = "total"
		case photo = "photo"
	}
}
