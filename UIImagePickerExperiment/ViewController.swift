//
//  ViewController.swift
//  UIImagePickerExperiment
//
//  Created by Jun.Yuan on 16/6/4.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: -
    // MARK: Variables
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    private var memedImage: UIImage!
    
    
    // MARK: -
    // MARK: Save Meme object
    func saveMeme() {
        //Create the meme
        let _ = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        originImage: imagePickerView.image!,
                        memedImage: memedImage)
    }
    
    // MARK: -
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        setTextField(topTextField, withDelegate: self, textAttribute: memeTextAttributes, aligment: .Center)
        setTextField(bottomTextField, withDelegate: self, textAttribute: memeTextAttributes, aligment: .Center)
    }
    
    func setTextField(textfield: UITextField, withDelegate delegate: UITextFieldDelegate, textAttribute: [String: AnyObject], aligment: NSTextAlignment) {
        textfield.delegate = delegate
        textfield.defaultTextAttributes = textAttribute
        textfield.textAlignment = aligment
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        if imagePickerView.image != nil {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        subscribeToKeyboardNotifications()
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: -
    // MARK: Button actions
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentImagePickerControllerWithSourceType(.PhotoLibrary)
    }
    
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        presentImagePickerControllerWithSourceType(.Camera)
    }
    
    
    @IBAction func shareMemeImage(sender: AnyObject) {
        memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            if completed {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    func generateMemedImage() -> UIImage {
        navigationBar.hidden = true
        bottomToolbar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navigationBar.hidden = false
        bottomToolbar.hidden = false
        return memedImage
    }
    
    
    @IBAction func resetEditor(sender: AnyObject) {
        let alertController = UIAlertController(title: "Reset Editor", message: "Changes unsaved will be lost", preferredStyle: .ActionSheet)
        
        let resetAction = UIAlertAction(title:"Reset", style: .Destructive) { action in
            self.topTextField.text = "TOP"
            self.bottomTextField.text = "BOTTOM"
            self.imagePickerView.image = nil
            self.shareButton.enabled = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: -
    // MARK: Image picker delegate
    func presentImagePickerControllerWithSourceType(type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: -
    // MARK: Text field delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        let text = textField.text
        if text == "TOP" || text == "BOTTOM" {
            textField.text = nil
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text
        if text == "" {
            switch textField {
            case topTextField:
                textField.text = "TOP"
            case bottomTextField:
                textField.text = "BOTTOM"
            default:
                break
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: -
    // MARK: Toggle view when editing bottom textField
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        if topTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}
