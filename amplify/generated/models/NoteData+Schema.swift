// swiftlint:disable all
import Amplify
import Foundation

extension NoteData {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case description
    case agegroup
    case gender
    case location
    case tdate
    case time
    case isdeleted
    case realdate
    case realtime
    case contact
    case pitch
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let noteData = NoteData.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "NoteData"
    model.syncPluralName = "NoteData"
    
    model.attributes(
      .index(fields: ["id", "realdate"], name: "byBookingDate"),
      .primaryKey(fields: [noteData.id])
    )
    
    model.fields(
      .field(noteData.id, is: .required, ofType: .string),
      .field(noteData.name, is: .required, ofType: .string),
      .field(noteData.description, is: .optional, ofType: .string),
      .field(noteData.agegroup, is: .optional, ofType: .string),
      .field(noteData.gender, is: .optional, ofType: .string),
      .field(noteData.location, is: .optional, ofType: .string),
      .field(noteData.tdate, is: .optional, ofType: .string),
      .field(noteData.time, is: .optional, ofType: .string),
      .field(noteData.isdeleted, is: .optional, ofType: .string),
      .field(noteData.realdate, is: .optional, ofType: .date),
      .field(noteData.realtime, is: .optional, ofType: .time),
      .field(noteData.contact, is: .optional, ofType: .string),
      .field(noteData.pitch, is: .optional, ofType: .string),
      .field(noteData.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(noteData.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension NoteData: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}