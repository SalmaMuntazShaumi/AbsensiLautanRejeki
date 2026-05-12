# 🚀 Quick Start Guide - Attendance System

## Step 1: Update Office Location 📍

Edit `lib/services/location_service.dart` and update your office coordinates:

```dart
// Replace these with your actual office location
static const double OFFICE_LATITUDE = -6.197728;      // Your office latitude
static const double OFFICE_LONGITUDE = 106.758653;    // Your office longitude
static const double RADIUS_METERS = 100.0;           // Verification radius (default: 100m)
```

**How to find your office coordinates:**
1. Open Google Maps
2. Search for your office address
3. Right-click on the location → Get coordinates
4. Copy the latitude and longitude

---

## Step 2: Install Dependencies 📦

```bash
cd "E:\Slam Project\Flutter\Lautan Rejeki"
flutter pub get
```

---

## Step 3: Configure Permissions 🔐

### Android Setup
Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Setup
Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to verify you are at the office for attendance.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture attendance proof photos.</string>
```

---

## Step 4: Verify Backend API 🔌

Your backend should have these endpoints:

**Clock-In Endpoint:**
```
POST http://192.168.0.31:8000/api/check-in
Authorization: Bearer {token}
Content-Type: application/json

Body:
{
  "photo": "base64_encoded_image_data"
}

Response:
{
  "success": true,
  "message": "Clock-in successful"
}
```

**Clock-Out Endpoint:**
```
POST http://192.168.0.31:8000/api/check-out
Authorization: Bearer {token}
Content-Type: application/json

Body:
{
  "photo": "base64_encoded_image_data",
  "reason": "Optional reason if early out"
}

Response:
{
  "success": true,
  "message": "Clock-out successful"
}
```

---

## Step 5: Run the App ▶️

```bash
flutter run
```

---

## 🧪 Testing Scenarios

### Test 1: Verify Location Check
**Scenario**: User clicks "Clock In" from outside the office
1. **Expected**: Error popup showing "You are XXX meters away from the office. You need to be within 100 meters to clock in."
2. **Action**: Move closer to office (within 100m radius)

### Test 2: Verify Camera Opens at Office
**Scenario**: User clicks "Clock In" from within office
1. **Expected**: Camera page opens with "Take Clock-In Photo" title
2. **Action**: Click the camera button to take a photo

### Test 3: Verify Clock-In Success
**Scenario**: Photo taken and submitted
1. **Expected**: Return to home page, "Clock-in" button becomes grayed out
2. **Data Sent**: POST to `/api/check-in` with photo (base64)

### Test 4: Verify Clock-Out Before 14:50
**Scenario**: Click "Clock Out" before 2:50 PM
1. **Expected**: "Early Out" popup appears asking for reason
2. **Action**: Enter reason and click "Continue"
3. **Expected**: Camera opens for photo
4. **Data Sent**: POST to `/api/check-out` with photo + reason

### Test 5: Verify Clock-Out After 14:50
**Scenario**: Click "Clock Out" after 2:50 PM
1. **Expected**: Camera directly opens (no reason dialog)
2. **Action**: Take photo
3. **Data Sent**: POST to `/api/check-out` with photo (no reason)

---

## 🎯 Key Features Overview

### 📍 Location Verification
- User must be within 100 meters of office to clock in
- System automatically detects location using GPS
- Error shown if outside radius

### 📸 Photo Capture
- Photos taken using device camera
- Automatically converted to Base64 format
- Sent directly to backend API
- **Not stored on device** (saves storage)

### ⏰ Time-Based Rules
- Clock-in marked as "Late" if after 8:30 AM
- Clock-in marked as "On Time" if before 8:30 AM
- Early out alert if clocking out before 14:50 (2:50 PM)

### 💾 Real-Time Recording
- All data recorded in database immediately
- Includes: time, photo, location coordinates, reason

### 🛡️ Error Handling
- Network errors properly displayed
- Permission denied errors shown
- Location verification failures detailed

---

## 📝 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    HOME PAGE                                │
│         Clock In [Button] | Clock Out [Button]              │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
    CLOCK-IN FLOW                CLOCK-OUT FLOW
        │                             │
    [Verify Location]              [Check Time]
        │                             │
        ├─ Outside Radius        ├─ Before 14:50
        │  └─ Show Error          │  └─ Early Out Dialog
        │                         │     └─ Get Reason
        │                         │
        ├─ Within Radius      After 14:50
        │  └─ Open Camera    └─ Skip Dialog
        │                         │
        ▼                         ▼
    [Take Photo]          [Open Camera]
        │                         │
        ▼                         ▼
    [Send to API]          [Take Photo]
        │                         │
        ▼                         ▼
    POST /api/check-in    POST /api/check-out
    { photo }             { photo, reason? }
        │                         │
        ▼                         ▼
    [Update DB]            [Update DB]
        │                         │
        ▼                         ▼
    [Show Success]         [Show Success]
        │                         │
        └──────────────┬──────────┘
                       │
                       ▼
            [Display Updated Status]
```

