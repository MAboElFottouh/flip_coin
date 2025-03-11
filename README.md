# Flip Coin Game

A Flutter-based coin flipping game where players can test their luck by guessing the outcome of a coin flip.

## Features

### Authentication
- Login and signup functionality
- Username-based authentication
- Persistent user data using SharedPreferences

### Game Levels
- 10 different levels accessible from the home screen
- Level progress tracking with star rating system (⭐⭐⭐)
- Each level displays as a card with gradient background

### Gameplay
- Egyptian coin flip animation
- Head/Tail selection buttons
- Random outcome generation
- Win/loss detection and feedback
- Visual feedback for selected choices
- Smooth 3D coin flip animation

## Project Structure

```
flip_coin/
├── lib/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   └── game_screen.dart
│   ├── services/
│   │   └── auth_service.dart
│   └── main.dart
├── assets/
│   ├── head.png
│   └── tail.png
```

## Technical Details

### Dependencies
- flutter_sdk
- shared_preferences: ^2.2.2

### Key Components
1. **LoginScreen**
   - User authentication
   - Form validation
   - Login/Signup buttons with loading states

2. **HomeScreen**
   - Level selection interface
   - Progress tracking (stars)
   - Logout functionality
   - Vertical scrolling level list

3. **GameScreen**
   - Interactive coin flip animation
   - Head/Tail selection buttons
   - Start button for coin flip
   - Win/loss detection
   - User feedback through SnackBars

### Animation
- Uses AnimationController with 2-second duration
- Implements SingleTickerProviderStateMixin
- 3D rotation effect for coin flipping
- Smooth easing animation curves

## Game Flow
1. User logs in/signs up
2. Navigates through level selection
3. Selects Head or Tail
4. Presses Start to flip coin
5. Watches animation
6. Receives win/loss feedback
7. Can retry or return to levels

## Future Enhancements
- Score tracking system
- Level unlocking mechanism
- Sound effects
- Achievements system
- Multiplayer mode
