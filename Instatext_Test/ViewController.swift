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
    private var textStyleStatusArr: [(Int, TextStyle)] = []
    private var currentCoursorPosition: UITextPosition?
    
    private let myToolBAr = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Removing red lines
        view.endEditing(true)
        let myText = textview.attributedText
        textview.text = ""
        textview.attributedText = myText
        
        // Making screenshot, cleaning all, saving!
        let screenshot = textview.takeScreenshot()
        textview.text = ""
        saveButton.isEnabled = false
        textStyleStatusArr = []
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
    //    view.backgroundColor = .white
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
        let headerAction = UIAlertAction(title: TextStyle.header.rawValue, style: .default) { [self] action in
            self.myToolBAr.items?.first?.title = TextStyle.header.rawValue
            self.currentStyleStatus = TextStyle.header
            // Проверка на выделенный текст.
            if self.textview.selectedRange.length > 0 {
                let location = self.textview.selectedRange.location
                let length = self.textview.selectedRange.length
                let endPosition = location + length
                print("Selected text is \(self.textview.selectedRange.length)")
                print("Start text is \(self.textview.selectedRange.location)")
                
                var bufferArray: [(Int, TextStyle)] = []
                
                for (i,k) in textStyleStatusArr.enumerated() {
                    if location == 0 && endPosition == k.0 {
                        bufferArray.append((k.0,currentStyleStatus))
                        continue
                    }
                    
                    if location == 0 && endPosition < k.0 {
                        bufferArray.append((endPosition,currentStyleStatus))
                        bufferArray.append((k.0, k.1))
                        continue
                    }
                    if textStyleStatusArr.count == 1 {
                        
                        continue
                    }
                        
                    if location < k.0 {
                        if endPosition < k.0 {
                            bufferArray.append((endPosition, currentStyleStatus))
                            bufferArray.append((k.0,k.1))
                            continue
                        }
                        bufferArray.append((location, k.1))
                        continue
                    }
                    bufferArray.append(k)
                }
                print("main array \(textStyleStatusArr)")
                print("buffer array \(bufferArray)")
                self.textStyleStatusArr = bufferArray
                self.textview.attributedText = self.textStyleEditing(textView: self.textview)
            }
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
        //Checking pointer position
        _ = getCoursorPosition(textView: textView)
        //Добавляем информацию по стилю и количеству тектса в массив
        normalTextEditing(textView: textView)
        
        //Если массив пустой, то нужно выйти из метода
        if textStyleStatusArr.isEmpty {
            return
        }
        textView.attributedText = textStyleEditing(textView: textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        getCoursorPosition(textView: textView)
        let textRange = textView.selectedTextRange
        currentCoursorPosition = textView.selectedTextRange?.start
        print("selet \(textRange)")
        print("position start \(textRange?.start)")
        print("position finish \(textRange?.start)")
        
        print("Did Change selection")
        if let selectedRange = textView.selectedTextRange {

            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            print(textView.beginningOfDocument)
            print("\(cursorPosition)")
            print(textView.selectedTextRange)
        }
        print("Array \(textStyleStatusArr)")
      //  let a = UITextPosition()
    
//        textview.selectedTextRange = textview.textRange(from: <#T##UITextPosition#>, to: <#T##UITextPosition#>)
        //Управление курсором
//        if textview.text.count > 8 {
//            let arbitraryValue: Int = 5
//            if let newPosition = textView.position(from: textView.beginningOfDocument, in: .right, offset: 4) {
//
//                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//            }
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholdertext
            textView.textColor = .lightGray
            saveButton.isEnabled = false
        }
    }
}

