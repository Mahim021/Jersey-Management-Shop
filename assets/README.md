# Assets Folder

## Structure
- **images/** - Place your image files here (PNG, JPG, etc.)
- **icons/** - Place your custom icon files here
- **fonts/** - Place your custom font files here

## Usage in Code

### Images
```dart
Image.asset('assets/images/your_image.png')
```

### Network Images
```dart
Image.network('https://example.com/image.png')
```

### With AssetImage
```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/background.png'),
      fit: BoxFit.cover,
    ),
  ),
)
```

## Remember
After adding new assets, run `flutter pub get` to register them.
