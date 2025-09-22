# HackTracker Frontend

A modern Flutter mobile application for tracking slowpitch softball statistics, featuring a sleek dark theme with neon accents and comprehensive team management capabilities.

## 🏆 Features

### Current Implementation
- **🔐 AWS Cognito Authentication**: Secure JWT-based login with retry logic and auto-healing
- **🎨 Dark Hacker Theme**: Modern UI with neon green, blue, and pink accents
- **👥 Team Management**: Multi-team support with real-time team creation
- **📊 Dashboard**: Comprehensive home screen with real team data and stats
- **🧭 Navigation**: Bottom navigation with Home, Schedule, Stats, and Roster screens
- **📱 Responsive Design**: No-scroll layout optimized for mobile devices
- **🎯 Custom Typography**: Tektur font family for a modern, tech-forward appearance
- **🔄 State Management**: Provider-based architecture with comprehensive error handling
- **🌐 Backend Integration**: Full API integration with HackTracker backend

### Planned Features
- **Game Management**: Schedule games, track lineups, and live scoring
- **Player Statistics**: Advanced batting, fielding, and team analytics
- **Real-time Updates**: Live game scoring and stat tracking
- **Team Analytics**: Performance insights and trends
- **Ghost Player Support**: Add players without accounts and link them later

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point with AuthWrapper
├── amplifyconfiguration.dart    # AWS Amplify configuration
├── models/                      # Data models (User, Team, Game, etc.)
├── providers/                   # State management with Provider
│   ├── auth_provider.dart       # Authentication state management
│   └── team_provider.dart       # Team data and operations
├── screens/                     # UI screens
│   ├── home_screen.dart         # Main dashboard with real data
│   ├── login_screen.dart        # Cognito authentication
│   ├── signup_screen.dart       # User registration
│   ├── create_team_screen.dart  # Team creation interface
│   ├── schedule_screen.dart     # Game schedule
│   ├── stats_screen.dart        # Team and player statistics
│   └── roster_screen.dart       # Team roster management
├── services/                    # API and business logic
│   ├── api_service.dart         # Comprehensive backend integration
│   └── auth_service.dart        # AWS Amplify authentication
├── utils/                       # Utility functions
│   ├── auth_validators.dart     # Input validation and sanitization
│   └── auth_error_handler.dart  # User-friendly error messages
└── widgets/                     # Reusable UI components
```

### Tech Stack
- **Framework**: Flutter 3.35.4+
- **Language**: Dart 3.9.2+
- **State Management**: Provider pattern with ChangeNotifier
- **Authentication**: AWS Amplify + Cognito
- **HTTP Client**: http package with JWT authorization
- **Local Storage**: SharedPreferences
- **Code Generation**: json_serializable, build_runner
- **Linting**: flutter_lints
- **Backend Integration**: RESTful API with comprehensive error handling

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
The app connects to a serverless Python backend with JWT authentication:
- **🔐 Authentication**: AWS Cognito with JWT tokens
- **👥 User Management**: Profile management with self-only access
- **🏆 Team Management**: Team creation, unified player model, ghost player support
- **🎮 Game Management**: Game scheduling, lineup management, and scoring
- **📊 Statistics**: Real-time stats calculation and historical data

### Backend API Structure (🔒 JWT Required)
```
# User Management
GET  /users/{id}                           # Get user profile (self-only)
PUT  /users/{id}                           # Update user profile (self-only)
GET  /users/{id}/teams                     # Get user's teams

# Team Management  
POST /teams                                # Create team
GET  /teams/{id}                           # Get team details
DELETE /teams/{id}                         # Delete team (cascading)

# Player Management (Unified Model)
GET  /teams/{id}/players                   # List team players
POST /teams/{id}/players                   # Add ghost player
POST /teams/{id}/players/{player_id}/link  # Link ghost to user
PUT  /teams/{id}/transfer-ownership        # Transfer ownership

# Game Management
POST /teams/{id}/games                     # Create game
GET  /teams/{id}/games                     # List games (paginated)
GET  /teams/{id}/games/{game_id}           # Get game details
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

## ✅ Recent Fixes

- **Authentication Flow**: Implemented comprehensive JWT validation with retry logic
- **Team Name Display**: Fixed dropdown showing correct team names (not "Unknown Team")
- **Card Width Consistency**: Resolved layout issues between Next Game and Stats cards
- **API Response Parsing**: Fixed team games and user teams data transformation
- **Stats Screen Overflow**: Resolved RenderFlex overflow issues
- **Dropdown Consistency**: Fixed dropdown direction and height consistency
- **Error Handling**: Implemented user-friendly error messages throughout the app

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

## 🗺️ Roadmap

### Phase 1 ✅ (Completed)
- [x] Basic UI/UX implementation with dark hacker theme
- [x] Navigation structure with bottom navigation
- [x] Dark theme with neon accents and custom typography
- [x] Team and player stats display with dynamic dropdowns
- [x] **Backend API integration** with comprehensive error handling
- [x] **AWS Cognito authentication** with JWT validation
- [x] **Team management** with real-time creation and data display
- [x] **State management** with Provider pattern
- [x] **Input validation** and user-friendly error messages

### Phase 2 🚧 (In Progress)
- [x] User profile management with self-only access
- [x] Team creation and membership display
- [ ] Game scheduling and lineup management
- [ ] Real-time game scoring interface
- [ ] Ghost player management and linking

### Phase 3 🔮 (Future)
- [ ] Advanced team and player analytics
- [ ] Push notifications for game updates
- [ ] Social features and team communication
- [ ] Offline mode with local data caching
- [ ] Multi-language support

---

**HackTracker** - Modern softball statistics tracking for the digital age. 🥎⚡