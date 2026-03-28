# 🗺️ Real-Time Location Tracking Map — AutoMate

> **Feature:** Hailing-app style map where drivers and mechanics can see each other's live location during emergency requests.

---

## Architecture Overview

```
Driver App                    Supabase                     Mechanic App
──────────────               ────────────                  ──────────────
1. Get GPS location    ──►   locations table    ◄──        1. Get GPS location
2. Upsert location           (realtime)                    2. Upsert location
3. Submit request     ──►   service_requests              3. Listen for new requests
4. See mechanic pin  ◄──    (realtime)         ──►        4. Accept / Reject
5. Track mechanic           locations table               5. Track driver pin
```

### How it works (like Grab/Angkas)
1. **Driver** opens the map — sees nearby mechanics as pins on the map.
2. Driver taps a mechanic or hits "Request Help" → submits an emergency request.
3. **Mechanic** gets a popup on their screen — can Accept or Reject.
4. After **accepted** — both see each other's **live GPS pin** updating in real time.
5. Mechanic marks job **Completed** → tracking stops.

---

## 📦 Dependencies to Add (`pubspec.yaml`)

```yaml
dependencies:
  flutter_map: ^7.0.2         # Map widget (uses OpenStreetMap, NO API key needed)
  latlong2: ^0.9.1            # LatLng coordinate class used by flutter_map
  geolocator: ^13.0.2         # Device GPS
  permission_handler: ^11.3.1 # Location permission dialogs
```

Run after adding:
```
flutter pub get
```

---

## 🗄️ Supabase SQL — Run in Supabase SQL Editor

```sql
-- ============================================================
-- TABLE: locations  (live GPS coordinates, upserted every ~5s)
-- ============================================================
create table locations (
  id         uuid primary key references auth.users(id) on delete cascade,
  role       text not null,           -- 'driver' or 'mechanic'
  latitude   float8 not null,
  longitude  float8 not null,
  updated_at timestamptz default now()
);

alter table locations enable row level security;

create policy "Users can upsert their own location"
  on locations for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Authenticated users can view all locations"
  on locations for select
  using (auth.role() = 'authenticated');

-- ============================================================
-- TABLE: service_requests  (the booking/job row)
-- ============================================================
create table service_requests (
  id           uuid primary key default gen_random_uuid(),
  driver_id    uuid references auth.users(id),
  mechanic_id  uuid references auth.users(id),   -- null until accepted
  status       text default 'pending',            -- pending | accepted | rejected | completed
  service_type text,                              -- 'emergency' | 'scheduled'
  description  text,
  created_at   timestamptz default now()
);

alter table service_requests enable row level security;

create policy "Driver can insert their own requests"
  on service_requests for insert
  with check (auth.uid() = driver_id);

create policy "Driver and Mechanic can read their requests"
  on service_requests for select
  using (auth.uid() = driver_id or auth.uid() = mechanic_id);

create policy "Mechanic can accept/reject (update status)"
  on service_requests for update
  using (auth.uid() = mechanic_id);

-- ============================================================
-- Enable Realtime for live updates
-- ============================================================
alter publication supabase_realtime add table locations;
alter publication supabase_realtime add table service_requests;
```

---

## 📁 New Files to Create (Flutter)

| File | Purpose |
|------|---------|
| `lib/Logic/location_logic.dart` | Gets GPS, upserts to Supabase, streams other user's location |
| `lib/Logic/request_logic.dart` | Creates requests, listens for status changes, accept/reject |
| `lib/screen/user/map_screen.dart` | Driver's live map screen |
| `lib/screen/mechanic/mechanic_map_screen.dart` | Mechanic's live map screen |

---

## 📝 Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add 4 new packages |
| `android/app/src/main/AndroidManifest.xml` | Add GPS permissions |
| `lib/screen/user/user_homescreen.dart` | Wire "Map" nav tab to MapScreen |
| `lib/screen/user/user_dashboard.dart` | Wire "Request Help" button to submit request + navigate to map |
| Mechanic dashboard (TBD) | Add map tab + incoming request handler |

---

## 📱 Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 🔄 User Flow

### Driver Flow
```
Home Screen
  └─► "Ask for Help" / "Map" tab
        └─► MapScreen (sees mechanic pins around them)
              └─► Tap mechanic OR fill request form
                    └─► Submit Request
                          └─► "Finding Mechanic..." banner
                                └─► Mechanic accepts
                                      └─► Live tracking begins
                                            └─► "Mechanic On the Way!" banner
```

### Mechanic Flow
```
Mechanic Dashboard
  └─► Map tab (sees their own location)
        └─► Incoming request popup appears
              ├─► Reject → dismiss
              └─► Accept → live tracking begins
                    └─► Navigate to driver
                          └─► Mark "Completed"
```

---

## ❓ Open Questions (for the group to decide)

1. **Map tab navigation** — Should the bottom nav "Map" tab open the live map, or is the map only accessible via "Ask for Help"?
2. **Mechanic screen** — Is there already a mechanic dashboard UI being built? The map screen needs to plug into it.
3. **Mechanic discovery** — Should the driver see ALL online mechanics, or only those within a specific radius (e.g., 10km)?
4. **Scheduled requests** — Do scheduled requests also use the map, or just emergency ones?

---

## ✅ Implementation Checklist

- [ ] Run Supabase SQL to create tables
- [ ] Add dependencies to `pubspec.yaml` and run `flutter pub get`
- [ ] Add Android location permissions
- [ ] Create `location_logic.dart`
- [ ] Create `request_logic.dart`
- [ ] Create `map_screen.dart` (driver)
- [ ] Create `mechanic_map_screen.dart` (mechanic)
- [ ] Wire up navigation in existing screens
- [ ] Test with two devices/emulators

---

*Generated: 2026-03-28 | AutoMate — Softdev 2 Project*
Delete the file after implementation