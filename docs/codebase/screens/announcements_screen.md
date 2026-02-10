# Announcements Screen - Complete Technical Documentation
**File Location**: [`lib/screens/announcements_screen.dart`](../../../lib/screens/announcements_screen.dart)  
**Purpose**: Display system or institutional announcements  
**Type**: `StatelessWidget`  
**Lines of Code**: ~75

---

## Overview
This is a **static content screen** — it doesn't pull from AppState. It displays hardcoded announcements.

**Use Case**: University notices, deadlines, events.

---

## Screen Structure

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Announcements'),
    backgroundColor: AppColors.primaryBlue,
    centerTitle: true,
  ),
  body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildAnnouncementCard(...),
      SizedBox(height: 16),
      _buildAnnouncementCard(...),
      SizedBox(height: 16),
      _buildAnnouncementCard(...),
    ],
  ),
)
```

**Layout**: Simple vertical list of cards.

---

## Announcement Card

```dart
Widget _buildAnnouncementCard(String title, String subtitle, String body) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
```

### Typography Hierarchy
1. **Title**: 20px, bold, dark
2. **Subtitle**: 16px, bold, black
3. **Body**: Default size, grey, line height 1.5

---

## Sample Data

```dart
_buildAnnouncementCard(
  'Announcements',
  'Reminder: Project Deadlines',
  'Department of Software Engineering\nComming at deliverable beyond\nwill issue in',
)
```

**Note**: The actual text appears to be placeholder content. In a production app, this would be:
1. Fetched from an API
2. Stored in AppState
3. Rendered dynamically

---

## Future Enhancements

### Dynamic Data from API
```dart
class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
}

// In AppState
List<Announcement> _announcements = [];

// Fetch from server
Future<void> fetchAnnouncements() async {
  final response = await http.get('https://api.uni.com/announcements');
  _announcements = (jsonDecode(response.body) as List)
      .map((json) => Announcement.fromJson(json))
      .toList();
  notifyListeners();
}
```

### Read/Unread State
```dart
class Announcement {
  bool isRead;
}

// Visual indicator
Container(
  decoration: BoxDecoration(
    color: announcement.isRead ? Colors.white : Colors.blue.withOpacity(0.1),
  ),
  child: ...,
)
```

### Push Notifications
```dart
// When new announcement arrives
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(message.notification!.title!),
      content: Text(message.notification!.body!),
    ),
  );
});
```

---

## Design Patterns

### Card Padding
```dart
padding: const EdgeInsets.all(20)
```
**Purpose**: Inner spacing for comfortable reading.

### Spacing Between Elements
```dart
const SizedBox(height: 12)
```
**Purpose**: Vertical rhythm.

### Line Height
```dart
height: 1.5
```
**Purpose**: Improved readability for body text (150% of font size).

---

## Accessibility Considerations

### Semantic Structure
Order matters:
1. Title (most important)
2. Subtitle (context)
3. Body (details)

Screen readers narrate in this order.

### Color Contrast
- **Title**: Dark on white (high contrast)
- **Body**: Grey on white (medium contrast, but still accessible)

---

## Performance
**Cost**: Negligible. 3 static cards.  
**Optimization**: None needed unless dynamic list grows to 100+ items.

---

## Summary
- **Purpose**: Static content display
- **Current State**: Hardcoded placeholder text
- **Future State**: Dynamic API-driven announcements
- **Pattern**: Reusable card component
