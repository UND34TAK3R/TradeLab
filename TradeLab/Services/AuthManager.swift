//
//  AuthManager.swift
//  TradeLab
//
//  Created by Derrick Mangari on 2025-10-29.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject{
    //Singleton Pattern
    static let shared = AuthManager()
    
    @Published var currentUser: AppUser?
    
    // db reference
    private let db = Firestore.firestore()
    
    //sign up
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<AppUser, Error>) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let user = result?.user else {
                return completion(.failure(SimpleError("Unable to create user")))
            }
            guard let defaultImage = UIImage(named: "default-profile"),
                  let imageData = defaultImage.jpegData(compressionQuality: 0.8)else{
                return completion(.failure(SimpleError("Unable to compress profile image")))
            }
            // uid -> FirebasAuth (user) --> uid (Firestore)
            let uid = user.uid //Firebase Auth.User
            //Convert image data to encoded String
            let imageString = imageData.base64EncodedString()
            // create app user obj
            let appUser = AppUser(id: uid, email: email, displayName: displayName, picture: imageString)
            // database query
            do{
                try self.db.collection("users").document(uid).setData(from: appUser){
                    error in
                    if let error = error{
                        return completion(.failure(error))
                    }
                    //have the user
                    DispatchQueue.main.async {
                        self.currentUser = appUser
                    }
                }
            }catch{
                completion(.failure(error))
            }
        }
    }
    
    
    //login
    func login(email: String, password: String, completion: @escaping (Result<AppUser, Error>)
               -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error{
                completion(.failure(error))
            }else if let user = result?.user{
                // fetch the appuser from the database
                // set it to the currentUser
                self.fetchCurrentAppUser{
                    res in
                    switch res{
                    case.success(let appUserObj):
                        if let appUser = appUserObj{
                            completion(.success(appUser))
                        }
                        else{
                            //auth service mismatch with the firestore
                            let email = result?.user.email ?? "unknown"
                            let name = result?.user.displayName ?? "Anonymous"
                            guard let defaultImage = UIImage(named: "default-profile"),
                                  let imageData = defaultImage.jpegData(compressionQuality: 0.8)else{
                                return completion(.failure(SimpleError("Unable to compress profile image")))
                            }
                            let imageString = imageData.base64EncodedString()
                            let appUser = AppUser(id: user.uid, email: email, displayName: name, picture: imageString)
                            
                            //push it to firestore
                            do {
                                try self.db.collection("users").document(user.uid).setData(from: appUser){
                                    error in
                                    if let error = error{
                                        completion(.failure(error))
                                    }
                                    DispatchQueue.main.async {
                                        self.currentUser = appUser
                                    }
                                    completion(.success(appUser))
                                }
                            }catch{
                                completion(.failure(error))
                            }
                        }
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            }
        }
    }
    
    
    //fetch user details
    func fetchCurrentAppUser(completion: @escaping (Result<AppUser?, Error>)-> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return completion(.success(nil))
        }// end of guard statement
        db.collection("users").document(uid).getDocument{
            snap, error in
            if let error = error{
                return completion(.failure(error))
            }
            guard let snap = snap else{
                return completion(.success(nil))
            }
            do{
                let user = try snap.data(as: AppUser.self)
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                completion(.success(user))
            }catch{
                completion(.failure(error))
            }
        }
    }
    
    //update user details
    
    //signout
    func signOut() -> Result<Void, Error> {
        do{
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return .success(())
        }catch{
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    //function to update display name
    func updateDisplayName(displayName: String, completion: @escaping (Result<Void, Error>)->Void){
        //uid
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success(()))
        }
        db.collection("users").document(uid).updateData(["displayName": displayName]){
            error in
            if let error = error{
                return completion(.failure(error))
            }else{
                //refetch the user object
                self.fetchCurrentAppUser{ _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    //Function to update profile picture
    func updateProfilePicture(profilePicture: UIImage, completion: @escaping (Result<Void, Error>)-> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success(()))
        }
        let imageData = profilePicture.jpegData(compressionQuality: 0.8)
        let imageString = imageData?.base64EncodedString() ?? ""
        db.collection("users").document(uid).updateData(["picture": imageString]){
            error in
            if let error = error{
                return completion(.failure(error))
            }else{
                self.fetchCurrentAppUser { _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    //Function to update Dark Mode
    func updateIsDarkMode(isDarkMode: Bool, completion: @escaping (Result<Void, Error>)->Void){
        //uid
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success(()))
        }
        db.collection("users").document(uid).updateData(["isDarkMode": isDarkMode]){
            error in
            if let error = error{
                return completion(.failure(error))
            }else{
                //refetch the user object
                self.fetchCurrentAppUser{ _ in
                    completion(.success(()))
                }
            }
        }
    }
}
