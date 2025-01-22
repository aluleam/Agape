import SwiftUI
import Combine
import CoreData
import UIKit
import AVFoundation
import Photos
import NaturalLanguage
import Speech
import MapKit
import MobileCoreServices
import AVKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import URLImage
import FirebaseStorage
import FSCalendar
import WebKit
import Stripe
import SDWebImageSwiftUI



enum UserRole: String, CaseIterable 
{
    case admin = "Admin"
    case musician = "Musician"
    case artist = "Artist"
    case gamer = "Gamer"
    case educator = "Educator"
    
    var icon: Image {
        switch self {
        case .admin:
            return Image(systemName: "star.circle.fill")
        case .musician:
            return Image(systemName: "guitar")
        case .artist:
            return Image(systemName: "paintbrush.fill")
        case .gamer:
            return Image(systemName: "gamecontroller.fill")
        case .educator:
            return Image(systemName: "graduationcap.fill")
        }
    
    }
}


struct ContentView: View {
   
    let blackColor = Color.black

    @State private var emailOrPhone = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage = ""
    @State private var isResetPasswordSheetPresented = false
    @State private var resetEmail = ""
    @State private var isLoggedIn = false
    @State private var isNavigatingToCreateAccount = false
    @Binding var registrationSuccess: Bool
    @State private var showRegistrationView = false
    @State private var showAgapeAndGloriaView = false

    init(registrationSuccess: Binding<Bool>) {
        _registrationSuccess = registrationSuccess
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("Body-Of-Christ-Church-CHURCH-SEAL-NN")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding(.bottom, 20)

    
                TextField("Email or Phone", text: $emailOrPhone)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.black) // Set text color to black
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                   


                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .foregroundColor(.white)
                            .background(Color.clear)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: $password)
                            .foregroundColor(.black)
                            .background(Color.clear)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    Button(action: {
                        self.isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.clear)
                .cornerRadius(10)
                .padding(.bottom, 20)

                Button(action: {
                    self.authenticateUser(email: self.emailOrPhone, password: self.password)
                }) {
                    Text("Login")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(blackColor)
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)
                NavigationLink(destination: AgapeAndGloriaView(isUserProfileSheetPresented: .constant(false)), isActive: $showAgapeAndGloriaView) {
                    EmptyView()
                }
                .hidden()


                // Forgot Password
                Button("Forgot Password?") {
                    isResetPasswordSheetPresented = true
                }
                .foregroundColor(blackColor)
                .sheet(isPresented: $isResetPasswordSheetPresented) {
                    ResetPasswordView(resetEmail: $resetEmail)
                }

                Button("Create Account")
                {
                    self.showRegistrationView = true
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(blackColor)
                .cornerRadius(10)


                // Error message display
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
                NavigationLink(destination: RegistrationView(isSideMenuOpen: .constant(false), registrationSuccess: $registrationSuccess), isActive: $showRegistrationView) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [blackColor.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom))
            .navigationBarTitle("", displayMode: .inline)
        }

    }

    func authenticateUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let _ = error {
                    self.errorMessage = "Incorrect email or password"
                } else if authResult?.user != nil {
                    self.isLoggedIn = true
                    self.errorMessage = ""
                    self.showAgapeAndGloriaView = true
                }
            }
        }
    }

}

 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(registrationSuccess: .constant(false))
    }
}

    func isValidEmailOrPhone(_ input: String) -> Bool {
        return input.contains("@")
    }

    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 8
    }


struct CheckEmailAndPasswordView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isAccountExistenceChecked = false
    @State private var accountExists = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Check Email and Password")

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(isEmailValid ? .primary : .red)

            if !isEmailValid {
                Text("Please enter a valid email address.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Check Email Existence") {
                checkEmailExistence(email: email) { exists in
                    self.accountExists = exists
                    self.isAccountExistenceChecked = true

                    if !exists {
                        self.errorMessage = "Account with this email doesn't exist. You can create one."
                    } else {
                        self.errorMessage = ""
                    }
                }
                
                //usb blaster
                //manufacture: unknown
                
            }

            Button("Check Password") {
                checkPassword(email: email, password: password) { isValid in
                    self.isPasswordValid = isValid

                    if !isValid {
                        self.errorMessage = "Password is not valid."
                    } else {
                        self.errorMessage = ""
                    }
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }
    
    func checkEmailExistence(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            if let error = error {
                print("Error checking email existence: \(error.localizedDescription)")
                completion(false)
            } else if let methods = methods {
                completion(!methods.isEmpty)
            }
        }
    }

    func checkPassword(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                print("Error checking password: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isRegistering = false
    @State private var registrationSuccess = false
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text(isRegistering ? "Register" : "Login")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isRegistering {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(isRegistering ? "Register" : "Login") {
                if isRegistering {
                    registerUser()
                } else {
                    loginUser()
                }
            }

            if registrationSuccess {
                Text("Registration Successful")
                    .foregroundColor(.green)
            }

            Button(isRegistering ? "Already have an account? Login" : "Don't have an account? Register") {
                isRegistering.toggle()
                errorMessage = nil
            }
        }
        .padding()
    }

    private func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                registrationSuccess = true
                isLoggedIn = true
            }
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}


  
    struct WelcomeView: View {
        @Binding var showWelcome: Bool
        
        var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if showWelcome {
                        
                        Text("Welcome")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            )
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.showWelcome = false
                                    }
                                }
                            }
                    } else {
                        
                        Color.clear
                            .opacity(0)
                    }
                    
                    Spacer()
                }
            }
        }
    }

  
//struct AddPostView: View {
//    @State private var postContent = ""
//    @State private var selectedImage: UIImage?
//    @State private var isImagePickerPresented = false
//    @State private var isPosting = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        VStack {
//            if let image = selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity, maxHeight: 200)
//                    .padding()
//            }
//
//            Button(action: {
//                isImagePickerPresented = true
//            }) {
//                Text("Add Picture")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black)
//                    .cornerRadius(10)
//            }
//            .sheet(isPresented: $isImagePickerPresented) {
//                FirebaseImagePicker(selectedImage: $selectedImage)
//            }
//
//            TextEditor(text: $postContent)
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(10)
//
//            Button(action: {
//                savePost()
//            }) {
//                if isPosting {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .foregroundColor(.white)
//                } else {
//                    Text("Post")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.black)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//            .disabled(isPosting)
//        }
//        .navigationTitle("Add Post")
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//    }
//
//    private func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
//
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//            completion(nil)
//            return
//        }
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        _ = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
//            guard error == nil else {
//                print("Error uploading image: \(error!.localizedDescription)")
//                completion(nil)
//                return
//            }
//            imageRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    print("Error getting download URL: \(error!.localizedDescription)")
//                    completion(nil)
//                    return
//                }
//                completion(downloadURL.absoluteString)
//            }
//        }
//    }
//
//    private func savePost() {
//        guard !postContent.isEmpty, let image = selectedImage else {
//            showAlert(message: "Please add both post content and an image before posting.")
//            return
//        }
//
//        isPosting = true
//
//        uploadImageToFirebase(image: image) { imageURL in
//            if let imageURL = imageURL {
//            
//                savePostData(content: postContent, imageURL: imageURL)
//            } else {
//            
//                isPosting = false
//                showAlert(message: "Error uploading image.")
//            }
//        }
//    }
//
//    private func savePostData(content: String, imageURL: String) {
//        let db = Firestore.firestore()
//        let postRef = db.collection("posts").document()
//
//        let postData: [String: Any] = [
//            "content": content,
//            "imageURL": imageURL,
//            "timestamp": Date()
//        ]
//
//        postRef.setData(postData) { error in
//            if let error = error {
//                print("Error saving post data: \(error.localizedDescription)")
//                showAlert(message: "Error saving post data.")
//            } else {
//                print("Post saved successfully!")
//                postContent = ""
//                selectedImage = nil
//                isPosting = false
//            }
//        }
//    }
//
//    private func showAlert(message: String) {
//        alertMessage = message
//        showAlert = true
//    }
//}
//
//struct FirebaseImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Environment(\.presentationMode) var presentationMode
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: FirebaseImagePicker
//
//        init(parent: FirebaseImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let selectedImage = info[.originalImage] as? UIImage {
//                parent.selectedImage = selectedImage
//                parent.uploadImageToFirebase(image: selectedImage)
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = .photoLibrary
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func uploadImageToFirebase(image: UIImage) {
//        // Upload image to Firebase Storage
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let imageRef = storageRef.child("images/example.jpg")
//
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        _ = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
//            guard let _ = metadata else {
//                print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//        func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
//                let storage = Storage.storage()
//                let storageRef = storage.reference()
//                let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
//
//                guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//                    completion(nil)
//                    return
//                }
//
//                let metadata = StorageMetadata()
//                metadata.contentType = "image/jpeg"
//
//                _ = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
//                    guard error == nil else {
//                        print("Error uploading image: \(error!.localizedDescription)")
//                        completion(nil)
//                        return
//                    }
//                    imageRef.downloadURL { (url, error) in
//                        guard let downloadURL = url else {
//                            print("Error getting download URL: \(error!.localizedDescription)")
//                            completion(nil)
//                            return
//                        }
//                        print("Image uploaded successfully at \(downloadURL.absoluteString)")
//                        completion(downloadURL.absoluteString)
//                    }
//                }
//            }
//
//        }
//    }
//}

struct AgapeAndGloriaView: View {
    @Binding var isUserProfileSheetPresented: Bool
    @State private var rotationDegrees = 0.0
    @State private var showChurchInfo = false
    @State private var isEnglish = true
    @State private var limitedScrolling = false
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorScheme) var colorScheme
   
    let upcomingEvents = [
        "Men's Breakfast": "Saturday 10:00AM",
        "Youth Group": "Sunday 1:00PM",
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    
                    LinearGradient(gradient: dayTimeGradient(), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 15) {
                        Image("Body-Of-Christ-Church-CHURCH-SEAL-NN")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 5))
                            .shadow(radius: 8)
                            .rotationEffect(.degrees(rotationDegrees))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                                    rotationDegrees = 360
                                }
                            }

                        FlashingText(text1: "Body of Christ Church", text2: "Mwili wa Kristo", isEnglish: $isEnglish)
                            .padding(.vertical, 5)

                        Text("Jesus is Our Redeemer")
                            .font(.system(size: 16)).italic()
                            .foregroundColor(Color.black)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )

                        //BibleQuestionView()

                        VStack(spacing: 8) {
                            Text("Upcoming Events")
                                .font(.headline)
                                .padding(.vertical, 5)
                            ForEach(upcomingEvents.keys.sorted(), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(upcomingEvents[key]!)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.bottom, 10)

                        Spacer()

                        navigationButtons()
                            .padding(.bottom, 10)
                    }
                }
                .frame(minHeight: geometry.size.height)
                .onAppear {
                    limitedScrolling = geometry.size.height < 800
                }
                .disabled(limitedScrolling)
            }
            .frame(height: limitedScrolling ? nil : geometry.size.height)
        }
    }

    private func dayTimeGradient() -> Gradient {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 6 || hour > 18 {
            return Gradient(colors: [Color.black, Color.gray])
        } else if hour < 12 {
            return Gradient(colors: [Color.blue, Color.green])
        } else {
            return Gradient(colors: [Color.orange, Color.red])
        }
    }
    
    private func navigationButtons() -> some View {
        VStack {
            HStack(spacing: 30) {
                NavigationLink(destination: HomeView()) {
                    iconButtonView(iconName: "house.fill", label: "Home")
                }
                NavigationLink(destination: AnnouncementView()) {
                    iconButtonView(iconName: "bell.fill", label: "Notifications")
                }
                NavigationLink(destination: ReminderView()) {
                    iconButtonView(iconName: "clock.fill", label: "Reminder")
                }
                NavigationLink(destination: ChatView()) {
                    iconButtonView(iconName: "message.fill", label: "Chat")
                }
                NavigationLink(destination: MoreView()){
                    iconButtonView(iconName: "ellipsis.circle.fill", label: "More")
                }
            }
            .padding(.top, 10)
            Spacer()
        }
    }

    
    private func iconButtonView(iconName: String, label: String) -> some View
    {
        VStack {
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(Color.black)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.black)
        }
    }
}