---

## 🐛 Troubleshooting

### Location Permission Denied
**Problem**: App says "Location permission denied"
**Solution**: 
1. Go to Settings → Apps → Lautan Rejeki → Permissions
2. Enable "Location"
3. Restart the app

### Camera Permission Denied
**Problem**: App says "Camera permission denied"
**Solution**:
1. Go to Settings → Apps → Lautan Rejeki → Permissions
2. Enable "Camera"
3. Restart the app

### Can't Detect Location
**Problem**: System can't find your location
**Solution**:
1. Ensure GPS is enabled on device
2. Move outdoors if possible
3. Close and reopen the app
4. Wait 10-15 seconds for GPS lock

### Photo Won't Upload
**Problem**: Photo capture works but doesn't submit
**Solution**:
1. Check internet connection
2. Verify API endpoint URL is correct
3. Check backend API is running
4. View error message for more details

### Clock-Out Button Grayed Out
**Problem**: Can't clock out after clocking in
**Solution**:
1. This is normal - wait for clock-in to complete
2. The button will become active once clock-in is processed
3. If it's still grayed out, check if there's an error message

---

## ✨ Tips & Tricks

### 1️⃣ Test with Mock Location
For development, you can use mock location in Android:
1. Enable "Mock location" in Developer Options
2. Use a mock location app to simulate being at the office

### 2️⃣ Check Database Records
After clocking in/out, verify the data in your backend:
- Look for photo base64 data
- Check timestamp is recorded
- Verify latitude/longitude are saved

### 3️⃣ Monitor Network Calls
Use tool like Charles Proxy or Postman to see:
- What data is being sent
- API response format
- Any errors from backend

### 4️⃣ Early Out Testing
To test early out functionality:
1. Change system time to before 14:50
2. Click "Clock Out"
3. Reason dialog should appear

### 5️⃣ Location Radius Testing
To test location verification:
1. Use mock location to set position 150+ meters away
2. Try to clock in
3. Should show error dialog

---

## 📞 Need Help?

**File Structure:**
```
lib/
 ├─ pages/
 │  └─ camera_page.dart          ← Camera UI
 ├─ services/
 │  ├─ location_service.dart     ← Location logic (MODIFY THIS)
 │  └─ camera_service.dart       ← Camera logic
 ├─ bloc/attendance/
 │  ├─ attendance_event.dart     ← Events
 │  ├─ attendance_state.dart     ← States
 │  └─ attendance_bloc.dart      ← BLoC logic
 ├─ repositories/
 │  └─ attendance_repository.dart ← API calls
 └─ components/
    └─ custom_absent_card.dart   ← Main UI component
```

**For Issues:**
1. Check `ATTENDANCE_SETUP.md` for setup details
2. Check `IMPLEMENTATION_SUMMARY.md` for feature overview
3. Review error messages in app
4. Check backend API logs

---

## 🎉 You're Ready!

Your attendance system is now fully functional. Just:
1. ✅ Update office coordinates
2. ✅ Install permissions
3. ✅ Run the app
4. ✅ Test the flows

Enjoy accurate, location-aware attendance tracking! 🚀

