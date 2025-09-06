# Hour Tracker

A Flutter app that helps you track what you do each hour of the day. This is essentially a time-based todo/activity tracker where you can log your activities for each hour and review your previous days.

## Features

- **24-Hour Daily View**: Track activities for each hour of the day (0:00 - 23:00)
- **Text Input for Each Hour**: Simple text boxes to record what you did during each hour
- **Data Persistence**: All entries are saved locally using SharedPreferences
- **Previous Day Navigation**: View and edit entries from previous days
- **Daily Activity Chart**: Visual pie chart showing logged vs empty hours
- **Edit Mode**: Toggle edit mode to clear individual entries or all entries for a day
- **Clean UI**: Easy-to-use interface with cards for each hour
- **Auto-save**: Entries are automatically saved as you type
- **No Debug Banner**: Clean production-ready interface

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── hour_entry.dart           # Data model for hour entries
├── screens/
│   ├── home_screen.dart          # Main screen with date navigation
│   └── day_view_screen.dart      # 24-hour view for a specific day
├── services/
│   └── storage_service.dart      # Local data persistence
└── widgets/
    ├── hour_tile.dart            # Individual hour input widget
    └── daily_activity_chart.dart # Daily activity visualization
```

## How to Use

1. **Home Screen**: 
   - View today's progress with activity chart
   - Navigate to previous days
   - Select specific dates using the calendar

2. **Day View**:
   - See all 24 hours for the selected day
   - View daily activity chart at the top (green = logged activities, gray = empty hours)
   - Enter activities in the text boxes for each hour
   - Entries auto-save as you type

3. **Edit Mode**:
   - Tap the edit icon in the app bar to enter edit mode
   - Clear individual entries using the red X button next to each text field
   - Clear all entries for the day using the "Clear All" button
   - Tap "Done" to exit edit mode

4. **Data Persistence**:
   - All entries are saved locally
   - Data persists between app sessions
   - Previous days remain accessible

## Dependencies

- `flutter`: Flutter SDK
- `shared_preferences`: For local data storage
- `intl`: For date formatting
- `cupertino_icons`: iOS-style icons
- `fl_chart`: For daily activity charts

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine
- Android Studio or VS Code with Flutter extensions
- An Android/iOS device or emulator

### Installation

1. Ensure Flutter is installed:
   ```bash
   flutter doctor
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Features in Detail

### Hour Input
- Each hour displays in 12-hour format (12:00 AM - 11:00 PM)
- Text boxes allow unlimited text input
- Auto-save functionality prevents data loss

### Data Storage
- Uses SharedPreferences for local storage
- Data is stored as JSON strings
- Efficient querying by date and hour

### Navigation
- Quick access to today's entries
- Date picker for selecting specific dates
- List of previous days with activity counts

## Future Enhancements

- Export data to CSV/PDF
- Search functionality across all entries
- Categories/tags for activities
- Statistics and analytics
- Backup and sync options
- Dark mode theme

## License

This project is open source and available under the MIT License.
