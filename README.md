# Bunda Care Mobile App

A comprehensive maternal and child health monitoring mobile application built with Flutter. This app provides essential tools for expectant mothers and new parents to track their pregnancy journey, monitor baby development, access nutritional guidance, and receive personalized health recommendations.

## 📱 Features

### 🏠 Dashboard
- **Health Overview**: Comprehensive summary of maternal and baby health metrics
- **Progress Tracking**: Visual charts and statistics for pregnancy milestones
- **Quick Access**: Direct navigation to all major features

### 🍎 Nutrition & Meal Tracking
- **Meal Logging**: Track daily food intake and nutritional values
- **Dietary Recommendations**: Personalized meal suggestions based on pregnancy stage
- **Nutrition Analysis**: Monitor calorie intake and essential nutrients
- **Food Scanning**: Capture and analyze food items for nutritional information

### 📊 Baby Development & Monitoring
- **Growth Tracking**: Monitor baby's growth patterns and developmental milestones
- **Health Records**: Keep comprehensive health and vaccination records
- **Weight & Measurements**: Track baby's weight, height, and other metrics

### 🤖 AI Chatbot Assistant
- **24/7 Support**: Get instant answers to pregnancy and parenting questions
- **Health Guidance**: Professional advice on common pregnancy concerns
- **Emergency Information**: Quick access to important health resources

### 📚 Educational Content
- **Pregnancy Guide**: Week-by-week pregnancy information
- **Nutrition Education**: Learn about proper nutrition during pregnancy
- **Parenting Tips**: Expert advice for new parents
- **Health Articles**: Curated content on maternal and child health

### 👤 User Profile & Preferences
- **Personal Health Profile**: Track personal health information
- **Preferences**: Customize app experience based on individual needs
- **Secure Data**: All personal information is securely stored

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language

### State Management
- **Provider**: State management solution for reactive UI

### Networking & API
- **Dio**: HTTP client for API communication
- **RESTful API**: Backend integration for data synchronization

### Authentication & Security
- **Google Sign-In**: OAuth authentication
- **Flutter Secure Storage**: Secure local data storage

### UI/UX
- **Material Design**: Modern, intuitive interface
- **Google Fonts**: Typography
- **FL Chart**: Data visualization for health metrics

### File & Media Handling
- **Image Picker**: Camera and gallery integration
- **Cloudinary**: Cloud storage for images and media

## 🏗️ Project Structure

```
lib/
├── models/                 # Data models and DTOs
│   ├── api_error.dart
│   ├── auth_response.dart
│   ├── dashboard_summary.dart
│   ├── user.dart
│   └── user_preference.dart
├── pages/                  # UI screens and pages
│   ├── dashboard_page.dart
│   ├── chatbot_page.dart
│   ├── meal_log_page.dart
│   ├── scan_page.dart
│   ├── edukasi_page.dart
│   ├── profile_page.dart
│   └── ...
├── providers/              # State management providers
│   ├── auth_provider.dart
│   ├── food_provider.dart
│   └── user_preference_provider.dart
├── services/               # Business logic and API services
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── food_service.dart
│   ├── storage_service.dart
│   └── user_service.dart
├── utils/                  # Utility functions and constants
│   ├── cloudinary_uploader.dart
│   └── constants.dart
├── widgets/                # Reusable UI components
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bunda_care_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your API keys and configuration:
     ```
     API_BASE_URL=your_api_base_url
     CLOUDINARY_CLOUD_NAME=your_cloudinary_name
     CLOUDINARY_API_KEY=your_cloudinary_key
     CLOUDINARY_API_SECRET=your_cloudinary_secret
     ```

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

## 🔧 Configuration

### Environment Setup
The app uses environment variables for configuration. Ensure all required variables are set in your `.env` file:

- `API_BASE_URL`: Base URL for your backend API
- `CLOUDINARY_*`: Cloudinary configuration for image uploads
- `GOOGLE_SIGN_IN_*`: Google OAuth configuration (if applicable)

### Build Configuration

**For Android:**
```bash
flutter build apk --release
```

**For iOS:**
```bash
flutter build ios --release
```

## 📱 Platform Support

- ✅ Android (API Level 21+)
- ✅ iOS (iOS 11.0+)
- ✅ Web (Limited features)
- 🔄 Windows (In Development)
- 🔄 macOS (In Development)
- 🔄 Linux (In Development)

## 🔐 Security Features

- **Secure Authentication**: OAuth integration with Google Sign-In
- **Encrypted Storage**: Sensitive data stored using Flutter Secure Storage
- **API Security**: JWT token-based authentication
- **Input Validation**: Comprehensive data validation throughout the app

## 🌐 API Integration

The app integrates with a RESTful API backend for:
- User authentication and authorization
- Health data synchronization
- Nutritional information and recommendations
- AI chatbot services
- Educational content delivery

## 📊 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | ^3.9.2 | Core framework |
| provider | ^6.0.5 | State management |
| dio | ^5.4.0 | HTTP client |
| image_picker | ^1.2.0 | Camera/Gallery access |
| flutter_secure_storage | ^9.0.0 | Secure data storage |
| google_sign_in | ^6.2.1 | OAuth authentication |
| fl_chart | ^1.1.1 | Data visualization |
| google_fonts | ^6.2.0 | Typography |

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For widget testing:
```bash
flutter test test/widget_test.dart
```

## 📝 Development Guidelines

### Code Style
- Follow Dart/Flutter official style guide
- Use `flutter_lints` for code quality
- Maintain proper documentation for all public APIs

### State Management
- Use Provider for global state
- Keep UI components stateless when possible
- Implement proper disposal of resources

### API Integration
- Handle all API errors gracefully
- Implement proper loading states
- Use repository pattern for data access

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common issues

## 🗺️ Roadmap

### Upcoming Features
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Wear OS integration
- [ ] Advanced analytics dashboard
- [ ] Community features
- [ ] Telemedicine integration

### Improvements
- [ ] Performance optimization
- [ ] Enhanced UI/UX
- [ ] Additional educational content
- [ ] Integration with health wearables

---

**Built with ❤️ for expectant mothers and new parents** 
