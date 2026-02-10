# Quick Reference Card - Common Scenarios

This is your **cheat sheet** for quickly finding documentation during your demo or debugging.

---

## 🚨 "I need to explain this feature in my demo"

| Feature | Primary Doc | Supporting Docs |
|---------|-------------|-----------------|
| Adding an assignment | [assignments_screen.md](codebase/screens/assignments_screen.md) | [app_state.md](codebase/providers/app_state.md) |
| Checking attendance | [risk_status_screen.md](codebase/screens/risk_status_screen.md) | [session.md](codebase/models/session.md) |
| Viewing schedule | [schedule_screen.md](codebase/screens/schedule_screen.md) | [app_state.md](codebase/providers/app_state.md) |
| Dashboard overview | [dashboard_screen.md](codebase/screens/dashboard_screen.md) | [app_state.md](codebase/providers/app_state.md) |
| First-time setup | [signup_screen.md](codebase/screens/signup_screen.md) | [main.dart](codebase/main.md) |

---

## 🐛 "Something is broken, where do I look?"

| Problem | Check This Doc First |
|---------|---------------------|
| Data not saving | [app_state.md](codebase/providers/app_state.md) → _saveData() |
| Screen not updating | [03_STATE_MANAGEMENT_DEEP_DIVE.md](03_STATE_MANAGEMENT_DEEP_DIVE.md) → notifyListeners() |
| Assignment not showing | [assignments_screen.md](codebase/screens/assignments_screen.md) → filteredAssignments |
| Schedule date grouping wrong | [schedule_screen.md](codebase/screens/schedule_screen.md) → groupByday() |
| Attendance calculation wrong | [app_state.md](codebase/providers/app_state.md) → getAttendancePercentage() |
| Can't load saved data | [app_state.md](codebase/providers/app_state.md) → initData() |

---

## 🎤 "I'm being asked technical questions"

| Question Topic | Reference Doc |
|----------------|---------------|
| "Explain your architecture" | [01_ARCHITECTURE.md](01_ARCHITECTURE.md) |
| "How does state management work?" | [03_STATE_MANAGEMENT_DEEP_DIVE.md](03_STATE_MANAGEMENT_DEEP_DIVE.md) + [app_state.md](codebase/providers/app_state.md) |
| "Show me the data models" | [assignment.md](codebase/models/assignment.md) + [session.md](codebase/models/session.md) |
| "How is data persisted?" | [app_state.md](codebase/providers/app_state.md) → SharedPreferences section |
| "Explain this UI pattern" | [04_UI_DECONSTRUCTION.md](04_UI_DECONSTRUCTION.md) |
| "What's your most complex code?" | [schedule_screen.md](codebase/screens/schedule_screen.md) → Week offset logic |

---

## 📖 "Which file should I read first?"

### If you have 15 minutes
1. [TUTORIAL.md](../TUTORIAL.md) - Quick overview
2. [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) - Understand what you have

