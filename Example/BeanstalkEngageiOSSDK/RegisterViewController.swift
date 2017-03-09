//
//  RegisterViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class RegisterViewController: BaseViewController, RegistrationProtocol, UITextFieldDelegate {
  @IBOutlet var scrollView: UIScrollView!
  
  @IBOutlet var firstNameTextField: UITextField!
  @IBOutlet var lastNameTextField: UITextField!
  @IBOutlet var phoneTextField: UITextField!
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet var confirmEmailTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var confirmPasswordTextField: UITextField!
  @IBOutlet var zipCodeTextField: UITextField!
  @IBOutlet var optEmailCheckBox: UISwitch!
  @IBOutlet var genderSegmentView: UISegmentedControl!
  
  var selectedDate = NSDate()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    self.firstNameTextField.text = "John"
//    self.lastNameTextField.text = "Appleseed"
//    self.phoneTextField.text = "+1234567890"
    self.emailTextField.text = ""
    self.confirmEmailTextField.text = ""
    self.passwordTextField.text = ""
    self.confirmPasswordTextField.text = ""
    self.zipCodeTextField.text = ""
    self.optEmailCheckBox.isOn = true
    self.genderSegmentView.selectedSegmentIndex = 0
    
    self.selectedDate = self.dateInPast(yearsAgo: 21)!
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Register",
      style: .plain,
      target: self,
      action: #selector(register))
  }
  
  
  //MARK: - Actions
  
  func register() {
    self.scrollView.endEditing(true)
    
    let request = ContactRequest()
    request.set(firstName: self.firstNameTextField.text)
    request.set(lastName: self.lastNameTextField.text)
    request.set(phone: self.phoneTextField.text?.replacingOccurrences(of: "-", with: ""))
    request.set(email: self.emailTextField.text)
    request.set(password: self.passwordTextField.text)
    request.set(zipCode: self.zipCodeTextField.text)
    request.set(birthday: self.getFormatedDate(date: self.selectedDate, dateFormat: "yyyy-MM-dd"))
    request.set(emailOptin: self.optEmailCheckBox.isOn)
    request.set(gender: self.genderSegmentView.selectedSegmentIndex == 0 ? "Male" : "Female")
    
    self.coreService?.registerMe(self, request: request, handler: { (success) in
      self.completionBlock?(success)
    })
    
//    self.coreService?.registerLoyaltyAccount(self, request: request, handler: {
//        success in
//        self.completionBlock?(success: success)
//    })
  }
  
  
  //MARK: - UITextFieldDelegate
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return false
  }
  
  
  //MARK: - Private
  
  private func getFormatedDate(date: NSDate, dateFormat: String) -> String {
    var formatedString: String!
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    formatedString = dateFormatter.string(from: date as Date)
    
    return formatedString
  }
  
  override internal func keyboardWillChange(notification: Notification) {
    var scrollInsets = UIEdgeInsets.zero
    
    if let endFrameInfo = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let endFrame = endFrameInfo.cgRectValue
      let converted = self.view.convert(endFrame, from: UIApplication.shared.keyWindow!)
      
      scrollInsets.bottom = converted.height
    }
    
    self.scrollView.contentInset = scrollInsets
    self.scrollView.scrollIndicatorInsets = scrollInsets
  }
  
  override internal func keyboardWillHide(notification: Notification) {
    self.scrollView.contentInset = UIEdgeInsets.zero
    self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
  }
  
  //MARK: - Private
  
  private func dateInPast(yearsAgo: Int) -> NSDate? {
    let currentDate = NSDate()
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    
    if var dateComponents = calendar?.components([.year, .month, .day], from: currentDate as Date) {
      dateComponents.year = dateComponents.year! - yearsAgo
      
      let date = calendar?.date(from: dateComponents)
      
      return date as NSDate?
    }
    
    return nil
  }
}
