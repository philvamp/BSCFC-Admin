//
//  Backend.swift
//  BSCFC Admin App
//
//  Created by Phil Vamplew on 21/09/2023.
//


import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
//import AWSS3StoragePlugin
import ClientRuntime
//import class Amplify.List

class Backend  {
    
    enum AuthStatus {
        case signedIn
        case signedOut
        case sessionExpired
    }
    
    static let shared = Backend()
        
    private init() {
        // initialize amplify
        do {
//            Amplify.Logging.logLevel = .info
            // reduce verbosity of AWS SDK
            SDKLoggingSystem.initialize(logLevel: .warning)

            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            
            try Amplify.configure()
            print("Initialized Amplify")
        } catch {
            print("Could not initialize Amplify: \(error)")
        }

    }

    public func getInitialAuthStatus() async throws -> AuthStatus {
        // let's check if user is signedIn or not
        let session = try await Amplify.Auth.fetchAuthSession()
        return session.isSignedIn ? AuthStatus.signedIn : AuthStatus.signedOut
    }
    
    public func listenAuthUpdate() async -> AsyncStream<AuthStatus> {
        
        return AsyncStream { continuation in
            
            continuation.onTermination = { @Sendable status in
                       print("[BACKEND] streaming auth status terminated with status : \(status)")
            }
            
            // listen to auth events.
            // see https://github.com/aws-amplify/amplify-ios/blob/master/Amplify/Categories/Auth/Models/AuthEventName.swift
            let _  = Amplify.Hub.listen(to: .auth) { payload in
                
                switch payload.eventName {
                    
                case HubPayload.EventName.Auth.signedIn:
                    print("==HUB== User signed In, update UI")
                    continuation.yield(AuthStatus.signedIn)
                case HubPayload.EventName.Auth.signedOut:
                    print("==HUB== User signed Out, update UI")
                    continuation.yield(AuthStatus.signedOut)
                case HubPayload.EventName.Auth.sessionExpired:
                    print("==HUB== Session expired, show sign in aui")
                    continuation.yield(AuthStatus.sessionExpired)
                default:
                    //print("==HUB== \(payload)")
                    break
                }
            }
        }
    }
    
    public func signIn() async {
        
        do {
            let result = try await Amplify.Auth.signInWithWebUI(options: .preferPrivateSession())
            if (result.isSignedIn) {
                print("Sign in succeeded")
            } else {
                print("Signin failed or required a next step")
            }
        } catch {
            print("Error while presenting web ui : \(error)")
        }
    }
    
    // signout
    public func signOut() async {
        
        let _ =  await Amplify.Auth.signOut()
    }
    
    // MARK: API Access
    
 func queryNotes() async -> [ Note ] {
        do {
            print("Loading notes")
            
            let queryResult = try await Amplify.API.query(request: .list(NoteData.self))

      
            print("Successfully retrieved list of Notes")
            
            // convert [ NoteData ] to [ Note ]
            let result = try queryResult.get().map { noteData in
                Note.init(from: noteData)
            }

            print("Successfully convert NoteData to Note")
            
            
            let now = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
            let filterednotes  = result.filter {anote in (anote.realdate! > yesterday!)}

            
            


            
            
            
            
            

            // in real life you probably want to sort on the server side
            // to do this, you need to implement your own query
            // https://docs.amplify.aws/lib/graphqlapi/advanced-workflows/q/platform/ios/#subset-of-data
            // and use a query + sort
            // https://docs.amplify.aws/guides/api-graphql/query-with-sorting/q/platform/ios/#implementation
            
            return filterednotes.sorted { lhs, rhs in
                if let ldate = lhs.createdAt, let rdate = rhs.createdAt {
                    return ldate > rdate
                } else {
                    return false
                }
            }

        } catch let error as APIError {
            print("Failed to load data from api : \(error)")
        } catch {
            print("Unexpected error while calling API : \(error)")
        }
        return []
        
    }
    
    func createNote(note: Note) async {
        
        do {
            let result = try await Amplify.API.mutate(request: .create(note.data))
            let data = try result.get()
            print("Successfully created note: \(data)")
        } catch let error as APIError {
            print("Failed to create note: \(error)")
        } catch {
            print("Unexpected error while calling create API : \(error)")
        }

    }
    
    func deleteNote(note: Note) async {
        
        do {
            let result = try await Amplify.API.mutate(request: .delete(note.data))
            let data = try result.get()
            print("Successfully deleted note: \(data)")
            
        } catch let error as APIError {
            print("Failed to delete note: \(error)")
        } catch {
            print("Unexpected error while calling delete API : \(error)")
        }
    }
}

struct EnvironmentVariable {

    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}
