//
//  ViewController.swift
//  Instatext_Test
//
//  Created by Mykhailo Romanovskyi on 22.01.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private let placeholdertext = "Вставьте сюда текст или начните печатать"
    
    enum TextStyle: String {
        case title = "Название"
        case header = "Заголовок"
        case subHeader = "Подзаголовок"
        case mainText = "Основной текст"
        case secondText = "Дополнительный текст"
    }
    
    private var currentStyleStatus: TextStyle = .mainText
    private var textStyleStatus: [(Int, TextStyle)] = []
    
    private let myToolBAr = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Removing red lines
        view.endEditing(true)
        let myText = textview.text!
        textview.text = ""
        textview.text = myText
        
        let screenshot = textview.takeScreenshot()
        textview.text = ""
        saveButton.isEnabled = false
        UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(image(_: didFinishavingWithError: contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Сохранено!", message: "Ваша картинка сохранена", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

//MARK: Setup ViewController
extension ViewController {
    private func mainSetup() {
        textViewSetup()
        gestureSetup()
        setupToolBar()
    }
    
    private func textViewSetup() {
        textview.text = placeholdertext
        textview.textColor = .lightGray
        textview.layer.cornerRadius = 5
        textview.layer.masksToBounds = false
        textview.layer.shadowColor = UIColor.lightGray.cgColor
        textview.layer.shadowRadius = 5.0
        textview.layer.shadowOpacity = 0.5
        textview.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    private func setupToolBar() {
        textview.inputAccessoryView = myToolBAr
        let styleItem = UIBarButtonItem(title: TextStyle.mainText.rawValue, style: .done, target: self, action: #selector(styleButton))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let keyboardItem = UIBarButtonItem(title: "Keyboard", style: .done, target: self, action: #selector(keyboardHideButton))
        myToolBAr.setItems([styleItem, spaceItem, keyboardItem], animated: true)
        let keyboardImage = UIImage(systemName: "keyboard")
        keyboardItem.image = keyboardImage
        myToolBAr.sizeToFit()
    }
    
    @objc private func styleButton() {
        
        let ac = UIAlertController(title: "Вибирите стиль текста", message: nil, preferredStyle: .actionSheet)
        
        let titleAction = UIAlertAction(title: TextStyle.title.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.title.rawValue
            self.currentStyleStatus = TextStyle.title
        }
        let headerAction = UIAlertAction(title: TextStyle.header.rawValue, style: .default) { action in
            self.myToolBAr.items?.first?.title = TextStyle.header.rawValue
            self.currentStyleStatus = TextStyle.header
        }
        let subHeaderAction = UIAlertAction(title: TextStyle.subHeader.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.subHeader.rawValue
            self.currentStyleStatus = TextStyle.subHeader
        }
        let mainTextAction = UIAlertAction(title: TextStyle.mainText.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.mainText.rawValue
            self.currentStyleStatus = TextStyle.mainText
        }
        let secondTextAction = UIAlertAction(title: TextStyle.secondText.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.secondText.rawValue
            self.currentStyleStatus = TextStyle.secondText
        }
        
        ac.addAction(mainTextAction)
        ac.addAction(titleAction)
        ac.addAction(headerAction)
        ac.addAction(subHeaderAction)
        ac.addAction(secondTextAction)
        
        present(ac, animated:  true)
    }
    
    @objc private func keyboardHideButton() {
        view.endEditing(true)
    }
    
    
    private func gestureSetup() {
        let tapGester = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGester)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: UITextViewDelegate
extension ViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textview.textColor == .lightGray {
            textview.text = ""
            textview.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            saveButton.isEnabled = true
        }
        print("Emtry \(textStyleStatus.isEmpty)")
//        if textStyleStatus.isEmpty {
//            return
//        }
        print(9<9)
        let lastIndex = textStyleStatus.count == 0 ? 0 : textStyleStatus.count - 1
        print("last index \(lastIndex)")
        //Алгоритм заполнения массима с данными по стилям текста
        if textview.text.count > textStyleStatus.last?.0 ?? 0 {
            
            if textStyleStatus.last?.1 == currentStyleStatus {
                let index = textStyleStatus.count == 0 ? 0 : textStyleStatus.count - 1
                print(index)
                textStyleStatus[index] = (textView.text.count, currentStyleStatus)
                print("Check 1\(textStyleStatus)")
            } else {
                textStyleStatus.append((textView.text.count ,currentStyleStatus))
                print("Check 2\(textStyleStatus)")
            }
        } else if textview.text.count < textStyleStatus.last?.0 ?? 0, lastIndex != 0,
                  textStyleStatus[lastIndex - 1].0 < textView.text.count {
            print(textview.text.count < textStyleStatus.last?.0 ?? 0)
            guard let lastStatus = textStyleStatus.last?.1 else { return }
            textStyleStatus[lastIndex] = (textView.text.count, lastStatus)
            print("Check 3\(textStyleStatus)")
        } else if lastIndex == 0 {
            let lastStatus = textStyleStatus[0].1
            textStyleStatus[lastIndex] = (textView.text.count, lastStatus)
            print("Check 4\(textStyleStatus)")
        } else {
            textStyleStatus = textStyleStatus.dropLast()
            guard let lastStatus = textStyleStatus.last?.1 else { return }
            textStyleStatus[lastIndex - 1] = (textView.text.count, lastStatus)
            print("Check 5\(textStyleStatus)")
        }
        print("Emtry \(textStyleStatus.isEmpty)")
        if textStyleStatus.isEmpty {
            return
        }
        
        let myAtrText = NSMutableAttributedString(string: textView.text)
        for i in 0...textStyleStatus.count - 1 {
            
            
            let location = i == 0 ? 0 : textStyleStatus[i - 1].0 - 1
            let length = i == 0 ? textStyleStatus[i].0 : textStyleStatus[i].0 - textStyleStatus[i - 1].0
            switch textStyleStatus[i].1 {
            case .title:
                let titleAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23, weight: .regular)
                ]
                myAtrText.addAttributes(titleAttribute,
                                        range: NSRange(location: location, length: length))
                textView.attributedText = myAtrText
            case .header:
                let headerAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .bold)
                ]
                myAtrText.addAttributes(headerAttribute,
                                        range: NSRange(location: location, length: length))
                textView.attributedText = myAtrText
            case .subHeader:
                let subHeaderAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
                ]
                myAtrText.addAttributes(subHeaderAttribute,
                                        range: NSRange(location: location, length: length))
                textView.attributedText = myAtrText
            case .mainText:
                let mainTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
                ]
                myAtrText.addAttributes(mainTextAttribute,
                                        range: NSRange(location: location, length: length))
                textView.attributedText = myAtrText
            case .secondText:
                let secondTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ]
                myAtrText.addAttributes(secondTextAttribute,
                                        range: NSRange(location: location, length: length))
                textView.attributedText = myAtrText
            }
            
        }
        
        
        //
        //        if textview.text.count > 15 {
        //        let titleAttribute = [
        //            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23, weight: .regular)
        //        ]
        //        let myAtrrText = NSMutableAttributedString(string: textView.text)
        //        myAtrrText.addAttributes(titleAttribute,
        //                                 range: NSRange(location: 3, length: 8))
        //        textView.attributedText = myAtrrText
        //        }
        
        // print("Count \(textView.text.count)")
        print("1")
        print(textView.selectedTextRange)
        print(textView.text)
        print("1")
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("2")
        print(textView.text)
        print(textView.selectedTextRange)
        print("2")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholdertext
            textView.textColor = .lightGray
            saveButton.isEnabled = false
        }
        
        
        let titleAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23, weight: .regular)
        ]
        
        let headerAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .bold)
        ]
        
        let subHeaderAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        let mainTextAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        
        let secondTextAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        
        //  let attrString = NSAttributedString(string: textview.text, attributes: myAttribute)
        //textView.attributedText = attrString
    }
}
