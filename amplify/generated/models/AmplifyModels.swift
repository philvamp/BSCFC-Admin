// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "d2897633ef5ed3b240fc6feab5a298be"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: NoteData.self)
  }
}