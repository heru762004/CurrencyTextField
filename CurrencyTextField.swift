//
//  CurrencyTextField.swift
//  CurrencyTextFieldDemo
//
//  Created by Deshmukh,Richa on 6/2/16.
//  Copyright © 2016 Richa. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable open class CurrencyTextField : UITextField{
    
    fileprivate let maxDigits = 7
    
    fileprivate var defaultValue: Double = 0.00
    
    fileprivate let currencyFormattor = NumberFormatter()
    
    fileprivate var previousValue : String = ""
    
    // MARK: - init functions
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTextField()
    }
    
    func initTextField(){
        self.keyboardType = UIKeyboardType.decimalPad
        currencyFormattor.numberStyle = .currency
        currencyFormattor.minimumFractionDigits = 2
        currencyFormattor.maximumFractionDigits = 2
        currencyFormattor.currencySymbol = "$"
        let usLocale = Locale(identifier: "en_US")
        currencyFormattor.locale = usLocale
        setAmount(defaultValue)
    }
    
    // MARK: - UITextField Notifications
    
    override open func willMove(toSuperview newSuperview: UIView!) {
        if newSuperview != nil {
            print("UITextInputDelegate.textDidChange")
            NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name:UITextField.textDidChangeNotification, object: self)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc private func textDidChange(_ notification: Notification){
        
        //Get the original position of the cursor
        let cursorOffset = getOriginalCursorPosition();
        
        let cleanNumericString : String = getCleanNumberString()
        let textFieldLength = self.text?.count
        
        if cleanNumericString.count > maxDigits{
            self.text = previousValue
        }
        else{
            let textFieldNumber = Double(cleanNumericString)
            if let textFieldNumber = textFieldNumber{
                let textFieldNewValue = textFieldNumber/100
                setAmount(textFieldNewValue)
            }else{
                self.text = previousValue
            }
        }
        //Set the cursor back to its original poistion
        setCursorOriginalPosition(cursorOffset, oldTextFieldLength: textFieldLength)
    }
    
    //MARK: - Custom text field functions
    
    open func setAmount (_ amount : Double){
        let textFieldStringValue = currencyFormattor.string(from: NSNumber(value: amount))
        self.text = textFieldStringValue
        if let textFieldStringValue = textFieldStringValue{
            previousValue = textFieldStringValue
        }
    }
    
    open func getAmount() -> Float {
        print("SELF TEXT = \(self.text)")
        let cleanNumericString = self.getCleanNumberString()
        print("clean num str = \(cleanNumericString)")
        let textFieldNumber = Double(cleanNumericString)
        if let textFieldNumber = textFieldNumber{
            let textFieldNewValue = textFieldNumber/100
            return Float(textFieldNewValue)
        }
        return 0.0
    }
    
    //MARK - helper functions
    
    fileprivate func getCleanNumberString() -> String {
        var cleanNumericString: String = ""
        let textFieldString = self.text
        if let textFieldString = textFieldString{
            
            //Remove $ sign
            var toArray = textFieldString.components(separatedBy: "$")
            cleanNumericString = toArray.joined(separator: "")
            
            //Remove periods, commas
            toArray = cleanNumericString.components(separatedBy: CharacterSet.punctuationCharacters)
            cleanNumericString = toArray.joined(separator: "")
        }
        
        return cleanNumericString
    }
    
    fileprivate func getOriginalCursorPosition() -> Int{
        
        var cursorOffset : Int = 0
        let startPosition : UITextPosition = self.beginningOfDocument
        if let selectedTextRange = self.selectedTextRange{
            cursorOffset = self.offset(from: startPosition, to: selectedTextRange.start)
        }
        return cursorOffset
    }
    
    fileprivate func setCursorOriginalPosition(_ cursorOffset: Int, oldTextFieldLength : Int?){
        
        let newLength = self.text?.count
        let startPosition : UITextPosition = self.beginningOfDocument
        if let oldTextFieldLength = oldTextFieldLength, let newLength = newLength, oldTextFieldLength > cursorOffset{
            let newOffset = newLength - oldTextFieldLength + cursorOffset
            let newCursorPosition = self.position(from: startPosition, offset: newOffset)
            if let newCursorPosition = newCursorPosition{
                let newSelectedRange = self.textRange(from: newCursorPosition, to: newCursorPosition)
                self.selectedTextRange = newSelectedRange
            }
            
        }
    }
    
}
