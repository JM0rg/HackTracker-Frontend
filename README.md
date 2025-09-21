# HackTracker Frontend

A modern Flutter mobile application for tracking slowpitch softball statistics, featuring a sleek dark theme with neon accents and comprehensive team management capabilities.

## 🏆 Features

### Current Implementation
- **Dark Hacker Theme**: Modern UI with neon green, blue, and pink accents
- **Team Management**: Multi-team support with dropdown team selection
- **Dashboard**: Comprehensive home screen with game info and stats
- **Navigation**: Bottom navigation with Home, Schedule, Stats, and Roster screens
- **Responsive Design**: No-scroll layout optimized for mobile devices
- **Custom Typography**: Tektur font family for a modern, tech-forward appearance

### Planned Features
- **Game Management**: Schedule games, track lineups, and live scoring
- **Player Statistics**: Comprehensive batting, fielding, and team stats
- **Real-time Updates**: Live game scoring and stat tracking
- **Team Analytics**: Performance insights and trends
- **User Authentication**: Secure login and team membership management

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/                   # Data models (User, Team, Game, etc.)
├── providers/                # State management with Provider
├── screens/                  # UI screens
│   ├── home_screen.dart      # Main dashboard
│   ├── schedule_screen.dart  # Game schedule
│   ├── stats_screen.dart     # Team and player statistics
│   └── roster_screen.dart    # Team roster management
├── services/                 # API and business logic
│   └── api_service.dart      # Backend API integration
└── widgets/                  # Reusable UI components
```

### Tech Stack
- **Framework**: Flutter 3.35.4+
- **Language**: Dart 3.9.2+
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Code Generation**: json_serializable, build_runner
- **Linting**: flutter_lints

## 🎨 Design System

### Color Palette
- **Primary**: `#00FF88` (Neon Green) - Team stats and highlights
- **Secondary**: `#0088FF` (Neon Blue) - Player stats and secondary actions
- **Tertiary**: `#FF0088` (Neon Pink) - Live games and alerts
- **Background**: `#000000` (Black) - Main background
- **Surface**: `#0A0A0A` (Dark Gray) - Cards and containers
- **Text**: `#E0E0E0` (Light Gray) - Primary text

### Typography
- **Font Family**: Tektur (Regular, Medium, SemiBold, Bold, ExtraBold, Black)
- **Design Philosophy**: Futuristic, hacker-inspired aesthetic

### Layout Principles
- **No-scroll Design**: All content fits within screen bounds
- **One-hand Friendly**: Thumb-accessible navigation and controls
- **Context-driven**: UI adapts based on user role and current state
- **Minimalist Actions**: Essential controls only, reducing cognitive load

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.4 or higher
- Dart SDK 3.9.2 or higher
- iOS Simulator (for iOS development)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HackTracker-Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (if using json_serializable)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Launch the app**
   ```bash
   # For iOS Simulator
   flutter run -d ios
   
   # For Android Emulator
   flutter run -d android
   
   # For Web (development)
   flutter run -d chrome
   ```

### Development Setup

1. **Enable developer mode**
   ```bash
   flutter config --enable-web
   ```

2. **Check Flutter installation**
   ```bash
   flutter doctor
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

## 📱 Screens Overview

### Home Screen (Dashboard)
- **Team Selector**: Dropdown to switch between user's teams
- **Next Game Card**: Upcoming game info with quick actions
- **Stats Summary**: Combined team/player stats with period selection
- **Quick Actions**: Role-based buttons for lineup editing and stats entry

### Schedule Screen
- Game calendar and upcoming matches
- Game details and lineup management
- Live scoring interface (planned)

### Stats Screen
- Team performance metrics
- Player statistics and leaderboards
- Historical data and trends

### Roster Screen
- Team member management
- Player profiles and contact info
- Role assignments (Owner, Coach, Player)

## 🔧 Configuration

### Environment Setup
Create environment-specific configuration files:
- `lib/config/development.dart`
- `lib/config/production.dart`
- `lib/config/staging.dart`

### API Integration
The app connects to a Python/FastAPI backend with the following endpoints:
- **Users**: Authentication and profile management
- **Teams**: Team creation, membership, and management
- **Games**: Game scheduling, lineup management, and scoring

### Backend API Structure
```
POST /users              # Create user
GET  /users/{id}         # Get user by ID
GET  /users?email=...    # Get user by email
POST /teams              # Create team
GET  /teams/{id}         # Get team details
POST /games              # Create game
GET  /games/{id}         # Get game details
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Building for Production

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏗️ Backend Integration

This frontend integrates with the HackTracker backend:
- **Repository**: `HackTracker-Backend`
- **Tech Stack**: Python, FastAPI, AWS Lambda, DynamoDB, API Gateway
- **Deployment**: AWS Serverless Architecture

## 🐛 Known Issues

- Stats screen overflow fixed (RenderFlex issue resolved)
- Dropdown consistency issues resolved
- iOS Simulator setup required for proper testing

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

## 🗺️ Roadmap

### Phase 1 (Current)
- [x] Basic UI/UX implementation
- [x] Navigation structure
- [x] Dark theme with neon accents
- [x] Team and player stats display

### Phase 2 (Next)
- [ ] Backend API integration
- [ ] User authentication
- [ ] Real-time game scoring
- [ ] Push notifications

### Phase 3 (Future)
- [ ] Advanced analytics
- [ ] Social features
- [ ] Offline mode
- [ ] Multi-language support

---

**HackTracker** - Modern softball statistics tracking for the digital age. 🥎⚡