### If you have 1 hour
1. [01_ARCHITECTURE.md](01_ARCHITECTURE.md) - 15 min
2. [main.dart](codebase/main.md) - 10 min
3. [app_state.dart](codebase/providers/app_state.md) - 35 min (skim, don't memorize)

### If you have 3 hours
Follow the **Intermediate Path** in [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 🔍 "I want to understand a specific concept"

| Concept | Primary Doc | Example In Code |
|---------|-------------|-----------------|
| Provider pattern | [03_STATE_MANAGEMENT_DEEP_DIVE.md](03_STATE_MANAGEMENT_DEEP_DIVE.md) | [dashboard_screen.md](codebase/screens/dashboard_screen.md) |
| JSON serialization | [02_DATA_MODELS.md](02_DATA_MODELS.md) | [assignment.md](codebase/models/assignment.md) |
| Date/time handling | [05_DART_CONCEPTS.md](05_DART_CONCEPTS.md) | [schedule_screen.md](codebase/screens/schedule_screen.md) |
| Enums | [02_DATA_MODELS.md](02_DATA_MODELS.md) | [assignment.md](codebase/models/assignment.md) |
| ListView.builder | [04_UI_DECONSTRUCTION.md](04_UI_DECONSTRUCTION.md) | [assignments_screen.md](codebase/screens/assignments_screen.md) |
| Dismissible widget | [04_UI_DECONSTRUCTION.md](04_UI_DECONSTRUCTION.md) | [assignments_screen.md](codebase/screens/assignments_screen.md) |
| TabController | [04_UI_DECONSTRUCTION.md](04_UI_DECONSTRUCTION.md) | [assignments_screen.md](codebase/screens/assignments_screen.md) |
| Navigation | [01_ARCHITECTURE.md](01_ARCHITECTURE.md) | [home_screen.md](codebase/screens/home_screen.md) |

---

## 💻 "I'm recording my demo video"

### Opening (30 seconds)
Read: [01_ARCHITECTURE.md](01_ARCHITECTURE.md) → Introduction section

**Script**: "This is a Flutter application using the MVVM architecture pattern with Provider for state management..."

### Feature Showcase (2 minutes)
Reference: [dashboard_screen.md](codebase/screens/dashboard_screen.md)

**Demo Flow**:
1. Show dashboard
2. Add an assignment (pause and explain Provider update)
3. Show attendance risk warning
4. Navigate to schedule

### Code Walkthrough (2 minutes)
Open docs while showing code:
- Show [app_state.dart](codebase/providers/app_state.md) → addAssignment() method
- Explain notifyListeners()
- Show [assignments_screen.md](codebase/screens/assignments_screen.md) → Consumer widget

### Closing (30 seconds)
Read: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) → "What You'll Master" section

---

## 🎯 One-Sentence Summaries (For Quick Recall)

| File | One-Sentence Summary |
|------|---------------------|
| main.dart | Entry point that wraps MaterialApp with ChangeNotifierProvider |
| assignment.dart | Data class with UUID, enums, and JSON serialization |
| session.dart | Calendar event with attendance tracking and time queries |
| app_state.dart | **The brain**: CRUD operations, persistence, and derived state calculations |
| home_screen.dart | Bottom navigation container with 5 tabs |
| dashboard_screen.dart | Aggregates stats and displays risk warnings |
| assignments_screen.dart | CRUD interface with tabs, Dismissible, and modal forms |
| schedule_screen.dart | Week navigation with date grouping and auto-scroll |
| risk_status_screen.dart | Attendance history with toggle switches |
| announcements_screen.dart | Static content cards |
| signup_screen.dart | Onboarding flow with validation |

---

## 📞 Emergency Contacts (During Demo)

**If asked**: "How does X work?"
1. **Don't panic**
2. Say: "Let me show you the exact code"
3. Open relevant .md file from docs/
4. Ctrl+F to find the section
5. Explain based on documentation

**Example**:
> **Question**: "How do you calculate attendance percentage?"  
> **Action**: Open [app_state.md](codebase/providers/app_state.md) → Search "getAttendancePercentage"  
> **Answer**: "We filter past sessions, count those where isPresent is true, divide by total, and multiply by 100. The formula is right here: `(attended / total) * 100`"

---

## 🏆 5-Minute Power Study

If you only have 5 minutes before your demo:

1. **Minute 1**: Read [TUTORIAL.md](../TUTORIAL.md) overview
2. **Minute 2**: Skim [app_state.md](codebase/providers/app_state.md) table of contents
3. **Minute 3**: Read [dashboard_screen.md](codebase/screens/dashboard_screen.md) architecture overview
4. **Minute 4**: Review [01_ARCHITECTURE.md](01_ARCHITECTURE.md) MVVM diagram
5. **Minute 5**: Practice saying: "This app uses Provider for reactive state management, persists data with SharedPreferences, and follows MVVM architecture with clear separation between models, providers, and screens."

---

**Pro Tip**: Keep [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) open in a browser tab during your demo for quick Ctrl+F searches.