//MARK: - Text stryling extension
extension ViewController {
    private func normalTextEditing(textView: UITextView) {
        //MARK: - Стандартная работа с текстом, ввод/удаление, сменя стиля. Курсов всегда в конце документа
        //Получаем последний индекс в массиве, для обращения к его элементам
        let lastIndex = textStyleStatusArr.count == 0 ? 0 : textStyleStatusArr.count - 1
        print("last index \(lastIndex)")
        
        //Алгоритм заполнения массима с данными по стилям текста
        if textview.text.count > textStyleStatusArr.last?.0 ?? 0 {
            
            if textStyleStatusArr.last?.1 == currentStyleStatus {
                let index = textStyleStatusArr.count == 0 ? 0 : textStyleStatusArr.count - 1
                print(index)
                textStyleStatusArr[index] = (textView.text.count, currentStyleStatus)
                print("Check 1\(textStyleStatusArr)")
            } else {
                textStyleStatusArr.append((textView.text.count ,currentStyleStatus))
                print("Check 2\(textStyleStatusArr)")
            }
        } else if textview.text.count < textStyleStatusArr.last?.0 ?? 0, lastIndex != 0,
                  textStyleStatusArr[lastIndex - 1].0 < textView.text.count {
            print(textview.text.count < textStyleStatusArr.last?.0 ?? 0)
            guard let lastStatus = textStyleStatusArr.last?.1 else { return }
            textStyleStatusArr[lastIndex] = (textView.text.count, lastStatus)
            print("Check 3\(textStyleStatusArr)")
        } else if lastIndex == 0 {
            let lastStatus = textStyleStatusArr[0].1
            textStyleStatusArr[lastIndex] = (textView.text.count, lastStatus)
            print("Check 4\(textStyleStatusArr)")
        } else {
            textStyleStatusArr = textStyleStatusArr.dropLast()
            guard let lastStatus = textStyleStatusArr.last?.1 else { return }
            textStyleStatusArr[lastIndex - 1] = (textView.text.count, lastStatus)
            print("Check 5\(textStyleStatusArr)")
        }
    }
    
    private func textStyleEditing(textView: UITextView) -> NSMutableAttributedString {
        //Форматирование текст под нужный стиль
        let myAtrText = NSMutableAttributedString(string: textView.text)
        for i in 0...textStyleStatusArr.count - 1 {
            let location = i == 0 ? 0 : textStyleStatusArr[i - 1].0
            let length = i == 0 ? textStyleStatusArr[i].0 : textStyleStatusArr[i].0 - textStyleStatusArr[i - 1].0
            switch textStyleStatusArr[i].1 {
            case .title:
                let titleAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23, weight: .regular)
                ]
                myAtrText.addAttributes(titleAttribute,
                                        range: NSRange(location: location, length: length))
            case .header:
                let headerAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .bold)
                ]
                myAtrText.addAttributes(headerAttribute,
                                        range: NSRange(location: location, length: length))
            case .subHeader:
                let subHeaderAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
                ]
                myAtrText.addAttributes(subHeaderAttribute,
                                        range: NSRange(location: location, length: length))
            case .mainText:
                let mainTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
                ]
                myAtrText.addAttributes(mainTextAttribute,
                                        range: NSRange(location: location, length: length))
            case .secondText:
                let secondTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ]
                myAtrText.addAttributes(secondTextAttribute,
                                        range: NSRange(location: location, length: length))
            }
        }
        return myAtrText
    }
    
    private func selectedTextStyleEditing(textView: UITextView) -> NSMutableAttributedString {
        //Форматирование текст под нужный стиль
        let myAtrText = NSMutableAttributedString(string: textView.text)
        
        let location = textView.selectedRange.location
        let length = textView.selectedRange.length
        switch currentStyleStatus {
            case .title:
                let titleAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23, weight: .regular)
                ]
                myAtrText.addAttributes(titleAttribute,
                                        range: NSRange(location: location, length: length))
            case .header:
                let headerAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .bold)
                ]
                myAtrText.addAttributes(headerAttribute,
                                        range: NSRange(location: location, length: length))
            case .subHeader:
                let subHeaderAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
                ]
                myAtrText.addAttributes(subHeaderAttribute,
                                        range: NSRange(location: location, length: length))
            case .mainText:
                let mainTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
                ]
                myAtrText.addAttributes(mainTextAttribute,
                                        range: NSRange(location: location, length: length))
            case .secondText:
                let secondTextAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ]
                myAtrText.addAttributes(secondTextAttribute,
                                        range: NSRange(location: location, length: length))
            }
        return myAtrText
    }
    
    private func getCoursorPosition(textView: UITextView) -> Int? {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            let selectedTextLength = textView.offset(from: selectedRange.start, to: selectedRange.end)
            print("Cursor position \(cursorPosition)")
            print("Start selected range \(selectedRange.start)")
            print("Ebn selected range \(selectedRange.end)")
            print("Selected leng \(selectedTextLength)")
            return cursorPosition
        }
        return nil
    }
}
