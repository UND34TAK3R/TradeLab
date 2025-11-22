import SwiftUI

struct EditProfileView: View {
    @StateObject var auth = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var displayName: String = ""
    @State private var newDisplayName: String = ""
    @State private var isDarkMode: Bool = false
    @State private var isNewDarkMode: Bool = false
    @State private var profilePicture: UIImage = UIImage(systemName: "person.circle.fill")!
    @State private var newProfilePicture: UIImage = UIImage(systemName: "person.circle.fill")!
    @State private var showImagePicker: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Picture Section
                        VStack(spacing: 15) {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(uiImage: newProfilePicture)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.8), lineWidth: 3)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.8))
                                            .clipShape(Circle())
                                            .offset(x: 40, y: 40)
                                    )
                            }
                            
                            Text("Tap to change photo")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Profile Information Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Display Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                TextField("Enter display name", text: $newDisplayName)
                                    .padding(12)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            
                            // Dark Mode Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dark Mode")
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.9))
                                    Text("Enable dark theme")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isNewDarkMode)
                                    .labelsHidden()
                                    .tint(.blue)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                        // Save Button
                        NavigationLink(destination: ProfileView()){
                            Button(action: {
                                saveProfile()
                            }) {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newProfilePicture)
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully!")
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - Add Errors To Failures
    
    private func loadUserData() {
        //load display Names
        displayName = auth.currentUser?.displayName ?? ""
        newDisplayName = displayName
        //load DarkModes
        isDarkMode = auth.currentUser?.isDarkMode ?? false
        isNewDarkMode = isDarkMode
        //load Images
        if let profilePictureString = auth.currentUser?.picture,
           let imageData = Data(base64Encoded: profilePictureString),
           let image = UIImage(data: imageData) {
            profilePicture = image
            newProfilePicture = profilePicture
        }
    }
    
    private func saveProfile() {
        let group = DispatchGroup()
        var hadError = false

        // Update display name
        if newDisplayName != displayName {
            group.enter()
            auth.updateDisplayName(displayName: newDisplayName) { result in
                if case .failure(_) = result { hadError = true }
                group.leave()
            }
        }

        // Update dark mode
        if isNewDarkMode != isDarkMode {
            group.enter()
            auth.updateIsDarkMode(isDarkMode: isNewDarkMode) { result in
                if case .failure(_) = result { hadError = true }
                group.leave()
            }
        }

        // Update profile picture
        if newProfilePicture != profilePicture {
            group.enter()
            auth.updateProfilePicture(profilePicture: newProfilePicture) { result in
                if case .failure(_) = result { hadError = true }
                group.leave()
            }
        }

        // Called when ALL updates finished
        group.notify(queue: .main) {
            if !hadError {
                //Go back to Profile Page
                dismiss()
            } else {
                //print error
                print("Something failed")
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    EditProfileView()
}