//struct BibleQuestion: Identifiable
//{
//    let id = UUID()
//    let question: String
//    let answer: String
//    let reference: String
//    
//        static let sampleQuestions = [
//            BibleQuestion(question: "Who was the oldest man to live in the Bible?", answer: "Methuselah", reference: "Genesis 5:27"),
//            BibleQuestion(question: "On which day did Jesus rise from the dead?", answer: "The third day", reference: "Matthew 20:19"),
//            BibleQuestion(question: "Who denied Jesus three times?", answer: "Peter", reference: "John 18:15-27"),
//            BibleQuestion(question: "What type of insect did John the Baptist eat in the desert?", answer: "Locusts", reference: "Matthew 3:4"),
//            BibleQuestion(question: "Who was thrown into a lion's den by King Darius?", answer: "Daniel", reference: "Daniel 6"),
//            BibleQuestion(question: "What was the first thing that God created?", answer: "Light", reference: "Genesis 1:3"),
//            BibleQuestion(question: "How many books are in the Bible?", answer: "66", reference: ""),
//            BibleQuestion(question: "Who was the first murderer?", answer: "Cain", reference: "Genesis 4:8"),
//            BibleQuestion(question: "Which book comes last in the New Testament?", answer: "Revelation", reference: ""),
//            BibleQuestion(question: "Who built an ark?", answer: "Noah", reference: "Genesis 6-9"),
//            BibleQuestion(question: "Who was sold into slavery by his brothers?", answer: "Joseph", reference: "Genesis 37"),
//            BibleQuestion(question: "Which apostle betrayed Jesus?", answer: "Judas Iscariot", reference: "Matthew 26:14-16"),
//            BibleQuestion(question: "In which city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
//            BibleQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 9:15-17"),
//            BibleQuestion(question: "Who interpreted the dreams of the Pharaoh?", answer: "Joseph", reference: "Genesis 41"),
//            BibleQuestion(question: "On what did Jesus feed 5,000 people?", answer: "Five loaves and two fish", reference: "Matthew 14:17-21"),
//            BibleQuestion(question: "Who walked on water to go to Jesus?", answer: "Peter", reference: "Matthew 14:29"),
//            BibleQuestion(question: "What was Paul’s occupation?", answer: "Tentmaker", reference: "Acts 18:3"),
//            BibleQuestion(question: "Who was the prophet that confronted King David about his sin with Bathsheba?", answer: "Nathan", reference: "2 Samuel 12"),
//            BibleQuestion(question: "Who was the father of John the Baptist?", answer: "Zechariah", reference: "Luke 1:13-17"),
//            BibleQuestion(question: "Which disciple doubted Jesus' resurrection until he saw Jesus himself?", answer: "Thomas", reference: "John 20:24-29"),
//            BibleQuestion(question: "Who wrote most of the New Testament letters (epistles)?", answer: "Paul", reference: "Multiple epistles attributed to Paul"),
//            BibleQuestion(question: "What is the last word in the Bible?", answer: "Amen", reference: "Revelation 22:21"),
//            BibleQuestion(question: "Who was the first martyr of the Christian church?", answer: "Stephen", reference: "Acts 7:54-60"),
//            BibleQuestion(question: "Who was known as the 'weeping prophet'?", answer: "Jeremiah", reference: "Jeremiah 9:1"),
//            BibleQuestion(question: "What was the name of the man who replaced Judas Iscariot as an apostle?", answer: "Matthias", reference: "Acts 1:21-26"),
//            BibleQuestion(question: "Who was the mother of Jesus?", answer: "Mary", reference: "Matthew 1:18-25"),
//            BibleQuestion(question: "What was the name of the disciple who betrayed Jesus for thirty pieces of silver?", answer: "Judas Iscariot", reference: "Matthew 26:14-16"),
//            BibleQuestion(question: "What did Jesus say to his disciples before ascending into heaven?", answer: "The Great Commission", reference: "Matthew 28:16-20"),
//            BibleQuestion(question: "Who wrote the Book of Revelation?", answer: "John", reference: "Revelation 1:1"),
//            BibleQuestion(question: "Who was the Roman governor who ordered Jesus' crucifixion?", answer: "Pontius Pilate", reference: "Matthew 27:11-26"),
//            BibleQuestion(question: "Which river did John the Baptist baptize Jesus in?", answer: "Jordan River", reference: "Matthew 3:13-17"),
//            BibleQuestion(question: "What is the name of the disciple who walked with Jesus on the road to Emmaus after his resurrection?", answer: "Cleopas", reference: "Luke 24:13-35"),
//            BibleQuestion(question: "What was the name of the city where Jesus performed his first miracle of turning water into wine?", answer: "Cana", reference: "John 2:1-11")
//        ]
//    }

struct EnhancedMarqueeText: View {
    var text: String
    var font: Font = .headline
    var startDelay: Double = 1.0
    var speed: Double = 50.0

    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .offset(x: animate ? -geometry.size.width * 2 : geometry.size.width)
                    .onAppear {
                        withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false).delay(startDelay)) {
                            animate = true
                        }
                    }
            }
        }
    }
}

struct GradientView: View {
    var reverse: Bool = false
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [reverse ? .clear : .black, .clear]), startPoint: reverse ? .center : .leading, endPoint: reverse ? .leading : .center)
            .frame(width: 20)
    }
}



//struct BibleQuestionView: View {
//    var questions: [BibleQuestion] = BibleQuestion.sampleQuestions.shuffled()
//    @State private var currentQuestionIndex = 0
//    @State private var userAnswer = ""
//    @State private var lastAnswer = ""
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @State private var showIncorrectMessage = false
//    
//    var body: some View {
//        VStack {
//            if currentQuestionIndex < questions.count {
//                Text(questions[currentQuestionIndex].question)
//                    .font(.headline)
//                    .lineLimit(nil) // Allow multiple lines
//                    .padding()
//                
//                TextField("Enter your answer here", text: $userAnswer)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                
//                Button("Submit") {
//                    submitAnswer()
//                }
//                .padding(.top)
//                
//                if showIncorrectMessage {
//                    Text("Incorrect, try again!")
//                        .foregroundColor(.red)
//                }
//            } else {
//                Text("You've answered all questions!")
//            }
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//        .padding()
//        .navigationBarTitle("Bible Quiz", displayMode: .inline)
//    }
//    
//    private func submitAnswer() {
//        guard currentQuestionIndex < questions.count else { return }
//        
//        let correctAnswer = questions[currentQuestionIndex].answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        let normalizedUserAnswer = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if normalizedUserAnswer == lastAnswer.lowercased() {
//            alertMessage = "You've already tried that answer."
//            showAlert = true
//            return
//        }
//        
//        if normalizedUserAnswer == correctAnswer {
//            moveToNextQuestion()
//        } else {
//            showIncorrectMessage = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                showIncorrectMessage = false
//            }
//            lastAnswer = userAnswer
//        }
//    }
//    
//    private func moveToNextQuestion() {
//        if currentQuestionIndex + 1 < questions.count {
//            currentQuestionIndex += 1
//        } else {
//            currentQuestionIndex = 0
//        }
//        userAnswer = ""
//        lastAnswer = ""
//        showAlert = false
//        showIncorrectMessage = false
//    }
//}
//


struct MarqueeText: View {
    let text: String
    let font: Font
    var leftFade: CGFloat
    var rightFade: CGFloat
    var startDelay: Double

    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Text(text)
                    .font(font)
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity(0)
                    .overlay(
                        Text(text)
                            .font(font)
                            .lineLimit(1)
                            .offset(x: animate ? -geometry.size.width * 2 : geometry.size.width)
                            .animation(Animation.linear(duration: 8).repeatForever(autoreverses: false).delay(startDelay), value: animate)
                    )
            }
            .onAppear {
                animate = true
            }
        }
    }
}



//struct QuestionsView: View {
//   // @State private var shuffledQuestions = BibleQuestion.sampleQuestions.shuffled()
//
//    var body: some View {
//        NavigationView {
//            List(shuffledQuestions) { question in
//                QuestionCell(question: question)
//            }
//            .navigationTitle("More Questions")
//        }
//    }
//}


//struct QuestionCell: View {
//    let question: BibleQuestion
//    @State private var showAnswer = false
//
//    var body: some View {
//        NavigationLink(destination: QuestionDetailView(question: question)) {
//            VStack(alignment: .leading) {
//                Text(question.question)
//                    .fontWeight(.bold)
//                    .onTapGesture {
//                        withAnimation {
//                            showAnswer.toggle()
//                        }
//                    }
//
//                if showAnswer {
//                    Text("Answer: \(question.answer)")
//                        .fontWeight(.light)
//                        .foregroundColor(.gray)
//                    if !question.reference.isEmpty {
//                        Text("Reference: \(question.reference)")
//                            .font(.caption)
//                            .foregroundColor(.black)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct QuestionDetailView: View {
//    let question: BibleQuestion
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(question.question)
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundColor(Color.black.opacity(0.8))
//                .padding(.bottom, 5)
//            
//            Text("Answer: \(question.answer)")
//                .font(.subheadline)
//                .foregroundColor(Color.green)
//                .padding(.bottom, 5)
//            
//            if !question.reference.isEmpty {
//                Text("Reference: \(question.reference)")
//                    .font(.caption)
//                    .foregroundColor(Color.gray)
//                    .padding(.bottom, 5)
//            }
//        }
//        .padding(12)
//        .navigationBarTitle("Question Detail")
//    }
//}
//

struct DynamicGreetingView: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Welcome"
        }
    }
    
    @State private var scaleEffect = 0.9
    
    var body: some View {
        Text("\(greeting)!")
            .font(.system(size: 24, weight: .light, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .scaleEffect(scaleEffect)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scaleEffect = 1.05
                }
            }
    }
}


struct FlashingText: View
{
    let text1: String
    let text2: String
    @Binding var isEnglish: Bool

    var body: some View {
        Text(isEnglish ? text1 : text2)
            .font(.custom("Georgia-BoldItalic", size: 28))
            .foregroundColor(.black)
            .padding()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                    withAnimation {
                        self.isEnglish.toggle()
                    }
                }
            }
    }
}

struct ChurchInfoButton: View {
    @Binding var showChurchInfo: Bool

    var body: some View {
        Button(action: {
            showChurchInfo.toggle()
        }) {
            VStack {
                Image(systemName: "info.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                Text("Church Info")
                    .font(.caption)
                    .foregroundColor(Color.black)
            }
        }
        .sheet(isPresented: $showChurchInfo) {
            ChurchInfoView()
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed
    }
}

struct ChurchInfoView: View {
    @State private var isEnglish = true
    @State private var showWebsite = false
    
    var body: some View {
        VStack {
            Text(isEnglish ? "Body of Christ Church" : "Mwili wa Kristo")
                .font(.custom("Georgia-BoldItalic", size: 28))
                .foregroundColor(.black)
                .padding()
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                        withAnimation {
                            self.isEnglish.toggle()
                        }
                    }
                }

            VStack(alignment: .leading) {
                Text("Address:")
                    .fontWeight(.bold)
                Text("123 Main Street")
                    .font(.system(size: 16))
                Text("Cityville, State")
                    .font(.system(size: 16))
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("CreamBackground"))
                    )
                    .onTapGesture {
                        openMaps()
                    }

                Text("Contact:")
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Text("Phone: 123-456-7890")
                    .font(.system(size: 16))
                Text("Email: info@bodyofchristchurch.com")
                    .font(.system(size: 16))
            }

            Button(action: {
               
                showWebsite.toggle()
            }) {
                Text("About Us:")
                    .fontWeight(.bold)
            }
            .sheet(isPresented: $showWebsite) {
                WebView(url: URL(string: "https://www.bodyofchristchurch.com")!)
            }
        }
        .padding()
    }

    private func openMaps() {
        let coordinates = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Body of Christ Church"
        mapItem.openInMaps(launchOptions: nil)
    }
}




struct BibleStudyView: View {
    var body: some View {
        VStack {
            Text("Bible Study Resources")
                .font(.title)
                .foregroundColor(.black)
                .padding()

            // Add Bible study resources here, such as links to online Bibles, study guides, etc.

            // Example link to an online Bible
            Link("Read the Bible Online", destination: URL(string: "https://www.bible.com")!)
                .foregroundColor(.black)
                .padding()

        
        }
    }
}




struct FeatureCardView: View {
    var featureCard: FeatureCard

    var body: some View {
        NavigationLink(destination: FeatureDetailView(featureCard: featureCard)) {
            VStack(alignment: .leading) {
                Text(featureCard.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(featureCard.description)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct FeatureDetailView: View {
    var featureCard: FeatureCard

    var body: some View {
        VStack {
            Text(featureCard.title)
                .font(.title)
                .padding()
                .foregroundColor(.black) // Change text color to black
            Text(featureCard.description)
                .font(.body)
                .padding()
                .foregroundColor(.black) // Change text color to black
        }
        .navigationBarTitle(featureCard.title)
    }
}

struct FeatureCard: Hashable {
    let title: String
    let description: String

    static let examples = [
        FeatureCard(title: "Daily Verse", description: "Get inspired with a daily Bible verse."),
        FeatureCard(title: "Prayer Requests", description: "Share and receive prayer requests from the community."),
        FeatureCard(title: "Upcoming Events", description: "Stay updated with church events and activities.")
    ]
}


struct CustomButton<Destination: View>: View {
    let iconName: String
    @Binding var isTapped: Bool
    var destination: Destination
    
    var body: some View {
        Button(action: {
            isTapped.toggle()
        }) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            NavigationLink(
                destination: destination,
                isActive: $isTapped
            ) {
                EmptyView()
            }
                .buttonStyle(PlainButtonStyle())
        )
    }
}
struct ConductorView: View {
    @State private var metronomeOn = false
    @State private var beatsPerMinute = 120.0
    @State private var timerIsRunning = false
    @State private var timeElapsed = 0
    @State private var notes = ""
    @State private var currentPiece = "Select Piece"
    @State private var showConductorDetails = false
    @State private var metronomeSoundPlayer: AVAudioPlayer?

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .font(.largeTitle)
                    .padding()

                HStack {
                    Text("Current Piece:")
                    Menu(currentPiece) {
                        Button("Symphony No. 5", action: { setCurrentPiece("Symphony No. 5") })
                        Button("Eine kleine Nachtmusik", action: { setCurrentPiece("Eine kleine Nachtmusik") })
                        // Add more pieces as needed
                    }
                }
                .padding()

                Toggle(isOn: $metronomeOn) {
                    Text("Metronome")
                }
                .padding()
                .onChange(of: metronomeOn) { newValue in
                    if newValue {
                        startMetronome()
                    } else {
                        stopMetronome()
                    }
                }

                if metronomeOn {
                    Slider(value: $beatsPerMinute, in: 40.0...240.0)
                    Text("\(Int(beatsPerMinute)) BPM")
                }

                Divider()

                HStack {
                    Text("Timer:")
                    Text("\(timeElapsed) seconds")
                    Spacer()
                    Button(timerIsRunning ? "Stop" : "Start") {
                        timerIsRunning.toggle()
                    }
                    Button("Reset") {
                        resetTimer()
                    }
                }
                .padding()

                Divider()

                MusicSheetViewer()

                Divider()

                Button("View Conductor Details") {
                    showConductorDetails = true
                }
                .sheet(isPresented: $showConductorDetails) {
                    ConductorDetailsView()
                }

                Divider()

                Text("Notes")
                    .font(.headline)
                    .padding()

                TextEditor(text: $notes)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()

                Spacer()
            }
            .navigationBarTitle("Conductor's View")
            .onReceive(timer) { _ in
                if timerIsRunning {
                    timeElapsed += 1
                }
            }
            .onAppear {
                prepareMetronomeSound()
            }
        }
    }

    func setCurrentPiece(_ piece: String) {
        currentPiece = piece
    }

    func prepareMetronomeSound() {
        guard let soundURL = Bundle.main.url(forResource: "metronomeSound", withExtension: "mp3") else { return }
        do {
            metronomeSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            metronomeSoundPlayer?.prepareToPlay()
        } catch {
            print("Error loading metronome sound: \(error)")
        }
    }

    func startMetronome() {
        metronomeSoundPlayer?.numberOfLoops = -1
        metronomeSoundPlayer?.play()
    }

    func stopMetronome() {
        metronomeSoundPlayer?.stop()
    }

    func resetTimer() {
        timerIsRunning = false
        timeElapsed = 0
    }
}

struct MusicSheetViewer: View {
    var body: some View {
        Text("Music Sheet Viewer")
            .font(.title)
            .padding()
    }
}

struct ConductorDetailsView: View {
    var body: some View {
        VStack {
            Text("Conductor & Assistant")
                .font(.headline)
                .padding()

            HStack {
                VStack(alignment: .leading) {
                    Text("Head Conductor:")
                    Text("Shandro")
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Assistant Conductor:")
                    Text("Byamss")
                        .fontWeight(.bold)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitle("Details", displayMode: .inline)
    }
}

struct ConductorView_Previews: PreviewProvider 
{
    static var previews: some View 
    {
        ConductorView() //
    }
}


struct Instrument: Identifiable, Codable 
{
    var id: String = UUID().uuidString
    var name: String
    var quantity: Int
    var details: String
}

struct InstrumentDetailView: View 
{
    var instrument: Instrument

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name: \(instrument.name)")
                .font(.title2)
            Text("Quantity: \(instrument.quantity)")
            Text("Details: \(instrument.details)")
            Spacer()
        }
        .padding()
        .navigationBarTitle("Instrument Details", displayMode: .inline)
    }
}

struct AddInstrumentView: View {
    @Binding var instruments: [Instrument]
    @State private var name = ""
    @State private var quantity = ""
    @State private var details = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Instrument Details")) {
                    TextField("Name", text: $name)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    TextField("Details", text: $details)
                }

