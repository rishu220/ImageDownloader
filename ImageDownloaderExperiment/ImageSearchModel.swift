import Foundation


struct ImageSearchModel : Codable {
	let photos : Photos?
	let stat : String?

	enum CodingKeys: String, CodingKey {

		case photos = "photos"
		case stat = "stat"
	}
}
