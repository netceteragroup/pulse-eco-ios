import Foundation

enum Errors: Error {
	case ServerError
	case ApiGatewayError
	case ParsingError
	case InternalError
	case PersistenceFailed
}