                Button("Add Instrument") {
                    addInstrument()
                }
            }
            .navigationBarTitle("New Instrument", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func addInstrument() {
        guard !name.isEmpty, let quantityInt = Int(quantity) else { return }
        let newInstrument = Instrument(name: name, quantity: quantityInt, details: details)
        let db = Firestore.firestore()
        db.collection("instruments").addDocument(data: [
            "name": newInstrument.name,
            "quantity": newInstrument.quantity,
            "details": newInstrument.details
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self.instruments.append(newInstrument)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct InstrumentView: View {
    @State private var instruments: [Instrument] = []
    @State private var showingDetail = false
    @State private var selectedInstrument: Instrument?
    @State private var showingAddInstrument = false

    var body: some View {
        NavigationView {
            VStack {
                List(instruments) { instrument in
                    HStack {
                        Text(instrument.name)
                            .font(.headline)
                        Spacer()
                        Text("Count: \(instrument.quantity)")
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        self.selectedInstrument = instrument
                        self.showingDetail = true
                    }
                    .padding(.vertical, 5)
                }

                NavigationLink(destination: InstrumentDetailView(instrument: selectedInstrument ?? Instrument(name: "", quantity: 0, details: "")), isActive: $showingDetail) {
                    EmptyView()
                }

                Button(action: {
                    self.showingAddInstrument = true
                }) {
                    Text("Add Instrument")
                }
                .padding()
            }
            .navigationBarTitle("Instruments")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddInstrument = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddInstrument) {
                AddInstrumentView(instruments: $instruments)
            }
        }
        .onAppear(perform: fetchInstruments)
    }

    func fetchInstruments() {
        let db = Firestore.firestore()
        db.collection("instruments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.instruments = querySnapshot!.documents.compactMap { document -> Instrument? in
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let details = data["details"] as? String else {
                        return nil
                    }

                    return Instrument(id: document.documentID, name: name, quantity: quantity, details: details)
                }
            }
        }
    }
}

struct InstrumentView_Previews: PreviewProvider 
{
    static var previews: some View {
        InstrumentView()
    }
}

    



struct InstrumentListView: View 

{
    @State private var instruments: [Instrument] = []
    @State private var showingDetail = false
    @State private var selectedInstrument: Instrument?

    var body: some View {
        List(instruments) { instrument in
            NavigationLink(destination: InstrumentDetailView(instrument: instrument), isActive: $showingDetail) {
                HStack {
                    Text(instrument.name)
                        .font(.headline)
                    Spacer()
                    Text("Count: \(instrument.quantity)")
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                self.selectedInstrument = instrument
                self.showingDetail = true
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Instruments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchInstruments()
        }
    }

    func fetchInstruments() {
        let db = Firestore.firestore()
        db.collection("instruments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.instruments = querySnapshot!.documents.compactMap { document -> Instrument? in
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let details = data["details"] as? String else {
                        return nil
                    }

                    return Instrument(id: document.documentID, name: name, quantity: quantity, details: details)
                }
            }
        }
    }
}


struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination:SongListView()) {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.black)
                                .font(.title)
                            Text("Songs")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: ChoirMembersListView()) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.green)
                                .font(.title)
                            Text("Singers")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: ConductorView()) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.orange)
                                .font(.title)
                            Text("Conductors")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: DetailView(title: "Microphone", imageName: "mic.fill")) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.gray)
                                .font(.title)
                            Text("Microphone")
                                .font(.headline)
                        }
                    }
                    
                    NavigationLink(destination: InstrumentListView()) {
                        HStack {
                            Image(systemName: "guitars.fill")
                                .foregroundColor(.brown)
                                .font(.title)
                            Text("Instruments")
                                .font(.headline)
                        }
                    }
                    
             
                    NavigationLink(destination: DetailView(title: "Schedule", imageName: "calendar.badge.clock")) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.teal)
                                .font(.title)
                            Text("Schedule")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: DetailView(title: "Performances", imageName: "star.fill")) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.843, blue: 0.0)) // Custom black Color
                                .font(.title)
                            Text("Performances")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: DetailView(title: "Recordings", imageName: "camera.fill")) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text("Recordings")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: DetailView(title: "Audio Recordings", imageName: "waveform.path.ecg")) {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.indigo)
                                .font(.title)
                            Text("Audio Recordings")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: DetailView(title: "Favorites", imageName: "heart.fill")) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.title)
                            Text("Favorites")
                                .font(.headline)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Home", displayMode: .large)
        }
    }
}


struct MainMenuView: View {
    var body: some View {
        NavigationView {
            List {
            
                NavigationLink(destination: ChoirMembersListView()) {
                    Text("View Choir Members")
                }
            }
            .navigationTitle("Main Menu")
        }
    }
}






struct ChoirMember: Codable, Identifiable {
    var id: String
    var name: String
    var location: String
    var email: String
    var phoneNumber: String
    var role: String


    init(id: String = UUID().uuidString, name: String = "", location: String = "", email: String = "", phoneNumber: String = "", role: String = "")
    {
        self.id = id
        self.name = name
        self.location = location
        self.email = email
        self.phoneNumber = phoneNumber
        self.role = role
    }
}

class FirebaseService: ObservableObject {
    @Published var choirMembers: [ChoirMember] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchChoirMembers()
    }
    
    func fetchChoirMembers() {
        db.collection("choirMembers").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.choirMembers = documents.map { queryDocumentSnapshot -> ChoirMember in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let name = data["name"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let role = data["role"] as? String ?? ""
                return ChoirMember(id: id, name: name, location: location, email: email, phoneNumber: phoneNumber, role: role)
            }
        }
    }

    func addChoirMember(member: ChoirMember) {
        do {
            try db.collection("choirMembers").document(member.id).setData(from: member)
        } catch let error {
            print("Error writing member to Firestore: \(error.localizedDescription)")
        }
    }

    func deleteChoirMember(member: ChoirMember, completion: @escaping (Bool) -> Void) {
        db.collection("choirMembers").document(member.id).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                print("Document successfully removed!")
                completion(true)
            }
        }
    }
}


struct ChoirMembersListView: View {
    @ObservedObject var firebaseService = FirebaseService()
    @State private var isAddingMember = false

    var body: some View {
        NavigationView {
            List {
                ForEach(firebaseService.choirMembers) { member in
                    NavigationLink(destination: MemberDetailView(member: member)) {
                        Text(member.name)
                    }
                }
                .onDelete(perform: deleteMember)
            }
            .navigationTitle("Choir Members")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Toggle the flag to show the AddMemberView
                        isAddingMember.toggle()
                    }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingMember) {
            AddMemberView(firebaseService: firebaseService, isPresented: $isAddingMember)
        }
    }

    private func deleteMember(at offsets: IndexSet) {
        for index in offsets {
            guard index < firebaseService.choirMembers.count else { return }
            let memberToDelete = firebaseService.choirMembers[index]

            // Call the delete method directly on firebaseService
            firebaseService.deleteChoirMember(member: memberToDelete) { success in
                DispatchQueue.main.async {
                    if success {
                        // Update the choirMembers array to reflect the deletion
                        self.firebaseService.choirMembers.remove(at: index)
                    } else {
                        
                    }
                }
            }
        }
    }
}


struct AddMemberView: View {
    @ObservedObject var firebaseService: FirebaseService
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var location = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var role = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Choir Member Details")) {
                    TextField("Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Email", text: $email)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Role", text: $role)
                }
            }
            .navigationTitle("Add Choir Member")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    // Create a new ChoirMember instance and add it to Firebase
                    let newMember = ChoirMember(name: name, location: location, email: email, phoneNumber: phoneNumber, role: role)
                    firebaseService.addChoirMember(member: newMember)

                    // Close the AddMemberView
                    isPresented = false
                }
            )
        }
    }
}














struct MemberDetailView: View {
    var member: ChoirMember

    var body: some View {
        VStack {
            Text("Name: \(member.name)")
            Text("Location: \(member.location)")
            Text("Email: \(member.email)")
            Text("Phone: \(member.phoneNumber)")
            Text("Role: \(member.role)")
        }
    }
}



















struct HomeView_Previews: PreviewProvider 
{
    static var previews: some View {
        HomeView()
    }
}

struct DetailView: View {
    var title: String
    var imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .cornerRadius(12)
            
            Text("Detail for \(title)")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button(action: {
                
            }) {
                Text("Learn More")
                    .font(.headline)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}



struct MoreView: View {
    @State private var isEditingProfile = false
    @State private var profileName = ""
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUpcomingEventsPresented = false
    @State private var isBookmarksPresented = false
    @State private var isMyPostsPresented = false
    @State private var isJoinRequestSentPresented = false
    @State private var isMarketplacePresented = false // Added for Marketplace
    @State private var showChurchInfo = false // Added for Church Info
    @State private var showDonationView = false // Added for Donation View
    @State private var showMapView = false // Added for Map View

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        //ProfileHeaderView()

                        Group {
                            NavigationLink(destination: UpcomingEventsView(), isActive: $isUpcomingEventsPresented) {
                                Text("Upcoming Events \u{25B6}")
                            }
                            .foregroundColor(.black)
                            
                            NavigationLink(destination: BookmarksView(), isActive: $isBookmarksPresented) {
                                Text("Bookmarks \u{25B6}")
                            }
                            .foregroundColor(.black)
                            
                            NavigationLink(destination: MyPostsView(), isActive: $isMyPostsPresented) {
                                Text("My Posts \u{25B6}")
                            }
                            .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Group {
                            NavigationLink(destination: JoinRequestSentView(), isActive: $isJoinRequestSentPresented) {
                                Text("Join Request Sent \u{25B6}")
                            }
                            .foregroundColor(.black)
                            
                            NavigationLink(destination: MarketplaceView(), isActive: $isMarketplacePresented) {
                                Text("Marketplace \u{25B6}")
                            }
                            .foregroundColor(.black)
                            .padding(.bottom)

                            Button(action: {
                                self.showChurchInfo.toggle()
                            }) {
                                Text("Church Information")
                            }
                            .foregroundColor(.black)

                            Button(action: {
                                self.showDonationView.toggle()
                            }) {
                                Text("Make a Donation")
                            }
                            .foregroundColor(.black)

                            Button(action: {
                                self.showMapView.toggle()
                            }) {
                                Text("View Map")
                            }
                            .foregroundColor(.black)
                        }

                        Spacer()

                       // BottomIconRowView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                }
            }
            .navigationTitle("More")
            .navigationBarItems(trailing: Button("Edit") {
                self.isEditingProfile.toggle()
            })
            .sheet(isPresented: $showingImagePicker, onDismiss: uploadProfileImage) {
                ImagePicker(image: self.$inputImage, isImagePickerPresented: self.$isImagePickerPresented)
            }
            .sheet(isPresented: $showChurchInfo) {
                ChurchInfoView() // Assuming ChurchInfoView is the view to display church information
            }
            .sheet(isPresented: $showDonationView) {
                DonationView() // Placeholder for DonationView
            }
            .sheet(isPresented: $showMapView) {
                MapView() // Placeholder for MapView
            }
        }
    }

    private func uploadProfileImage() {
        // Handle the profile image upload logic
    }

    private func signOut() {
        // Handle the sign out logic
    }
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locations = [Location]()
    
    let address = "6201 South Lyncrest Ave, Sioux Falls, SD 57108, USA"

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapPin(coordinate: location.coordinate, tint: .black)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            geocodeAddress(address: address)
        }
    }
    
    private func geocodeAddress(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No location found for: \(address)")
                return
            }
            
            let coordinate = location.coordinate
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
           
            self.locations = [Location(coordinate: coordinate)]
        }
    }
}

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


struct DonationView: View {
    @State private var donationAmount = ""
    @State private var selectedPresetAmount: Double? = nil
    let presetDonationAmounts: [Double] = [5.0, 10.0, 25.0, 50.0, 100.0]
    @State private var donations: [Double] = []
    @State private var isDonationSuccessful = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Support Our Cause")
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    presetAmountsView
                    
                    customAmountTextField
                    
                    donateButton
                    
