// swiftlint:disable all
import Amplify
import Foundation

public struct NoteData: Model {
  public let id: String
  public var name: String
  public var description: String?
  public var agegroup: String?
  public var gender: String?
  public var location: String?
  public var tdate: String?
  public var time: String?
  public var isdeleted: String?
  public var realdate: Temporal.Date?
  public var realtime: Temporal.Time?
  public var contact: String?
  public var pitch: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      description: String? = nil,
      agegroup: String? = nil,
      gender: String? = nil,
      location: String? = nil,
      tdate: String? = nil,
      time: String? = nil,
      isdeleted: String? = nil,
      realdate: Temporal.Date? = nil,
      realtime: Temporal.Time? = nil,
      contact: String? = nil,
      pitch: String? = nil) {
    self.init(id: id,
      name: name,
      description: description,
      agegroup: agegroup,
      gender: gender,
      location: location,
      tdate: tdate,
      time: time,
      isdeleted: isdeleted,
      realdate: realdate,
      realtime: realtime,
      contact: contact,
      pitch: pitch,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      description: String? = nil,
      agegroup: String? = nil,
      gender: String? = nil,
      location: String? = nil,
      tdate: String? = nil,
      time: String? = nil,
      isdeleted: String? = nil,
      realdate: Temporal.Date? = nil,
      realtime: Temporal.Time? = nil,
      contact: String? = nil,
      pitch: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.description = description
      self.agegroup = agegroup
      self.gender = gender
      self.location = location
      self.tdate = tdate
      self.time = time
      self.isdeleted = isdeleted
      self.realdate = realdate
      self.realtime = realtime
      self.contact = contact
      self.pitch = pitch
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}