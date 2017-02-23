//
//  RegisterViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
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
    
    self.firstNameTextField.text = "John"
    self.lastNameTextField.text = "Appleseed"
    self.phoneTextField.text = "+1234567890"
    self.emailTextField.text = ""
    self.confirmEmailTextField.text = ""
    self.passwordTextField.text = ""
    self.confirmPasswordTextField.text = ""
    self.zipCodeTextField.text = ""
    self.optEmailCheckBox.on = false
    self.genderSegmentView.selectedSegmentIndex = 0
    
    self.selectedDate = self.dateInPast(21)!
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Register",
      style: .Plain,
      target: self,
      action: #selector(register))
  }
  
  
  //MARK: - Actions
  
  func register() {
    self.scrollView.endEditing(true)
    
    let request = ContactRequest()
    request.set(firstName: self.firstNameTextField.text)
    request.set(lastName: self.lastNameTextField.text)
    request.set(phone: self.phoneTextField.text?.stringByReplacingOccurrencesOfString("-", withString: ""))
    request.set(email: self.emailTextField.text)
    request.set(password: self.passwordTextField.text)
    request.set(zipCode: self.zipCodeTextField.text)
    request.set(birthday: self.getFormatedDate(self.selectedDate, dateFormat: "yyyy-MM-dd"))
    request.set(emailOptin: self.optEmailCheckBox.on)
//    request.set(preferredReward: "")
    request.set(gender: self.genderSegmentView.selectedSegmentIndex == 0 ? "Male" : "Female")
    
    self.coreService?.register(self, request: request, handler: { (success) in
      self.completionBlock?(success: success)
    })
    
    //        self.coreService?.registerLoyaltyAccount(self, request: request, handler: {
    //            success in
    //            self.completionBlock?(success: success)
    //        })
  }
  
  
  //MARK: - UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return false
  }
  
  
  //MARK: - Private
  
  private func getFormatedDate(date: NSDate, dateFormat: String) -> String {
    var formatedString: String!
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    formatedString = dateFormatter.stringFromDate(date)
    
    return formatedString
  }
  
  override internal func keyboardWillChange(notification: NSNotification) {
    var scrollInsets = UIEdgeInsetsZero
    
    if let endFrameInfo = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let endFrame = endFrameInfo.CGRectValue()
      let converted = self.view.convertRect(endFrame, fromView: UIApplication.sharedApplication().keyWindow!)
      
      scrollInsets.bottom = converted.height
    }
    
    self.scrollView.contentInset = scrollInsets
    self.scrollView.scrollIndicatorInsets = scrollInsets
  }
  
  override internal func keyboardWillHide(notification: NSNotification) {
    self.scrollView.contentInset = UIEdgeInsetsZero
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
  }
  
  //MARK: - Private
  
  private func dateInPast(yearsAgo: Int) -> NSDate? {
    let currentDate = NSDate()
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    if let dateComponents = calendar?.components([.Year, .Month, .Day], fromDate: currentDate) {
      dateComponents.year = dateComponents.year - yearsAgo
      
      let date = calendar?.dateFromComponents(dateComponents)
      
      return date
    }
    
    return nil
  }
}
