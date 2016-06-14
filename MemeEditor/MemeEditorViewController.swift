//
//  MemeEditorViewController.swift
//  UIImagePickerExperiment
//
//  Created by Jun.Yuan on 16/6/4.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

// MARK:- View Controller Properties
class MemeEditorViewController: UIViewController {
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var pushedInMeme: Meme?
    
    private var memedImage: UIImage!
    
    private var memeEditorStatusDefault: MemeEditorStatus {
        return MemeEditorStatus(topText: "TOP", bottomText: "BOTTOM", originImage: nil)
    }
    
    private var memeEditorStatusPushedIn: MemeEditorStatus {
        if let pushedInMeme = pushedInMeme {
            return MemeEditorStatus(topText: pushedInMeme.topText, bottomText:pushedInMeme.bottomText, originImage:pushedInMeme.originImage)
        }
        return memeEditorStatusDefault
    }
    
    private var memeEditorStatusCurrent: MemeEditorStatus {
        return MemeEditorStatus(topText: topTextField.text, bottomText: bottomTextField.text, originImage: imagePickerView.image)
    }
}


// MARK:- View Controller Lifecycle
extension MemeEditorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        setTextField(topTextField, textAttribute: memeTextAttributes)
        setTextField(bottomTextField, textAttribute: memeTextAttributes)
        
        if let meme = pushedInMeme {
            imagePickerView.image = meme.originImage
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if imagePickerView.image != nil {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        
        autoEnableResetButton()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setTextField(textfield: UITextField, textAttribute: [String: AnyObject]) {
        textfield.delegate = self
        textfield.defaultTextAttributes = textAttribute
        textfield.textAlignment = .Center
    }
    
    func autoEnableResetButton() {
        if memeEditorStatusCurrent == memeEditorStatusDefault {
            resetButton.enabled = false
        } else {
            resetButton.enabled = true
        }
    }
}


// MARK: - View Touching Behavior
extension MemeEditorViewController {
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hideOrShowBar(navigationBar)
        hideOrShowBar(bottomToolbar)
        
        dismissKeyboardForTextField(topTextField)
        dismissKeyboardForTextField(bottomTextField)
    }
    
    func dismissKeyboardForTextField(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
}


// MARK: - View Shifting Behavior
extension MemeEditorViewController {
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
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


// MARK:- Buttons Action
extension MemeEditorViewController {
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
    
    @IBAction func resetEditor(sender: AnyObject) {
        let titleText = "Editor will be reset to default."
        let messageText = "Any unsaved changes will be lost."
        let alertController = UIAlertController(title: titleText, message: messageText, preferredStyle: .ActionSheet)
        let resetAction = UIAlertAction(title:"Reset Editor", style: .Destructive) { action in
            self.imagePickerView.image = nil
            self.topTextField.text = self.memeEditorStatusDefault.topText
            self.bottomTextField.text = self.memeEditorStatusDefault.bottomText
            self.shareButton.enabled = false
            self.resetButton.enabled = false
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func quitEditor(sender: AnyObject) {
        if (memeEditorStatusCurrent == memeEditorStatusDefault) || (memeEditorStatusCurrent == memeEditorStatusPushedIn) {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let titleText = "Quit Editor"
            let messageText = "Any unsaved changes will be lost."
            let alertController = UIAlertController(title: titleText, message: messageText, preferredStyle: .ActionSheet)
            let quitAction = UIAlertAction(title: "Quit Editor", style: .Destructive) { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(quitAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func presentImagePickerControllerWithSourceType(type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        hideBar(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        hideBar(false)
        
        return memedImage
    }
    
    func saveMeme() {
        let meme = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        originImage: imagePickerView.image!,
                        memedImage: memedImage)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        
    }
    
    func hideBar(boolen: Bool) {
        navigationBar.hidden = boolen
        bottomToolbar.hidden = boolen
    }
}


// MARK:- ImagePicker Delegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK:- TextField Delegate
extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        setUIView(navigationBar, withAlpha: 0.0)
        setUIView(bottomToolbar, withAlpha: 0.0)
        
        let text = textField.text
        if text == memeEditorStatusDefault.topText || text == memeEditorStatusDefault.bottomText {
            textField.text = nil
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        setUIView(navigationBar, withAlpha: 1.0)
        setUIView(bottomToolbar, withAlpha: 1.0)
        
        let text = textField.text
        if text == "" {
            switch textField {
            case topTextField:
                textField.text = memeEditorStatusDefault.topText
            case bottomTextField:
                textField.text = memeEditorStatusDefault.bottomText
            default:
                break
            }
        }
        autoEnableResetButton()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
