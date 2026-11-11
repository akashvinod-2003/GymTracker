# PulseFit - Gym Workout Tracker (Flutter)

A Flutter mobile and web application converted from the HTML prototype, featuring **Firebase Authentication**, **Cloud Firestore Database**, **Dark Mode & Light Mode**, and workout tracking.

---

## 🚀 Key Features

### 1. Daily Fitness Tab (Home)
- **Blue Curved Hero Card**:
  - Live calculated **Daily Lifted Volume** (kg) with pulsating activity badge.
  - Quick action buttons (Zap quick-complete and '+' quick entry).
  - 3-column stats pill card: **EXERCISES**, **TOTAL SETS**, and **FINISHED** sets.
- **Split Breakdown Carousel**:
  - Circular pastel muscle group badges with set counts and real-time workload percentage share.
  - Direct "Manage" shortcut to the Splits tab.
- **Interactive Exercise Cards**:
  - Equipment icon badges (Dumbbell, Machine, Barbell, Cable, Bodyweight).
  - Set-by-set tracker:
    - Set number (`#1`, `#2`, ...).
    - Editable **Weight (kg)** and **Reps** inputs with dynamic volume calculation.
    - Teal completion toggle button.
    - Delete set button (`-`).
  - "+ Add Set" button per exercise.
  - Empty state with "Quick Setup" action.

### 2. Splits & Muscle Groups Tab
- Configurable workout splits (e.g. Upper Body, Front/Anterior, Back/Posterior, Lower Body).
- Interactive muscle tags with removal buttons.
- "+ Add Muscle" modal dialog.
- "+ New Split" modal dialog to create custom workout splits.

### 3. Analytics & History Tab
- **Volume Performance Line Chart**:
  - Dark styled chart card showing daily volume progression across dates.
- **Donut Muscle Share Chart**:
  - Doughnut chart displaying breakdown of sets across muscle groups.
- **Previous Session Logs**:
  - Chronological list of recorded sessions with exercise counts and lifted volume.
  - Tap any session to view and modify that day's workout in the Daily tab.

### 4. Floating Navigation & Quick Entry
- Bottom floating pill navigation bar with custom center orange gradient **'+' FAB**.
- Quick Entry bottom sheet:
  - Starting Weight & Reps selector.
  - Exercise Name with suggestion presets.
  - Split selector chips.
  - Body Part grid cards with pastel icons.
  - Equipment Type chips.

### 5. Authentication & Firebase Integration
- **Firebase Authentication**: Email and Password authentication with Username support.
- **Cloud Firestore Database**:
  - User split groups stored under `users/{uid}/splits`.
  - Workout sessions stored under `users/{uid}/sessions/{dateKey}`.
- **Offline & Demo Mode Fallback**: Automatically activates seamless offline/local storage if Firebase keys are not yet configured or offline.

### 6. Dark Mode & Light Mode
- Comprehensive theming (Light mode matching the clean Tailwind CSS design, Dark mode matching the midnight navy analytics view).
- Quick toggle button in the app bar.
- Dedicated selector in the Profile Drawer (Light / Dark / System).
- Theme choice persisted via `SharedPreferences`.

---

## 🛠️ How to Run

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Windows (Desktop)
```bash
flutter run -d windows
```

### Run on Android / iOS
```bash
flutter run
```

---

## 🔥 Connecting Your Firebase Project

1. Install the FlutterFire CLI (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Run configuration:
   ```bash
   flutterfire configure
   ```
   This will automatically update `lib/firebase_options.dart` with your Firebase project credentials.
3. In your Firebase Console:
   - Enable **Authentication** -> **Email/Password** provider.
   - Create a **Cloud Firestore** database.