                    if !donations.isEmpty {
                        donationHistory
                    }
                }
                .padding()
                .alert(isPresented: $isDonationSuccessful) {
                    Alert(title: Text("Thank You!"), message: Text("Your donation was successful."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle(Text("Donations for \(currentYear())"), displayMode: .inline)
        }
    }
    
    private var presetAmountsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(presetDonationAmounts, id: \.self) { amount in
                    Button(action: {
                        self.selectedPresetAmount = amount
                        self.donationAmount = String(format: "%.2f", amount)
                    }) {
                        Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "")
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(self.selectedPresetAmount == amount ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
            }
        }
    }
    
    private var customAmountTextField: some View {
        TextField("Enter amount", text: $donationAmount)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    private var donateButton: some View {
        Button(action: initiatePayPalPayment) {
            HStack {
                Image(systemName: "heart.fill")
                Text("Donate with PayPal")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private var donationHistory: some View {
        VStack(alignment: .leading) {
            Text("Donation History")
                .font(.headline)
                .padding(.vertical)
            
            ForEach(donations, id: \.self) { donation in
                Text(currencyFormatter.string(from: NSNumber(value: donation)) ?? "")
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
        }
    }
    
    private func initiatePayPalPayment() {
        guard let amount = Double(donationAmount), amount > 0 else {
            errorMessage = "Please enter a valid donation amount."
            showErrorAlert = true
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.donations.append(amount)
            self.donationAmount = ""
            self.selectedPresetAmount = nil
            self.isDonationSuccessful = true
        }
    }
    
    private func currentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}





// Placeholder for ImagePicker
struct ImagePicker: View {
    @Binding var image: UIImage?
    @Binding var isImagePickerPresented: Bool

    var body: some View {
        Text("Image Picker Placeholder")
    }
}

struct ProfileHeaderViewModel: View {
    var body: some View {
        Text("ProfileHeaderViewModel")
            .font(.title)
            .padding()
    }
}


//struct ProfileHeaderView: View {
//    @ObservedObject var viewModel = ProfileHeaderViewModel()
//    @State private var showImagePicker = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if let user = viewModel.user {
//                if let photoURL = user.photoURL {
//                    WebImage(url: photoURL)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .shadow(radius: 5)
//                } else {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .shadow(radius: 5)
//                }
//                
//                Text(user.displayName ?? "Anonymous")
//                    .font(.title)
//                    .fontWeight(.bold)
//                
//                Button(action: {
//                    showImagePicker = true
//                }) {
//                    Text("Change Profile Picture")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .sheet(isPresented: $showImagePicker) {
//                    ImagePicker(image: $viewModel.profileImage, onImagePicked: { image in
//                        viewModel.uploadProfilePicture(image: image)
//                    })
//                }
//                
//                // Additional user details can be displayed here
//            } else {
//                ProgressView()
//            }
//        }
//        .padding()
//        .onAppear {
//            viewModel.fetchUserData()
//        }
//    }
//}


struct BookmarksView: View {
    var body: some View {
        
        Text("This is the Bookmarks View")
    }
}

struct JoinRequestSentView: View {
    var body: some View {
        Text("Join Request Sent")
    }
}

struct MultiLinkInviteView: View {
    var body: some View {
        
        Text("Multi-Link Invite View")
    }
}



// Placeholder structs for the views to be presented. You'll need to replace these with your actual view implementations.
struct NoticesView: View {
    var body: some View {
        Text("Notices Placeholder")
    }
}

struct CheckInviteView: View {
    var body: some View {
        Text("Check Invite Placeholder")
    }
}

struct StickerShopView: View {
    var body: some View {
        Text("Sticker Shop Placeholder")
    }
}



struct BottomIconView: View {
    let imageName: String
    let label: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
            Text(label)
        }
    }
}


struct UpcomingEventsView: View {
    @ObservedObject var viewModel = EventsViewModel()

    var body: some View {
        VStack {
            FSCalendarView(viewModel: viewModel)
            List {
                ForEach(viewModel.uniqueMonths, id: \.self) { month in
                    Section(header: Text(month, formatter: monthYearFormatter)) {
                        if viewModel.events(onDay: month).isEmpty {
                            Text("No events coming")
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                        } else {
                            ForEach(viewModel.events(onDay: month)) { event in
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                        .font(.headline)
                                    Text(event.date, formatter: dateFormatter)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
}


struct FSCalendarView: UIViewRepresentable {
    @ObservedObject var viewModel: EventsViewModel

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Update the calendar here if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, FSCalendarDataSource, FSCalendarDelegate {
        var viewModel: EventsViewModel

        init(viewModel: EventsViewModel) {
            self.viewModel = viewModel
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            // Show a dot for days with events
            return viewModel.daysWithEvents.contains(date) ? 1 : 0
        }
    }
}










struct JoinBandView: View
    {
        var body: some View {
            Text("Join a Band View")
                .font(.title)
                .foregroundColor(.black)
        }
    }















struct CalendarView: View {
    @ObservedObject var viewModel: EventsViewModel
    @State private var currentDate = Date()

    var body: some View {
        VStack {
            CalendarHeaderView(currentDate: $currentDate)
            DaysOfWeekView()
            MonthView(currentDate: $currentDate, viewModel: viewModel)
        }
    }
}

private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

struct CalendarHeaderView: View {
    @Binding var currentDate: Date

    var body: some View {
        HStack {
            Button(action: {
                self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate)!
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(currentDate, formatter: monthYearFormatter)
                .font(.title)
            Spacer()
            Button(action: {
                self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate)!
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
}


struct DaysOfWeekView: View {
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct MonthView: View {
    @Binding var currentDate: Date
    @ObservedObject var viewModel: EventsViewModel

    var body: some View {
        let days = generateDaysInMonth(for: currentDate)
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(days, id: \.self) { day in
                DayView(day: day, events: viewModel.events(onDay: day))
            }
        }
    }

    // Generate the days of the month based on the currentDate
    private func generateDaysInMonth(for date: Date) -> [Date] {
        var days: [Date] = []

        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!

        var day = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

        for _ in 1...range.count {
            days.append(day)
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }

        return days
    }
}

struct DayView: View {
    var day: Date
    var events: [Event]

    var body: some View {
        Text(day, formatter: dayFormatter)
            .frame(width: 30, height: 30)
            .padding(5)
            .background(events.isEmpty ? Color.clear : Color.green)
            .cornerRadius(15)
            .overlay(
                VStack {
                    if !events.isEmpty {
                        // Display a dot or something to indicate there's an event
                        Circle()
                            .frame(width: 5, height: 5)
                            .foregroundColor(.red)
                    }
                },
                alignment: .bottom
            )
    }
}

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()






class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var daysWithEvents: Set<Date> = []

    var uniqueMonths: [Date] {
        var months: Set<Date> = []
        let calendar = Calendar.current
        for event in events {
            // Get the first day of the month for the event date
            if let month = calendar.date(from: calendar.dateComponents([.year, .month], from: event.date)) {
                months.insert(month)
            }
        }
        return months.sorted()
    }

    init() {
        fetchEvents()
    }

    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            var fetchedEvents: [Event] = []
            var eventDays: Set<Date> = []
            for document in querySnapshot!.documents {
                let data = document.data()
                let id = document.documentID
                let title = data["title"] as? String ?? "Untitled"
                let timestamp: Timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                let date = timestamp.dateValue()
                
                let event = Event(id: id, title: title, date: date)
                fetchedEvents.append(event)
                eventDays.insert(Calendar.current.startOfDay(for: date))
            }
            DispatchQueue.main.async {
                self?.events = fetchedEvents.sorted { $0.date < $1.date }
                self?.daysWithEvents = eventDays
            }
        }
    }

    func events(onDay day: Date) -> [Event] {
        return events.filter {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }
    }
}





































private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()


struct Event: Identifiable {
    var id: String
    var title: String
    var date: Date
}


struct MyPostsView: View {
        var body: some View {
            Text("My Posts")
                .font(.title)
                .foregroundColor(.black)
        }
    }

 
struct MarketplaceView: View {
        var body: some View {
            Text("Marketplace")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
    }
    
    struct IconView: View {
        let systemName: String
        let label: String

        var body: some View {
            VStack {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }


    struct UserProfileView: View {
        var body: some View {
            Group {
                if let user = Auth.auth().currentUser {
                    VStack {
                        UserProfileImageView(photoURL: user.photoURL)
                        Text("\(user.displayName ?? "")")
                            .foregroundColor(.white)
                        Text("Email: \(user.email ?? "N/A")")
                            .foregroundColor(.white)
                    }
                } else {
                    Text("User Not Logged In")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }

    struct UserProfileImageView: View {
        var photoURL: URL?

        var body: some View {
            Group {
                if let photoURL = photoURL {
                    // Display user's profile image using the provided URL
                    // This could be implemented using FirebaseImageView or other methods to load an image from URL
                    Text("User's Profile Image")
                } else {
                    // Display a placeholder image if no photo URL is available
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
        }
    }
    struct NavigationButton<Destination>: View where Destination: View {
        var title: String
        var icon: String
        @Binding var isPresented: Bool
        var destination: () -> Destination

        var body: some View {
            VStack {
                Button(action: {
                    self.isPresented = true
                }) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(.white)
                        Text(title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .sheet(isPresented: $isPresented) {
                self.destination()
            }
        }
    }


    

    // Placeholder view for upcoming events, user posts, joining a band
    private func PlaceholderView(title: String, icon: String) -> some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding(.bottom, 20)
    }

    

class ProfileViewModel: ObservableObject 
{
    
    @Published var profileImage: UIImage?
    
    var inputImage: UIImage? {
        didSet {
            uploadProfileImage()
        }
    }
    
    init() {
    
    }
    
    private func uploadProfileImage() {
        guard let inputImage = self.inputImage else { return }
        

        self.profileImage = inputImage
        guard let imageData = inputImage.jpegData(compressionQuality: 0.4) else { return }
        
        let storageRef = Storage.storage().reference(withPath: "profile_pics/\(UUID().uuidString).jpg")
        
       
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Error uploading image: \(error?.localizedDescription ?? "No error description")")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                
                self.updateProfileImage(downloadURL: downloadURL)
            }
        }
    }
    
    private func updateProfileImage(downloadURL: URL) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = downloadURL
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile image successfully updated.")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}



    

    
   
struct FirebaseImageView: View {
    let photoURL: URL
    
    var body: some View {
        AsyncImage(url: photoURL) { image in
            // Image successfully loaded
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
           
            ProgressView()
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black, lineWidth: 4))
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}




struct FirestoreDataListView: View {
   
    var body: some View {
       
        Text("Placeholder for Firestore Data")
    }
}

struct EditProfileView: View {
    @Binding var profileName: String
    @Binding var profileAge: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("Name", text: $profileName)
                    TextField("Age", text: $profileAge)
                }
                Button(action: {
                    saveProfileDetails()
                }) {
                    Text("Save")
                }
            }
            .navigationBarTitle("Edit Profile")
        }
    }

    private func saveProfileDetails() {
        guard let userID = Auth.auth().currentUser?.uid else { return }


        let firestore = Firestore.firestore()
        let userDocument = firestore.collection("users").document(userID)
        userDocument.setData(["name": profileName, "age": profileAge], merge: true) { error in
            if let error = error {
                print("Error updating user profile: \(error.localizedDescription)")
            } else {
                print("Profile successfully updated")

                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = profileName
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Error updating Auth profile: \(error.localizedDescription)")
                    } else {
                        print("Auth profile updated")
                    }
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}



struct MyReminder: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var date: Date
    var isCompleted: Bool
}

struct ReminderView: View {
    @State private var reminders: [MyReminder] = []
    private var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List {
                ForEach(reminders) { reminder in
                    ReminderCell(reminder: reminder)
                }
                .onDelete(perform: deleteReminder)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Reminders", displayMode: .large)
            .navigationBarItems(trailing: Button(action: addReminder) {
                Image(systemName: "plus")
            })
            .onAppear(perform: fetchReminders)
        }
    }

    func fetchReminders() {
        db.collection("reminders")
            .order(by: "date")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                reminders = documents.compactMap { document in
                    do {
                        let reminder = try document.data(as: MyReminder.self)
                        return reminder
                    } catch {
                        print("Error decoding reminder: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }

    func addReminder() {
        let newReminder = MyReminder(
            title: "New Reminder",
            description: "Description of the new reminder",
            date: Date(),
            isCompleted: false
        )

        do {
            _ = try db.collection("reminders").addDocument(from: newReminder) { error in
                if let error = error {
                    print("Error adding reminder: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.reminders.append(newReminder)
                        print("Reminder added successfully.")
                    }
                }
            }
        } catch {
            print("Error encoding new reminder: \(error.localizedDescription)")
        }
    }


    func deleteReminder(at offsets: IndexSet) {
        // Check if there are any selected rows
        guard let index = offsets.first else {
            return
        }

        let reminderToDelete = reminders[index]

        // Remove the reminder from the 'reminders' array
        reminders.remove(at: index)

        // Remove the reminder from Firestore
        if let documentID = reminderToDelete.id {
            db.collection("reminders").document(documentID).delete { error in
                if let error = error {
                    print("Error deleting reminder: \(error.localizedDescription)")
                } else {
                    print("Reminder deleted successfully.")
                }
            }
        }
    }
}






struct ReminderCell: View {
    var reminder: MyReminder

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .font(.headline)
                Text(reminder.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(dateFormatter.string(from: reminder.date))
                .font(.caption)
                .foregroundColor(.gray)
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(reminder.isCompleted ? .green : .gray)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }
}

struct RandomScriptureVerseView: View {
    @State private var randomVerseIndex = 0

    var body: some View {
        VStack {
            ScriptureCardView(verse: scriptureVerses[randomVerseIndex])
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.purple.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(15)
                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                .padding()
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5), value: randomVerseIndex)
        }
        .onAppear {
            randomVerseIndex = Int.random(in: 0..<scriptureVerses.count)
        }
    }
}

struct ScriptureCardView: View {
    var verse: String

    var body: some View {
        ZStack {
            // Background Blur
            Rectangle()
                .fill(Color.clear)
                .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                .cornerRadius(15)

            // Verse Text
            Text(verse)
                .font(.custom("Merriweather", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .animation(.easeIn(duration: 0.5), value: verse)
                .shadow(color: .gray, radius: 3, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// VisualEffectBlur Component
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}




struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

    
let scriptureVerses = [
    "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life. - John 3:16",
    "The Lord is my shepherd; I shall not want. - Psalm 23:1",
    "I can do all things through him who strengthens me. - Philippians 4:13",
    "Trust in the Lord with all your heart, and do not lean on your own understanding. - Proverbs 3:5",
    "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope. - Jeremiah 29:11",
    "In the beginning, God created the heavens and the earth. - Genesis 1:1",
    "But they who wait for the Lord shall renew their strength; they shall mount up with wings like eagles. - Isaiah 40:31",
    "And we know that for those who love God all things work together for good, for those who are called according to his purpose. - Romans 8:28",
    "The Lord is my light and my salvation; whom shall I fear? - Psalm 27:1",
    "Come to me, all who labor and are heavy laden, and I will give you rest. - Matthew 11:28",
    "For by grace you have been saved through faith. And this is not your own doing; it is the gift of God. - Ephesians 2:8",
    "In all your ways acknowledge him, and he will make straight your paths. - Proverbs 3:6",
    "I have been crucified with Christ. It is no longer I who live, but Christ who lives in me. - Galatians 2:20",
    "For the wages of sin is death, but the free gift of God is eternal life in Christ Jesus our Lord. - Romans 6:23",
    "Jesus said to him, 'I am the way, and the truth, and the life. No one comes to the Father except through me.' - John 14:6",
    "Be strong and courageous. Do not fear or be in dread of them, for it is the Lord your God who goes with you. He will not leave you or forsake you. - Deuteronomy 31:6",
    "God is our refuge and strength, a very present help in trouble. - Psalm 46:1",
    "For we walk by faith, not by sight. - 2 Corinthians 5:7",
    "He heals the brokenhearted and binds up their wounds. - Psalm 147:3",
    "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness. - Galatians 5:22",
    "Cast all your anxieties on him, because he cares for you. - 1 Peter 5:7",
    "The Lord is near to the brokenhearted and saves the crushed in spirit. - Psalm 34:18",
    "But seek first the kingdom of God and his righteousness, and all these things will be added to you. - Matthew 6:33",
    "I have said these things to you, that in me you may have peace. In the world you will have tribulation. But take heart; I have overcome the world. - John 16:33",
    "For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God. - Ephesians 2:8",
    "This is the day that the Lord has made; let us rejoice and be glad in it. - Psalm 118:24",
    "Jesus Christ is the same yesterday and today and forever. - Hebrews 13:8",
    "Do not be anxious about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God. - Philippians 4:6",
    "The name of the Lord is a strong tower; the righteous run into it and are safe. - Proverbs 18:10",
    "And let us not grow weary of doing good, for in due season we will reap, if we do not give up. - Galatians 6:9",
    "For with God nothing shall be impossible. - Luke 1:37",
    "The Lord your God is in your midst, a mighty one who will save; he will rejoice over you with gladness; he will quiet you by his love; he will exult over you with loud singing. - Zephaniah 3:17",
    "The Lord is gracious and righteous; our God is full of compassion. - Psalm 116:5",
    "Give thanks to the Lord, for he is good; his love endures forever. - Psalm 107:1",
    "Greater love has no one than this, that someone lay down his life for his friends. - John 15:13",
]

 


    
    
struct RegistrationView: View {
    @Binding var isSideMenuOpen: Bool
    @State private var fullName = ""
    @State private var emailOrMobile = ""
    @State private var password = ""
    @State private var confirmationPassword = ""
    @State private var isEmailOrMobileValid = true
    @State private var errorMessage = ""
    @Binding var registrationSuccess: Bool
    @State private var isRegistrationInfoComplete = false
    @State private var isCredentialsValid = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Registration")
                        .font(.title)
                    
                    VStack(spacing: 10) {
                        TextField("Full Name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email or mobile number", text: $emailOrMobile)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(isEmailOrMobileValid ? .primary : .red)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirmation", text: $confirmationPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    
                    Button("Register", action: {
                        if !fullName.isEmpty && isValidEmailOrPhone(emailOrMobile) && !password.isEmpty && password == confirmationPassword {
                            // Firebase registration call
                            Auth.auth().createUser(withEmail: emailOrMobile, password: password) { authResult, error in
                                if let error = error {
                                    // Handle errors such as email format incorrect, weak password, etc.
                                    self.errorMessage = error.localizedDescription
                                    self.isCredentialsValid = false
                                } else {
                                    // Registration successful
                                    self.registrationSuccess = true
                                    self.isCredentialsValid = true

                                    // Create a UserProfile instance
                                    let userProfile = UserProfile(
                                        name: self.fullName,
                                        email: self.emailOrMobile,
                                        profilePicture: "", // Set profile picture URL if available
                                        bio: "", // Set user's bio if available
                                        age: 0, // Set user's age if available
                                        location: "", // Set user's location if available
                                        phoneNumber: "" // Set user's phone number if available
                                    )

                                    // Store the UserProfile instance in Firestore
                                    let userUID = authResult?.user.uid ?? ""
                                    let userCollection = Firestore.firestore().collection("users")
                                    userCollection.document(userUID).setData(userProfile.dictionary) { error in
                                        if let error = error {
                                            print("Error storing user profile: \(error.localizedDescription)")
                                        } else {
                                            print("User profile stored successfully")
                                        }
                                    }
                                }
                            }
                        } else {
                            // Handle validation errors
                            if password != confirmationPassword {
                                self.errorMessage = "Passwords do not match"
                            } else if !isValidEmailOrPhone(emailOrMobile) {
                                self.errorMessage = "Invalid email or phone number"
                            } else {
                                self.errorMessage = "Please fill all fields correctly"
                            }
                            self.isCredentialsValid = false
                        }
                    })

                    Divider()
                    
                    if !errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 5)
                    }
                    
                    if registrationSuccess {
                        Text("")
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            Image(systemName: "")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()
        }
        .background(
            NavigationLink(destination: AgapeAndGloriaView(isUserProfileSheetPresented: .constant(false)), isActive: $isCredentialsValid) {
                EmptyView()
            }
            .opacity(0)
        )
        .navigationBarTitle("")
    }
}
func checkUserExistence(emailOrMobile: String, completion: @escaping (Bool) -> Void) {
    Auth.auth().fetchSignInMethods(forEmail: emailOrMobile) { methods, error in
        if let error = error 
        {
            print("Error checking user existence: \(error.localizedDescription)")
            
            completion(false)
            
        } else if let methods = methods {
            if methods.isEmpty {
               
                completion(false)
            } else {
                
                completion(true)
            }
        }
    }
}

    struct RegistrationView_Previews: PreviewProvider {
        static var previews: some View {
            let isSideMenuOpen = false
            let registrationSuccess = Binding<Bool>(
                get: { false },
                set: { _ in }
            )
            
            return RegistrationView(isSideMenuOpen: .constant(isSideMenuOpen), registrationSuccess: registrationSuccess)
        }
    }
    

    struct SideMenuView: View {
        @Binding var isOpen: Bool
        
        var body: some View {
            GeometryReader { geometry in
                VStack {
                    Text("Side Menu Content")
                        .font(.title)
                        .padding(.top, 20)
                    
                    Divider()
                    
                    Button(action: {
                       
                    }) {
                        Text("Menu Item 1")
                            .font(.headline)
                            .padding()
                    }
                    
                    Button(action: {
                        // Add action for another menu item here
                    }) {
                        Text("Menu Item 2")
                            .font(.headline)
                            .padding()
                    }
                    
                    
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.7)
                .background(Color.white)
                .offset(x: isOpen ? 0 : -geometry.size.width)
                .animation(.easeInOut, value: isOpen)
            }
        }
    }
    


struct ResetPasswordView: View 
{
    @Binding var resetEmail: String
    @State private var isResetSuccessful = false
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Enter the email associated with your account and we'll send an email with instructions to reset your password.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            CustomTextField(placeholder: "Email", text: $resetEmail, systemImage: "envelope")
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .padding()
            } else {
                Button(action: resetPassword) {
                    Text("Send Instructions")
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
            }

            if isResetSuccessful {
                Text("Password reset instructions have been sent to \(resetEmail). Please check your inbox.")
                    .foregroundColor(.green)
                    .padding()
                    .transition(.opacity)
                    .animation(.easeInOut)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .transition(.opacity)
                    .animation(.easeInOut)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $isResetSuccessful) {
            Alert(title: Text("Check Your Email"), message: Text("Password reset instructions have been sent to \(resetEmail)."), dismissButton: .default(Text("OK")))
        }
    }

    private func resetPassword() {
        isProcessing = true
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            isProcessing = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isResetSuccessful = true
            }
        }
    }
}

    
    
    
struct UserView: View {
    @State var user: User
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
        
        var body: some View{
            Form {
                Section(header: Text("User Profile").font(.title).padding()) {
                    ZStack {
                        if let inputImage = inputImage {
                            Image(uiImage: inputImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        }
                    }
                    
                    TextField("Name", text: $user.name)
                        .font(.headline)
                    
                    TextField("Email", text: $user.email)
                        .font(.headline)
                    
                    TextField("Bio", text: $user.bio)
                        .font(.headline)
                    
                    TextField("Phone Number", text: $user.phoneNumber)
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, isImagePickerPresented: $showingImagePicker) // Add the missing argument for presentation state
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
        }
    }
    
    struct User {
        var name: String
        var email: String
        var profilePicture: String // Store the URL or file path of the user's profile picture
        var bio: String // A short bio or description about the user
        var age: Int // User's age
        var location: String // User's location or address
        var phoneNumber: String // User's contact number
        // Add more properties as needed
        
        init(name: String, email: String, profilePicture: String, bio: String, age: Int, location: String, phoneNumber: String) {
            self.name = name
            self.email = email
            self.profilePicture = profilePicture
            self.bio = bio
            self.age = age
            self.location = location
            self.phoneNumber = phoneNumber
        }
    }
    
    struct UserView_Previews: PreviewProvider {
        static var previews: some View {
            UserView(user: User(name: "", email: "", profilePicture: "", bio: "", age: 0, location: "", phoneNumber: ""))
        }
    }
    
    
    

    
    struct RegistrationSuccessView: View {
        @Binding var isUserProfileSheetPresented: Bool
        
        var body: some View {
            AgapeAndGloriaView(isUserProfileSheetPresented: $isUserProfileSheetPresented)
        }
    }
    
    



    

    
    struct ImagePickerView: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var isImagePickerPresented: Bool
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(isImagePickerPresented: $isImagePickerPresented, image: $image)
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {}
        
        // Coordinator to handle UIImagePickerControllerDelegate
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            @Binding var isCoordinatorImagePickerPresented: Bool
            @Binding var imageInCoordinator: UIImage?
            
            init(isImagePickerPresented: Binding<Bool>, image: Binding<UIImage?>) {
                _isCoordinatorImagePickerPresented = isImagePickerPresented
                _imageInCoordinator = image
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    imageInCoordinator = uiImage
                }
                isCoordinatorImagePickerPresented = false
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                isCoordinatorImagePickerPresented = false
            }
        }
    }








//struct SongListView: View {
//    @State private var songs: [Song] = []
//    @State private var searchText = ""
//    @State private var isLoading = false
//    @State private var showingAddSongView = false
//    @State private var showingPasswordPrompt = false
//    @State private var passwordInput = ""
//    @State private var passwordIncorrect = false
//    @State private var newSongTitle = ""
//    @State private var newSongLyrics = ""
//    @State private var newSongNotes = ""
//    @State private var showingSongDetails = false
//    @State private var selectedSong: Song?
//    private let db = Firestore.firestore()
//    private let addSongPassword = "YourPassword"
//
//    var filteredSongs: [Song] {
//        searchText.isEmpty ? songs : songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
//    }
//
//    // Load songs from Firebase
//    private func loadSongs() {
//        isLoading = true
//        db.collection("songs").getDocuments { (querySnapshot, error) in
//            isLoading = false
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                songs = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Song.self)
//                } ?? []
//            }
//        }
//    }
//
//    private func addSong() {
//        let newSong = Song(title: newSongTitle, lyrics: newSongLyrics)
//        db.collection("songs").addDocument(data: [
//            "title": newSong.title,
//            "lyrics": newSong.lyrics
//        ]) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                newSongTitle = ""
//                newSongLyrics = ""
//                showingAddSongView = false
//                loadSongs()
//            }
//        }
//    }
//
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                Text("Total Songs: \(songs.count)")
//                    .font(.headline)
//                    .padding()
//
//                SearchBar(text: $searchText)
//
//                if isLoading {
//                    ProgressView()
//                } else {
//                    List(filteredSongs) { song in
//                        Button(action: {
//                            self.selectedSong = song
//                            self.showingSongDetails = true
//                        }) {
//                            Text(song.title)
//                        }
//                    }
//                }
//
//                Button("Add Song", action: { showingPasswordPrompt = true })
//                    .padding()
//                    .background(Color.black)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//
//                // Password prompt
//                if showingPasswordPrompt {
//                    SecureField("Admin password", text: $passwordInput)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(passwordIncorrect ? Color.red : Color.gray, lineWidth: 1))
//
//                    Button("Submit", action: {
//                        if passwordInput == addSongPassword {
//                            showingAddSongView = true
//                            showingPasswordPrompt = false
//                            passwordIncorrect = false
//                        } else {
//                            passwordIncorrect = true
//                            passwordInput = ""
//                            // Optionally show an error message
//                        }
//                    })
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//
//                // Form for adding a new song
//                if showingAddSongView {
//                    TextField("Song Title", text: $newSongTitle)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    TextEditor(text: $newSongLyrics)
//                        .frame(minHeight: 150, idealHeight: 200)
//                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
//                        .padding()
//
//                    TextField("Song Notes", text: $newSongNotes) // Text field for song notes
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    Button("Save Song", action: addSong)
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .onAppear(perform: loadSongs)
//        .sheet(isPresented: $showingSongDetails) {
//            if let selectedSong = selectedSong {
//                VStack {
//                    Text(selectedSong.title).font(.headline)
//                    ScrollView {
//                        Text(selectedSong.lyrics)
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}
//
//struct Song: Identifiable, Codable {
//    @DocumentID var id: String?
//    var title: String
//    var lyrics: String
//    var notes: String? // Optional property for song notes
//}
//
//struct SearchBar: View {
//    @Binding var text: String
//
//    var body: some View {
//        HStack {
//            TextField("Search", text: $text)
//                .padding(.horizontal, 10)
//            Button(action: {
//                text = ""
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//            }
//            .padding(.trailing, 10)
//            .opacity(text.isEmpty ? 0 : 1)
//            .animation(.default)
//        }
//    }
//}
//

struct SongListView: View {
    @State private var songs: [Song] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var showingAddSongView = false
    @State private var showingPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var passwordIncorrect = false
    @State private var newSongTitle = ""
    @State private var newSongLyrics = ""
    @State private var newSongNotes = ""
    @State private var showingSongDetails = false
    @State private var selectedSong: Song?
    private let db = Firestore.firestore()
    private let addSongPassword = "YourPassword"
    
    var filteredSongs: [Song] {
        searchText.isEmpty ? songs : songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    // Load songs from Firebase
    private func loadSongs() {
        isLoading = true
        db.collection("songs").getDocuments { (querySnapshot, error) in
            isLoading = false
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                songs = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Song.self)
                } ?? []
            }
        }
    }
    
    private func addSong() {
        let newSong = Song(title: newSongTitle, lyrics: newSongLyrics)
        db.collection("songs").addDocument(data: [
            "title": newSong.title,
            "lyrics": newSong.lyrics
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                newSongTitle = ""
                newSongLyrics = ""
                showingAddSongView = false
                loadSongs()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Total Songs: \(songs.count)")
                    .font(.headline)
                    .padding()

                if isLoading {
                    ProgressView()
                }

                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(filteredSongs) { song in
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)

                        Text(song.lyrics)
                            .font(.body)
                            .foregroundColor(.secondary)

                        if let notes = song.notes, !notes.isEmpty {
                            Text("Notes: \(notes)")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                }

                Button("Add Song", action: { showingPasswordPrompt = true })
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .navigationTitle("Song List")
            .navigationBarItems(trailing: Button("View Songs", action: { showingSongDetails = true }))
        }

        
        .onAppear(perform: loadSongs)
        .sheet(isPresented: $showingPasswordPrompt) {
            VStack {
                SecureField("Admin password", text: $passwordInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(passwordIncorrect ? Color.red : Color.gray, lineWidth: 1))
                
                Button("Submit", action: {
                    if passwordInput == addSongPassword {
                        showingAddSongView = true
                        showingPasswordPrompt = false
                        passwordIncorrect = false
                    } else {
                        passwordIncorrect = true
                        passwordInput = ""
                        // Optionally show an error message
                    }
                })
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .sheet(item: $selectedSong) { song in
            VStack {
                Text(song.title).font(.headline)
                ScrollView {
                    Text("Lyrics:\n\(song.lyrics)")
                    if let notes = song.notes {
                        Text("Notes:\n\(notes)")
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSongView) {
            VStack {
                TextField("Song Title", text: $newSongTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $newSongLyrics)
                    .frame(minHeight: 150, idealHeight: 200)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    .padding()
                
                TextField("Song Notes", text: $newSongNotes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save Song", action: addSong)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

struct Song: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var lyrics: String
    var notes: String?
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal, 10)
            Button(action: {
                text = ""
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 10)
            .opacity(text.isEmpty ? 0 : 1)
            .animation(.default)
        }
    }
}


















    
    struct SongListView_Previews: PreviewProvider {
        static var previews: some View {
            SongListView()
        }
    }
    
struct Announcement: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var message: String
    var date: Date
    var announcerName: String
}

extension Announcement {
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "message": message,
            "date": Timestamp(date: date),
            "announcerName": announcerName
        ]
    }
}



class AnnouncementViewModel: ObservableObject {
   @Published var announcements = [Announcement]()

   private var db = Firestore.firestore()

   func fetchAnnouncements() {
      // Calculate the date 7 days ago
      let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

      db.collection("announcements")
        .whereField("date", isGreaterThan: sevenDaysAgo)
        .order(by: "date", descending: true)
        .getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Error fetching announcements: \(e.localizedDescription)")
                return
            }
            if let snapshotDocuments = querySnapshot?.documents {
                DispatchQueue.main.async {
                    self.announcements = snapshotDocuments.compactMap { document in
                        try? document.data(as: Announcement.self)
                    }
                }
            }
        }
   }
}



struct AnnouncementView: View {
    @ObservedObject var viewModel = AnnouncementViewModel()

    var body: some View {
        List(viewModel.announcements) { announcement in
            NavigationLink(destination: AnnouncementDetailView(announcement: announcement)) {
                VStack(alignment: .leading) {
                    Text(announcement.title).font(.headline)
                    Text("Announced by \(announcement.announcerName)").font(.subheadline)
                    Text(formatDate(announcement.date)).font(.footnote)
                }
            }
        }
        .onAppear {
            viewModel.fetchAnnouncements()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AnnouncementDetailView: View {
    var announcement: Announcement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(announcement.title).font(.headline)
                Text(announcement.message).font(.body)
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Content", displayMode: .inline)
    }
}




struct AddAnnouncementView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var announcerName = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToAnnouncements = false
    @State private var passwordIncorrect = false

    let correctPassword = "JesusNiourRedeemer@"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Add a New Announcement")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    Divider().padding(.vertical)

                    GroupBox(label: Label("Announcer Name", systemImage: "person.fill")) {
                        TextField("Enter your name", text: $announcerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    GroupBox(label: Label("Title", systemImage: "textformat.abc")) {
                        TextField("Enter title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    GroupBox(label: Label("Content", systemImage: "text.bubble")) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    }

                    GroupBox(label: Label("Admin password", systemImage: "lock.fill")) {
                        SecureField("Enter password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(passwordIncorrect ? .red : .primary)
                    }

                    Spacer()

                    Button(action: saveAnnouncement) {
                        Text(isLoading ? "Saving..." : "Save Announcement")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isLoading ? Color.gray : Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                    .disabled(isLoading)

                    NavigationLink("View Current Announcements", destination: AnnouncementView())
                        .font(.headline)
                        .padding(.top)

                }
                .padding()
            }
            .navigationBarTitle("Add Announcement", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveAnnouncement() {
        passwordIncorrect = false

        guard !title.isEmpty, !content.isEmpty, !announcerName.isEmpty else {
            alertMessage = "All the fields must be filled"
            showAlert = true
            return
        }

        guard password == correctPassword else {
            alertMessage = "Incorrect password."
            showAlert = true
            passwordIncorrect = true
            return
        }

        isLoading = true
        let newAnnouncement = Announcement(title: title, message: content, date: Date(), announcerName: announcerName)

        let db = Firestore.firestore()
        db.collection("announcements").addDocument(data: newAnnouncement.toDictionary()) { error in
            isLoading = false
            if let error = error {
                alertMessage = "Error saving announcement: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Announcement added successfully"
                showAlert = true
                navigateToAnnouncements = true // Trigger navigation on success
                title = ""
                content = ""
                announcerName = ""
                password = ""
            }
        }
    }
}



struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct CustomTextEditor: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: 150)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            .padding(.horizontal)
    }
}

struct SaveButton: View {
    var isLoading: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(isLoading ? "Saving..." : "Save Announcement")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLoading ? Color.gray : Color.black)
                .cornerRadius(10)
                .animation(.easeInOut, value: isLoading)
        }
        .padding(.horizontal)
    }
}

struct ViewAnnouncementsLink<Destination: View>: View {
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Text("View Current Announcements")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

    struct AboutView: View {
        var body: some View {
            NavigationView {
                VStack {
                    
                    
                    Text(".............Kuusu app ni here.................")
                        .padding()
                    
                    Spacer()
                    
                    Text("Version: 1.0")
                        .foregroundColor(.gray)
                }
                .navigationTitle("About")
            }
        }
    }
    
    struct AboutView_Previews: PreviewProvider 
{
        static var previews: some View {
            AboutView()
        }
    }
struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var isFeedbackSubmitted = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Provide your feedback")
                    .padding()
                
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 200)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                Button(action: submitFeedback) {
                    Text("Submit Feedback")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(feedbackText.isEmpty)
            }
            .navigationBarTitle("Feedback")
            .alert(isPresented: $isFeedbackSubmitted) {
                Alert(
                    title: Text("Submitted"),
                    message: Text("Thank you for submitting your feedback!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func submitFeedback() {
        UserDefaults.standard.set(feedbackText, forKey: "UserFeedback")
        
        self.feedbackText = ""
        self.isFeedbackSubmitted = true
    }
}

    
    struct FeedbackView_Previews: PreviewProvider {
        static var previews: some View {
            FeedbackView()
        }
    }
   


    
//
//struct Chat: Identifiable {
//    let id = UUID()
//    let contactName: String
//    let lastMessage: String
//    let unreadMessagesCount: Int
//    let lastMessageTime: Date
//}
//


struct FirebaseMessage: Codable, Identifiable {
    var id: String
    var content: String
    var senderID: String
    var timestamp: Date
    var status: String // Add the status field

    init(id: String = UUID().uuidString, content: String, senderID: String, timestamp: Date = Date(), status: String = "Sent") {
        self.id = id
        self.content = content
        self.senderID = senderID
        self.timestamp = timestamp
        self.status = status
    }
}


struct UserProfile: Codable, Identifiable {
    var name: String
    var email: String
    var profilePicture: String
    var bio: String
    var age: Int
    var location: String
    var phoneNumber: String

    var id: String {
        name
    }

    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "profilePicture": profilePicture,
            "bio": bio,
            "age": age,
            "location": location,
            "phoneNumber": phoneNumber
        ]
    }
}




struct UserSelectionView: View {
    @State private var users: [UserProfile] = []
    @State private var selectedUserUID: String?
    private var usersCollection = Firestore.firestore().collection("users")
    
    var body: some View {
        NavigationView {
            if users.isEmpty {
               
                ProgressView("Still working on this...")
                
                    .onAppear(perform: loadUsers)
            } else {
                List(users) { user in
                    Button(action: {
                        startConversationWithSelectedUser(selectedUserUID: user.id)
                    }) {
                        Text(user.name)
                    }
                }
                .navigationBarTitle("Agape Users")
                .onAppear(perform: loadUsers)
            }
        }
    }
    
    
    func loadUsers() {
        usersCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user profiles: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                print("Fetched \(documents.count) user profiles")
                for document in documents {
                    do {
                        let user = try document.data(as: UserProfile.self)
                        print("Decoded user profile: \(user)") // Debug: Print the decoded user
                        DispatchQueue.main.async {
                            users.append(user)
                        }
                    } catch {
                        print("Error decoding user profile: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


    
func startConversationWithSelectedUser(selectedUserUID: String) {
    guard let currentUserUID = Auth.auth().currentUser?.uid else {
        return
    }
        
        
        // Check if a conversation already exists with the selected user
        Firestore.firestore().collection("conversations")
            .whereField("participants", arrayContains: currentUserUID)
            .whereField("participants", arrayContains: selectedUserUID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching conversations: \(error.localizedDescription)")
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // Conversation already exists, navigate to the chat view with the existing conversation
                    if let conversationID = documents.first?.documentID {
                        let conversation = Conversation(uid: conversationID, participants: [currentUserUID, selectedUserUID])
                        // Navigate to the chat view with the existing conversation
                        // You can implement your navigation logic here
                    }
                } else {
                    // Conversation does not exist, create a new conversation
                    let newConversation = Conversation(uid: UUID().uuidString, participants: [currentUserUID, selectedUserUID])
                    
                    Firestore.firestore().collection("conversations")
                        .addDocument(data: newConversation.dictionary) { (error) in
                            if let error = error {
                                print("Error creating conversation: \(error.localizedDescription)")
                            } else
                            {
                               
                            }
                        }
                }
            }
    }


    
    struct Conversation {
        var uid: String
        var participants: [String]
        
        var dictionary: [String: Any] {
            return [
                "uid": uid,
                "participants": participants
            ]
        }
    }

   
    
 
    
    
    struct UserSelectionView_Previews: PreviewProvider {
        static var previews: some View {
            UserSelectionView()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    



struct ChatView: View {
    @State private var newMessage = ""
    @State private var messages: [FirebaseMessage] = []
    private var messagesRef = Firestore.firestore().collection("messages")
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
        .navigationBarTitle("Chat")
        .onAppear(perform: authenticateAndLoadMessages)
    }
    
    private func authenticateAndLoadMessages() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    return
                }
                self.loadMessages()
            }
        } else {
            self.loadMessages()
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty, let senderID = Auth.auth().currentUser?.uid else {
            print("Error: Message is empty or user is not authenticated.")
            return
        }
        
        let messageData: [String: Any] = [
            "content": newMessage,
            "timestamp": Timestamp(),
            "senderID": senderID,
            "status": "Sent"
        ]
        
        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                newMessage = ""
            }
        }
    }
    private func loadMessages() {
        messagesRef.order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                // Print document changes for debugging
                print("Received snapshot changes: \(String(describing: querySnapshot?.documentChanges))")
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                // Clear the existing messages before updating with the new ones
                messages.removeAll()
                
                messages = documents.compactMap { document in
                    var message = try? document.data(as: FirebaseMessage.self)
                    // Ensure the message is not nil and set its id to the document's documentID
                    message?.id = document.documentID
                    return message
                }
                
                print("Updated messages: \(messages)")
            }
    }


    
}

struct MessageView: View {
    var message: FirebaseMessage
    let currentUserID = Auth.auth().currentUser?.uid

    var body: some View {
        HStack {
           
            if message.senderID == currentUserID
            {
                Spacer()
            }

            Text(message.content)
                .padding(10)
                .foregroundColor(.white)
                .background(message.senderID == currentUserID ? Color.black : Color.gray)
                .cornerRadius(20)
                .frame(maxWidth: 250, alignment: message.senderID == currentUserID ? .trailing : .leading)

            if message.senderID != currentUserID {
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}




    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct UserData: Codable, Identifiable {
        @DocumentID var id: String?
        var name: String
        var email: String
    }
    
    
    private func changePassword()
{
        // Implement Firebase Auth password change logic here
        // You'll need to prompt the user to enter the current password and a new password
        // Update the user's password using Firebase Auth
    }
    
    private func enableTwoFactorAuth() {
        // Implement Firebase Two-Factor Authentication setup logic here
        // This typically involves sending a verification code to the user's phone number or email
        // and enabling 2FA in Firebase Auth settings
    }
    
    private func loadUserData(completion: @escaping (UserData?) -> Void) {
        // Load user-specific data from Firestore here
        // This assumes you have a Firestore collection for user data
        // and the user is authenticated
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        let userData = try document.data(as: UserData.self)
                        completion(userData)
                    } catch {
                        print("Error decoding user data: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    // Handle the case where the document doesn't exist
                    completion(nil)
                }
            }
        }
    }
    
    
    
struct LanguageSelectionView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"

    let languages = ["English", "Swahili", "French", "Lingala","Spanish", "German"]

    var body: some View {
        List {
            ForEach(languages, id: \.self) { language in
                HStack {
                    Text(language)
                    Spacer()
                    if language == selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundColor(.black)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = language
                   
                }
            }
        }
        .navigationBarTitle("Select Language", displayMode: .inline)
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var theme: ColorScheme = .light
    
    func toggleTheme() {
        theme = (theme == .light) ? .dark : .light
    }
}



/////////
struct SettingsView: View {
    @AppStorage("theme") private var selectedTheme: String = "Light"
    @State private var receiveNotifications: Bool = true
    @State private var isLoggedOut: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Receive Notifications", isOn: $receiveNotifications)
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: LanguageSelectionView()) {
                        Text("Language")
                    }
                    NavigationLink(destination: AccountPreferencesView()) {
                        Text("Account Preferences")
                    }
                }
                
                Section {
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            isLoggedOut = true
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .alert(isPresented: $isLoggedOut) {
                Alert(
                    title: Text("Signed Out"),
                    message: Text("You have successfully signed out."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct AccountPreferencesView: View {
        @State private var displayName: String = "Fahila Making"
        @State private var email: String = "fahila@gmail.com"
        @State private var password: String = ""
        
        var body: some View {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Display Name", text: $displayName)
                    TextField("Email", text: $email)
                }
                
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $password)
                    SecureField("New Password", text: $password)
                    SecureField("Confirm New Password", text: $password)
                }
                
                Section(header: Text("Account Actions")) {
                    Button(action: {
                        // Implement logic to update the user's profile
                    }) {
                        Text("Update Profile")
                    }
                    
                    Button(action: {
                        // Implement logic to change the user's password
                    }) {
                        Text("Change Password")
                    }
                    
                    Button(action: {
                        // Implement logic to delete the user's account
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Account Preferences", displayMode: .inline)
        }
    }
    
    struct AccountPreferencesView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                AccountPreferencesView()
            }
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
    
    
    
    
    
    class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var imagePicker: UIImagePickerController!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCamera()
        }
        
        func setupCamera() {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .rear
            imagePicker.showsCameraControls = true
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Show the preview screen for photos
                showMediaPreview(image: image)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        
        func showMediaPreview(image: UIImage) {
            let previewVC = MediaPreviewViewController()
            previewVC.mediaToShow = image
            self.navigationController?.pushViewController(previewVC, animated: true)
        }
    }
    
    class MediaPreviewViewController: UIViewController {
        
        var mediaToShow: UIImage?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let mediaView = UIImageView()
            mediaView.contentMode = .scaleAspectFit
            mediaView.frame = view.bounds
            view.addSubview(mediaView)
            
            if let media = mediaToShow {
                mediaView.image = media
            }
            
            
            // You can add buttons or controls for editing or sending
            
        }
    }
    
    
    
    
    struct CameraViewControllerPreview: PreviewProvider {
        static var previews: some View {
            NavigationView {
                CameraViewControllerWrapper()
            }
        }
    }
    
    struct CameraViewControllerWrapper: UIViewControllerRepresentable {
        typealias UIViewControllerType = CameraViewController
        
        func makeUIViewController(context: Context) -> CameraViewController {
            return CameraViewController()
        }
        
        func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
            // Update if needed
        }
    }
    
    struct MediaPreviewViewControllerPreview: PreviewProvider {
        static var previews: some View {
            NavigationView {
                MediaPreviewViewControllerWrapper()
            }
        }
    }
    
    struct MediaPreviewViewControllerWrapper: UIViewControllerRepresentable {
        typealias UIViewControllerType = MediaPreviewViewController
        
        func makeUIViewController(context: Context) -> MediaPreviewViewController {
            return MediaPreviewViewController()
        }
        
        func updateUIViewController(_ uiViewController: MediaPreviewViewController, context: Context) {
            // Update if needed
        }
    }
    
    
    struct CallView: View {
        enum CallState {
            case idle
            case ringing
            case inCall
            case callEnded
        }
        
        @State private var callState: CallState = .idle
        @State private var isMicrophoneMuted = false
        @State private var isCameraEnabled = true // Camera is enabled by default
        @State private var isSpeakerEnabled = false // Speaker is disabled by default
        @State private var callDuration: TimeInterval = 0.0
        @State private var participants = ["John", "Jane"]
        
        var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            // End the call
                            callState = .callEnded
                        }) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                    
                    switch callState {
                    case .idle:
                        Text("Connected")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        HStack {
                            Button(action: {
                                // Mute/unmute microphone
                                isMicrophoneMuted.toggle()
                            }) {
                                Image(systemName: isMicrophoneMuted ? "mic.slash.fill" : "mic.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(isMicrophoneMuted ? .red : .white)
                                    .padding()
                            }
                            Button(action: {
                                // Enable/disable camera
                                isCameraEnabled.toggle()
                            }) {
                                Image(systemName: isCameraEnabled ? "video.fill" : "video.slash.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(isCameraEnabled ? .green : .red)
                                    .padding()
                            }
                            Button(action: {
                                // Toggle speaker
                                isSpeakerEnabled.toggle()
                            }) {
                                Image(systemName: isSpeakerEnabled ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(isSpeakerEnabled ? .green : .white)
                                    .padding()
                            }
                        }
                        Spacer()
                        Button(action: {
                            // End the call
                            callState = .callEnded
                        }) {
                            Text("End Call")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .cornerRadius(20)
                        }
                    case .ringing:
                        Text("Incoming Call")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        Text("From: John")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        HStack {
                            Button(action: {
                                // Accept the incoming call
                                callState = .inCall
                            }) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                                    .padding()
                            }
                            Button(action: {
                                // Reject the incoming call
                                callState = .callEnded
                            }) {
                                Image(systemName: "phone.down.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    case .inCall:
                        Text("In Call")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        HStack {
                            Text("Duration: \(Int(callDuration))s")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                // End the call
                                callState = .callEnded
                            }) {
                                Image(systemName: "phone.down.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    case .callEnded:
                        Text("Call Ended")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                // Back to the chat view or wherever you initiated the call
                                callState = .idle
                            }) {
                                Text("Back")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.black)
                                    .cornerRadius(20)
                            }
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                // Simulate call duration increment
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    if callState == .inCall {
                        callDuration += 1.0
                    }
                }
            }
        }
    }
    
    struct CallView_Previews: PreviewProvider {
        static var previews: some View {
            CallView()
        }
    }
    
    
    
    struct CallHistoryView: View {
        struct CallRecord: Identifiable {
            let id = UUID()
            let caller: String
            let callType: CallType
            let callDuration: TimeInterval
            let timestamp: Date
        }
        
        enum CallType: String {
            case voice = "Voice Call"
            case video = "Video Call"
        }
        
        @State private var callRecords: [CallRecord] = [] // Store your call history records here
        @State private var selectedFilter: CallType = .voice // Default filter
        @State private var isShowingDetail = false
        @State private var selectedRecord: CallRecord?
        
        var body: some View {
            NavigationView {
                VStack {
                    Picker("Filter", selection: $selectedFilter) {
                        Text("Voice").tag(CallType.voice)
                        Text("Video").tag(CallType.video)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    List(callRecords.filter { $0.callType == selectedFilter }) { record in
                        Button(action: {
                            selectedRecord = record
                            isShowingDetail = true
                        }) {
                            CallRecordRow(record: record)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Spacer()
                }
                .navigationBarTitle("Call History")
            }
            .sheet(isPresented: $isShowingDetail) {
                if let selectedRecord = selectedRecord {
                    CallRecordDetail(record: selectedRecord)
                }
            }
        }
    }
    
    struct CallRecordRow: View {
        let record: CallHistoryView.CallRecord
        
        
        private func formattedTimestamp(for date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(record.caller)
                        .font(.headline)
                    Text("\(formattedTimestamp(for: record.timestamp))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("Duration: \(Int(record.callDuration))s")
                    .font(.subheadline)
            }
        }
    }
    
    struct CallRecordDetail: View {
        let record: CallHistoryView.CallRecord
        private func formattedTimestamp(for date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        
        
        var body: some View {
            VStack {
                Text(record.caller)
                    .font(.largeTitle)
                    .padding()
                Text("Call Type: \(record.callType.rawValue)")
                    .font(.title)
                    .padding()
                Text("Duration: \(Int(record.callDuration)) seconds")
                    .font(.title)
                    .padding()
                Text("Call Time: \(formattedTimestamp(for: record.timestamp))")
                    .font(.title)
                    .padding()
            }
        }
    }
    //
    //    extension CallHistoryView {
    //        // Helper function to format timestamps
    //        private func formattedTimestamp(for date: Date) -> String {
    //            let dateFormatter = DateFormatter()
    //            dateFormatter.dateStyle = .medium
    //            dateFormatter.timeStyle = .short
    //            return dateFormatter.string(from: date)
    //        }
    //    }
    
    struct CallHistoryView_Previews: PreviewProvider {
        static var previews: some View {
            CallHistoryView()
        }
    }
    
    
    
    struct UserRoleListView: View {
        @State private var isListVisible = false
        @State private var selectedRole: UserRole?
        
        var body: some View {
            VStack {
                HStack {
                    Text("User Role:")
                        .foregroundColor(.gray)
                    Button(action: {
                        withAnimation {
                            isListVisible.toggle()
                        }
                    }) {
                        Text(selectedRole?.rawValue ?? "Select Role")
                            .foregroundColor(selectedRole != nil ? .black : .gray)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                
                Divider() // Horizontal line
                
                if isListVisible {
                    ScrollView {
                        LazyVStack {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                HStack {
                                    Text(role.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if role == selectedRole {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.black)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRole = role
                                    isListVisible.toggle()
                                }
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .frame(height: 150) // Adjust the height as needed
                }
            }
        }
    }
    
    struct UserRoleListView_Previews: PreviewProvider {
        static var previews: some View {
            UserRoleListView()
        }
    }
    
    
    
    struct LeaderView: View {
        var body: some View {
            NavigationView {
                List {
                    NavigationLink(destination: Text("Leader's Dashboard")) {
                        Label("Leader's Dashboard", systemImage: "house.fill")
                    }
                    NavigationLink(destination: Text("Leader Profile")) {
                        Label("Leader Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: Text("Leader Settings")) {
                        Label("Leader Settings", systemImage: "gearshape.fill")
                    }
                }
                .listStyle(SidebarListStyle()) // Use sidebar style for navigation
                
                Text("Welcome, Leader!")
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Leader View")
        }
    }
    
    struct LeaderView_Previews: PreviewProvider {
        static var previews: some View {
            LeaderView()
        }
    }
    
    
    struct SingerView: View {
        var body: some View {
            NavigationView {
                List {
                    NavigationLink(destination: Text("Singer's Dashboard")) {
                        Label("Singer's Dashboard", systemImage: "house.fill")
                    }
                    NavigationLink(destination: Text("Singer Profile")) {
                        Label("Singer Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: Text("Singer Songs")) {
                        Label("Singer Songs", systemImage: "music.note.list")
                    }
                }
                .listStyle(SidebarListStyle())
                
                Text("Welcome, Singer!")
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Singer View")
        }
    }
    
    struct SingerView_Previews: PreviewProvider {
        static var previews: some View {
            SingerView()
        }
    }
    struct MusicianSong: Identifiable, Hashable { // Conforming to Hashable
        let id = UUID()
        let title: String
        let artist: String
        let duration: String
        let lyrics: String // Added lyrics property
    }
    
    struct MusicianSongView: View {
        let songs: [MusicianSong]
        
        @State private var selectedSong: MusicianSong?
        
        var body: some View {
            NavigationView {
                List(songs) { song in
                    NavigationLink(destination: LyricsView(lyrics: song.lyrics), tag: song, selection: $selectedSong) {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artist)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Duration: \(song.duration)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                
                Text("Welcome, Musician!")
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Songs Played")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add an action to perform when a button is tapped
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                }
            }
        }
    }
    
    struct LyricsView: View {
        let lyrics: String
        
        var body: some View {
            ScrollView {
                Text(lyrics)
                    .padding()
            }
            .navigationTitle("Lyrics")
        }
    }
    
    struct MusicianSongView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleSongs = [
                MusicianSong(title: "Song 1", artist: "Artist 1", duration: "3:45", lyrics: "Lyrics for Song 1..."),
                MusicianSong(title: "Song 2", artist: "Artist 2", duration: "4:20", lyrics: "Lyrics for Song 2..."),
                MusicianSong(title: "Song 3", artist: "Artist 3", duration: "2:55", lyrics: "Lyrics for Song 3..."),
                // Add more sample songs here
            ]
            
            return MusicianSongView(songs: sampleSongs)
        }
    }
    
    struct Reminder: Identifiable {
        let id = UUID()
        var title: String
        let date: Date
    }
    
    struct RemindersView: View {
        @State private var reminders: [Reminder] = []
        @State private var newReminderTitle = ""
        @State private var selectedDate = Date()
        @State private var isAddingReminder = false
        @State private var errorMessage = ""
        @State private var isPlayingRandomSong = false
        
        var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                        List {
                            ForEach(reminders) { reminder in
                                ReminderRow(reminder: reminder)
                            }
                            .onDelete(perform: deleteReminder)
                        }
                        .listStyle(PlainListStyle())
                        
                        if reminders.isEmpty {
                            Text("No Reminders")
                                .font(.headline)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        Button(action: {
                            isAddingReminder = true
                            selectedDate = Date()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                        .padding()
                    }
                }
                .navigationTitle("Reminders")
                .navigationBarItems(trailing: EditButton())
            }
            .sheet(isPresented: $isAddingReminder, content: {
                NavigationView {
                    AddReminderView(newReminderTitle: $newReminderTitle, selectedDate: $selectedDate, isAddingReminder: $isAddingReminder, addReminder: addReminder, errorMessage: $errorMessage)
                        .navigationBarItems(trailing: Button("Done") {
                            isAddingReminder = false
                            newReminderTitle = ""
                        })
                        .navigationBarTitle("Add Reminder")
                }
            })
            .alert(isPresented: Binding<Bool>(
                get: { !errorMessage.isEmpty },
                set: { _ in errorMessage = "" }
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Check if it's time to play a random song when the view appears
                checkAndPlayRandomSong()
            }
        }
        
        func addReminder() {
            let currentDate = Date()
            if selectedDate < currentDate {
                errorMessage = "Please select a future date and time."
                return
            }
            
            let newReminder = Reminder(title: newReminderTitle, date: selectedDate)
            reminders.append(newReminder)
            newReminderTitle = ""
            selectedDate = currentDate // Reset the selected date to the current date
            
            // Check and play a random song if the reminder time is reached
            checkAndPlayRandomSong()
        }
        
        func deleteReminder(at offsets: IndexSet) {
            reminders.remove(atOffsets: offsets)
        }
        
        func checkAndPlayRandomSong() {
            let currentDate = Date()
            for reminder in reminders {
                if reminder.date <= currentDate {
                    playRandomSong()
                    return
                }
            }
        }
        
        func playRandomSong() {
            // Simulate playing a random song (you can replace this with actual audio playback logic)
            isPlayingRandomSong = true
            
            // After a delay, stop playing the random song
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isPlayingRandomSong = false
            }
        }
    }
    
    struct ReminderRow: View {
        let reminder: Reminder
        private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(Self.dateFormatter.string(from: reminder.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .shadow(radius: 5)
        }
    }
    
    struct AddReminderView: View {
        @Binding var newReminderTitle: String
        @Binding var selectedDate: Date
        @Binding var isAddingReminder: Bool
        var addReminder: () -> Void
        @Binding var errorMessage: String
        
        var body: some View {
            Form {
                Section(header: Text("Reminder Title")) {
                    TextField("Enter title", text: $newReminderTitle)
                }
                
                Section(header: Text("Select Date and Time")) {
                    DatePicker("Date and Time", selection: $selectedDate, in: Date()...)
                        .datePickerStyle(DefaultDatePickerStyle())
                }
                
                Section {
                    Button("Add Reminder") {
                        addReminder()
                    }
                    
                    .disabled(newReminderTitle.isEmpty)
                }
            }
        }
    }
    
    struct RemindersView_Previews: PreviewProvider {
        static var previews: some View {
            RemindersView()
        }
    }
    
    
    struct SpeechLanguageDetectionView: View {
        @State private var detectedLanguage = ""
        
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Change to the desired locale
        
        var body: some View {
            VStack {
                Text("Speech Language Detection")
                    .font(.headline)
                    .padding()
                
                Text("Detected Language: \(detectedLanguage)")
                    .font(.headline)
                    .padding()
                
                Button("Start Speech Recognition") {
                    startSpeechRecognition()
                }
                .padding()
            }
            .onAppear {
                requestSpeechAuthorization()
            }
        }
        
        func requestSpeechAuthorization() {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                if authStatus == .authorized {
                    print("Speech recognition authorized")
                }
            }
        }
        
        func startSpeechRecognition() {
            guard let recognizer = speechRecognizer else {
                return
            }
            
            let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest.shouldReportPartialResults = true
            
            let audioEngine = AVAudioEngine()
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                let inputNode = audioEngine.inputNode
                
                recognitionRequest.taskHint = .search
                
                _ = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                    if let result = result {
                        let recognizedText = result.bestTranscription.formattedString
                        
                        // Pass the recognized text to language detection
                        detectLanguage(for: recognizedText)
                    } else if let error = error {
                        print("Speech recognition error: \(error)")
                    }
                }
                
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer, _) in
                    recognitionRequest.append(buffer)
                }
                
                audioEngine.prepare()
                
                do {
                    try audioEngine.start()
                } catch {
                    print("Audio engine couldn't start because of an error: \(error)")
                }
            } catch {
                print("Audio session error: \(error)")
            }
        }
        
        func detectLanguage(for text: String) {
            let naturalLanguage = NLLanguageRecognizer()
            naturalLanguage.processString(text)
            
            if let dominantLanguage = naturalLanguage.dominantLanguage?.rawValue {
                detectedLanguage = dominantLanguage
            } else {
                detectedLanguage = "Language not detected"
            }
        }
    }
    
    struct SpeechLanguageDetectionView_Previews: PreviewProvider {
        static var previews: some View {
            SpeechLanguageDetectionView()
        }
    }
    
    
    

    
    struct CustomSearchView: View {
        @State private var searchText = ""
        @State private var isSearching = false
        @State private var searchResults: [String] = []
        @State private var recentSearches: [String] = ["Recent Query 1", "Recent Query 2", "Recent Query 3"]
        
        var body: some View {
            NavigationView {
                VStack {
                    CustomSearchBar(searchText: $searchText, isSearching: $isSearching, searchResults: $searchResults)
                        .padding(.horizontal)
                    
                    if isSearching {
                        List(searchResults, id: \.self) { result in
                            Text(result)
                        }
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                    } else {
                        Text("Start typing to search")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    if !recentSearches.isEmpty {
                        Text("Recent Searches")
                            .font(.headline)
                            .padding(.top)
                        
                        List(recentSearches, id: \.self) { recentQuery in
                            Button(action: {
                                searchText = recentQuery
                                isSearching = true
                            }) {
                                Text(recentQuery)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitle("Search")
            }
        }
    }
    
    struct CustomSearchView_Previews: PreviewProvider {
        static var previews: some View {
            CustomSearchView()
        }
    }
    
    struct CustomSearchBar: View {
        @Binding var searchText: String
        @Binding var isSearching: Bool
        @Binding var searchResults: [String] // Pass searchResults as a binding
        
        var body: some View {
            HStack {
                TextField("Search...", text: $searchText)
                    .padding(.leading, 24)
                    .onChange(of: searchText, perform: { newValue in
                        // Implement your search logic here and update searchResults
                        searchResults = performSearch(query: newValue)
                    })
                
                if isSearching {
                    Button(action: {
                        searchText = ""
                        isSearching = false
                        hideKeyboard()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .onTapGesture {
                isSearching = true
            }
        }
        
        private func performSearch(query: String) -> [String] {
            // Implement your search logic here based on the query and return search results
            // Replace this with your actual search implementation
            if query.isEmpty {
                return []
            } else {
                return ["Result 1", "Result 2", "Result 3"] // Sample search results
            }
        }
        
        private func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    
    struct ComprehensiveView: View {
        @State private var scale: CGFloat = 1
        @State private var isDarkMode: Bool = false
        
        var body: some View {
            VStack {
                AnimatedView(scale: $scale)
                
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }
                .padding()
                .onChange(of: isDarkMode,initial: true) { _,_  in
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                }
                
                AdaptiveThemeView()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    struct AnimatedView: View {
        @Binding var scale: CGFloat
        
        var body: some View {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1)) {
                        scale = scale == 1 ? 1.5 : 1
                    }
                }
        }
    }
    
    struct AdaptiveThemeView: View {
        var body: some View {
            Text("Adaptive Color")
                .foregroundColor(Color("AdaptiveColor"))
                .padding()
                .background(Color("AdaptiveBackgroundColor"))
        }
    }
    
    
    struct ComprehensiveView_Previews: PreviewProvider {
        static var previews: some View {
            ComprehensiveView()
        }
    }
    
    
    
    
    struct Contact: Identifiable {
        let id: Int
        let name: String
    }
    
    struct AddPersonToGroupChatView: View {
        @State private var searchText = ""
        @State private var selectedContacts: [Contact] = []
        @State private var userContacts: [Contact] = []
        @State private var newContactName = ""
        
        var body: some View {
            NavigationView {
                VStack {
                    TextField("Search Contacts", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    List {
                        ForEach(filteredContacts) { contact in
                            HStack {
                                Text(contact.name)
                                Spacer()
                                if selectedContacts.contains(where: { $0.id == contact.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.black)
                                }
                            }
                            .onTapGesture {
                                toggleContactSelection(contact)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Section(header: Text("Add New Contact")) {
                        TextField("Contact Name", text: $newContactName)
                        Button("Add Contact") {
                            addUserContact()
                        }
                        .disabled(newContactName.isEmpty)
                    }
                    
                    Section(header: Text("Your Contacts")) {
                        List(userContacts) { contact in
                            HStack {
                                Text(contact.name)
                                Spacer()
                                if selectedContacts.contains(where: { $0.id == contact.id }) {
                                    Button("Remove") {
                                        removeUserContact(contact)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button("Add Selected Contacts") {
                        // Add selected contacts to the group chat
                    }
                    .padding()
                    .disabled(selectedContacts.isEmpty)
                }
                .navigationBarTitle("Add People to Group Chat")
                .navigationBarItems(trailing: Button("Cancel") {
                    // Cancel adding people to the group chat
                })
            }
        }
        
        var filteredContacts: [Contact] {
            if searchText.isEmpty {
                return userContacts
            } else {
                return userContacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        func toggleContactSelection(_ contact: Contact) {
            if selectedContacts.contains(where: { $0.id == contact.id }) {
                selectedContacts.removeAll { $0.id == contact.id }
            } else {
                selectedContacts.append(contact)
            }
        }
        
        func addUserContact() {
            let newContactId = userContacts.count + 1
            let newContact = Contact(id: newContactId, name: newContactName)
            userContacts.append(newContact)
            newContactName = ""
        }
        
        func removeUserContact(_ contact: Contact) {
            userContacts.removeAll { $0.id == contact.id }
            selectedContacts.removeAll { $0.id == contact.id }
        }
    }
    
    struct AddPersonToGroupChatView_Previews: PreviewProvider {
        static var previews: some View {
            AddPersonToGroupChatView()
        }
    }
    
    
    
    struct PostView: View {
        @State private var selectedMediaType: MediaType = .photo
        @State private var selectedImage: Image?
        @State private var videoURL: URL?
        @State private var caption: String = ""
        
        enum MediaType {
            case photo
            case video
            case reel
        }
        
        var body: some View {
            NavigationView {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        openMediaPicker()
                    }) {
                        ZStack {
                            if selectedMediaType == .photo {
                                if let image = selectedImage {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                } else {
                                    Image(systemName: "camera.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color.black)
                                }
                            } else if selectedMediaType == .video {
                                if let thumbnailImage = thumbnailImage(for: videoURL) {
                                    thumbnailImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                } else {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color.black)
                                }
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    Picker("Select Media Type", selection: $selectedMediaType) {
                        Text("Photo").tag(MediaType.photo)
                        Text("Video").tag(MediaType.video)
                        Text("Reel").tag(MediaType.reel)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Spacer()
                    
                    if selectedMediaType == .photo && selectedImage != nil {
                        selectedImage!
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                    } else if selectedMediaType == .video && videoURL != nil {
                        VideoPlayer(player: AVPlayer(url: videoURL!))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    TextField("Enter Caption", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        // Implement posting logic here
                    }) {
                        Text("Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .disabled(caption.isEmpty || (selectedMediaType == .photo && selectedImage == nil) || (selectedMediaType == .video && videoURL == nil))
                    .padding()
                }
                .navigationBarTitle("Create Post", displayMode: .inline)
            }
        }
        
        func openMediaPicker() {
            // Implement your media picker logic here
        }
        
        func thumbnailImage(for videoURL: URL?) -> Image? {
            guard let videoURL = videoURL else {
                return nil
            }
            
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            do {
                let cgImage = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 2), actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                return Image(uiImage: uiImage)
            } catch {
                return nil
            }
        }
    }
    
    struct PostView_Previews: PreviewProvider {
        static var previews: some View {
            PostView()
        }
    }
    
    
    
    struct AdvancedAccessibleView: View {
        @State private var toggleStatus: Bool = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                // Image with a detailed accessibility label and traits
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .accessibilityLabel("Decorative image")
                    .accessibilityHidden(toggleStatus) // Hide when toggle is on
                    .padding()
                
                // Text with custom size that reacts to Dynamic Type
                Text("Accessibility Enhanced App")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .accessibilityElement(children: .combine)
                
                // Toggle with value and hint
                Toggle(isOn: $toggleStatus) {
                    Text("Enable Descriptions")
                        .accessibilityLabel("Enable Descriptions Toggle")
                        .accessibilityValue(toggleStatus ? "Enabled" : "Disabled")
                        .accessibilityHint("Toggles the detailed descriptions for images")
                }
                .padding()
                
                
                Button(action: {
                    // Button action here
                }) {
                    Label("Learn More", systemImage: "lightbulb")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("Learn More about Accessibility")
                .accessibilityHint("Double-tap to open detailed information")
                .accessibilityAddTraits(.isButton)
                .padding()
                Spacer()
            }
            .padding()
            .accessibilityAction(named: "Learn More")
            {
                
            }
            .navigationBarTitle("Accessibility", displayMode: .inline)
        }
    }
    
    struct AdvancedAccessibleView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                AdvancedAccessibleView()
                    .environment(\.sizeCategory, .accessibilityLarge)
            }
        }
    }
    
    class AuthViewModel: ObservableObject {
        @Published var isAuthenticated = false
        
        func signIn(email: String, password: String) {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    if let user = authResult?.user {
                        self?.isAuthenticated = true
                    } else {
                        self?.isAuthenticated = false
                    }
                }
            }
        }
    }
