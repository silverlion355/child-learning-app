# 童学乐 (StudyGame)

儿童学习App - 通过趣味游戏学习成语、诗词、英语单词

## 功能

- 📚 成语学习 - 趣味选字填空
- 📖 诗词诵读 - 经典诗词问答
- 🔤 英语单词 - 单词配对练习

## 技术栈

- Flutter 3.x
- SQLite 本地存储
- Provider 状态管理

## 运行

```bash
flutter pub get
flutter run
```

## 构建APK

```bash
flutter build apk --debug
```

## 学习规则

- 每关10题
- 答对：弹出鼓励语，进入下一题
- 答错：等待重试，直到答对
- 重试正确不计入正确分