//
//  ViewController.swift
//  PracticaFirebase
//
//  Created by Mananas on 28/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "Navigate To Home", sender: nil)
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        let email = (usernameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text ?? ""
        
        // Validaciones básicas antes de llamar a Firebase
        guard !email.isEmpty else {
            showMessage(message: "Por favor, ingresa tu correo electrónico.")
            return
        }
        guard !password.isEmpty else {
            showMessage(message: "Por favor, ingresa tu contraseña.")
            return
        }
        
        // Intento de inicio de sesión
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error as NSError? {
                // Mapeo de errores comunes de FirebaseAuth
                if let code = AuthErrorCode(rawValue: error.code) {
                    switch code {
                    case .userNotFound:
                        self.showMessage(message: "No existe una cuenta con ese correo. Por favor, crea una cuenta.")
                    case .wrongPassword:
                        self.showMessage(message: "Contraseña incorrecta. Inténtalo de nuevo.")
                    case .invalidEmail:
                        self.showMessage(message: "El formato del correo electrónico no es válido.")
                    case .userDisabled:
                        self.showMessage(message: "Esta cuenta ha sido deshabilitada.")
                    case .tooManyRequests:
                        self.showMessage(message: "Demasiados intentos. Inténtalo nuevamente más tarde.")
                    default:
                        // Para otros errores, mostramos el mensaje que provee Firebase
                        self.showMessage(message: error.localizedDescription)
                    }
                } else {
                    // Si no podemos mapear el código, mostramos el mensaje genérico
                    self.showMessage(message: error.localizedDescription)
                }
                return
            }
            
            // Éxito
            print("User signed in successfully")
            self.performSegue(withIdentifier: "Navigate To Home", sender: nil)
        }
    }

    @IBAction func resetPassword(_ sender: Any) {
        let email = (usernameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            showMessage(message: "Ingresa tu correo para restablecer la contraseña.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    switch code {
                    case .userNotFound:
                        self.showMessage(message: "No existe una cuenta con ese correo. Por favor, crea una cuenta.")
                    case .invalidEmail:
                        self.showMessage(message: "El formato del correo electrónico no es válido.")
                    default:
                        self.showMessage(message: error.localizedDescription)
                    }
                } else {
                    self.showMessage(message: error.localizedDescription)
                }
                return
            }
            
            self.showMessage(message: "Te enviamos un correo para restablecer tu contraseña.")
        }
    }
    
    @IBAction func signUP(_ sender: Any) {
        let email = (usernameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text ?? ""
        let repeatPassword = repeatPasswordTextField.text ?? ""
        
        // Validaciones básicas
        guard !email.isEmpty else {
            showMessage(message: "Por favor, ingresa tu correo electrónico.")
            return
        }
        guard !password.isEmpty else {
            showMessage(message: "Por favor, ingresa tu contraseña.")
            return
        }
        guard !repeatPassword.isEmpty else {
            showMessage(message: "Por favor, repite tu contraseña.")
            return
        }
        guard password == repeatPassword else {
            showMessage(message: "Las contraseñas no coinciden.")
            return
        }
        
        // Registro de usuario
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    switch code {
                    case .invalidEmail:
                        self.showMessage(message: "El formato del correo electrónico no es válido.")
                    case .emailAlreadyInUse:
                        self.showMessage(message: "Este correo ya está en uso. Intenta iniciar sesión.")
                    case .weakPassword:
                        self.showMessage(message: "La contraseña es demasiado débil. Prueba con una más segura.")
                    case .operationNotAllowed:
                        self.showMessage(message: "El registro de usuarios no está habilitado.")
                    default:
                        self.showMessage(message: error.localizedDescription)
                    }
                } else {
                    self.showMessage(message: error.localizedDescription)
                }
                return
            }
            
            // Éxito en el registro: puedes enviar verificación de correo si quieres
            // Auth.auth().currentUser?.sendEmailVerification(completion: nil)
            print("User signed up successfully")
            self.showMessage(message: "Cuenta creada con éxito. ¡Bienvenido!")
            self.performSegue(withIdentifier: "Navigate To Home", sender: nil)
        }
    }
}
