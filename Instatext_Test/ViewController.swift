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
        case main = "Название"
        case header = "Заголовок"
        case subHeader = "Подзаголовок"
        case mainText = "Основной текст"
        case secondText = "Дополнительный текст"
    }
    
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
        
        let mainAction = UIAlertAction(title: TextStyle.mainText.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.mainText.rawValue
        }
        let headerAction = UIAlertAction(title: TextStyle.header.rawValue, style: .default) { action in
            self.myToolBAr.items?.first?.title = TextStyle.header.rawValue
        }
        let subHeaderAction = UIAlertAction(title: TextStyle.subHeader.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.subHeader.rawValue
        }
        let mainTextAction = UIAlertAction(title: TextStyle.mainText.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.mainText.rawValue
        }
        let secondTextAction = UIAlertAction(title: TextStyle.mainText.rawValue, style: .default) { _ in
            self.myToolBAr.items?.first?.title = TextStyle.mainText.rawValue
        }
        
        ac.addAction(mainTextAction)
        ac.addAction(mainAction)
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholdertext
            textView.textColor = .lightGray
            saveButton.isEnabled = false
        }
    }
}
