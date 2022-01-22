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
