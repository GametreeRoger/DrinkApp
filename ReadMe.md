Drink App (麻古茶坊)

current version ２.0

- V 2.0
  1. 下載資料時顯示 LoadingViewController
  2. TableView 沒有資料時顯示沒有資料的畫面
     1. 遇到的困難 刪除最後一個資料時，刪除 section 後就不要再 deleteRows 了不然會出現 error
  3. UITextField 加了 return 收鍵盤
  4. 隨機選擇飲料 使用 randomElement
  5. 統整訂單，將一樣的飲料統整在一起 使用了 [Dictionary(grouping:by:)](https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/%E5%B0%87-array-%E5%88%86%E9%A1%9E%E7%9A%84-dictionary-init-grouping-by-b14770aac3c0) , struct 使用了 [Hashable](https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/swift-%E7%9A%84-hashable-protocol-6df8adfdcb54)
  6. 使用 [AVSpeechSynthesizer](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer) 唸出訂單
  7. [電話中唸給對方聽](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/3132070-mixtotelephonyuplink)
  8. UIButton 改成 iOS 15 以下可以用的寫法
  9. 店家資訊用 plist 的方式讀取
  10. 新增 icon, LaunchScreen
- V 1.0
  1. 新增訂購的飲料
  2. 飲料的 menu 搭配 JSON 存取
  3. 可修改編輯
  4. 可刪除
  5. 可開不同的團訂飲料
  6. 將抓資料的程式定義成 function，寫在 NetworkController 裡