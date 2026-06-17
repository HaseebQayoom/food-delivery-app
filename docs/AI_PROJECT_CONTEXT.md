# AI Project Context — crave. Food Delivery App

> **Purpose of this file:** Single source of truth for AI agents working on this project.
> Read this document before reading any source file. It tells you exactly which files to open for each task.

---

## Project Overview

| Field | Value |
|---|---|
| **Project Name** | crave. |
| **Type** | Flutter mobile app (food delivery) |
| **Purpose** | Food delivery ordering platform for a single restaurant, with customer-facing app and admin panel |
| **Target Users** | Food delivery customers (Pakistan market); restaurant staff via admin panel |
| **FYP Context** | Final Year Project — demo-ready, not production-deployed |
| **Completion** | Feature-complete — all screens and providers built; only `.env` credentials required to run |
| **flutter analyze** | ✅ No issues |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | Flutter 3.x (SDK ^3.11.5) |
| **State Management** | Riverpod 2.6.1 — `Provider` + `NotifierProvider` only |
| **Backend** | Supabase (supabase_flutter ^2.8.4) |
| **Database** | Supabase PostgreSQL (via Supabase client) |
| **Authentication** | Supabase Auth (email/password) |
| **Payments** | Stripe (flutter_stripe ^11.1.0) |
| **Maps** | OpenStreetMap via flutter_map ^7.0.2 (no API key needed) |
| **AI Chat** | Google Gemini 1.5 Flash (google_generative_ai ^0.4.6) |
| **Fonts** | Google Fonts — DM Sans + Bricolage Grotesque |
| **Images** | cached_network_image ^3.4.1 |
| **Environment** | flutter_dotenv ^5.1.0 |
| **Local Storage** | shared_preferences ^2.3.2 (cart persistence, onboarding flag) |
| **HTTP Client** | Dio ^5.7.0 (provider exists; direct Supabase client used for most calls) |
| **Formatting** | intl ^0.19.0 (DateFormat for order history) |
| **Navigation** | Standard Flutter Navigator — NOT go_router |

---

## Architecture

### Pattern

Feature-first folder structure with MVVM and Repository pattern. No dependency injection framework — Riverpod providers serve as the DI container.

```
UI (Screen) → watches → Notifier (ViewModel) → reads → Repository → calls → Supabase/Service
```

### Riverpod Rules — CRITICAL

```
✅ ALLOWED:
   Provider<T>                           — read-only values, repos, services
   NotifierProvider<Notifier, State>     — mutable state with logic
   NotifierProvider.family<N, S, Arg>    — parameterised (e.g., restaurantDetailProvider)

❌ FORBIDDEN — will break the architecture:
   FutureProvider
   StreamProvider
   StateProvider
   AsyncNotifierProvider
   StateNotifierProvider
```

### Data Flow Diagram

```
┌────────────────────────────────────────────────────────────┐
│  Widget (ConsumerWidget / ConsumerStatefulWidget)           │
│    ref.watch(xNotifierProvider)  ← rebuilds on state change │
│    ref.read(xNotifierProvider.notifier).someMethod()        │
└──────────────┬────────────────────────────┬────────────────┘
               │ watches state              │ calls method
               ▼                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Notifier (extends Notifier<State>)                          │
│    State build() { ... }                                     │
│    Future<void> someMethod() { ... }                         │
│    ref.read(xRepositoryProvider)  ← reads repository        │
└──────────────────────────┬──────────────────────────────────┘
                           │ calls
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Repository                                                  │
│    Supabase.instance.client.from('table').select()...        │
│    Returns models (not raw JSON)                             │
└─────────────────────────────────────────────────────────────┘
```

### Code Style Rules

- `(_, _)` for multiple unused callback params — never `(_, _2)` or `(_, __)`
- `AppThemeColors` tokens via `ac.xxx` — never hardcode `Color(0xFF...)` in widget files
- `AppDimensions.md` for spacing — never hardcode pixel values
- All secrets via `Env.xxx` from `.env` — never hardcode
- `SegmentedButton<T>` not deprecated `RadioListTile` group patterns
- `DropdownMenu<T>` not deprecated `DropdownButtonFormField`
- `activeThumbColor` not deprecated `activeColor` on `SwitchListTile`
- Color constants that have no `AppThemeColors` equivalent go in `AppColors` — never inline in widget files

---

## Folder Structure

```
food_delivery/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        ← AppColors static constants + AppGradients
│   │   │   ├── app_dimensions.dart    ← AppDimensions spacing/radius constants
│   │   │   ├── app_strings.dart       ← app-wide string constants
│   │   │   └── env.dart               ← Env class — reads .env via flutter_dotenv
│   │   ├── navigation/
│   │   │   ├── app_navigator.dart     ← AppNavigator (21 static methods)
│   │   │   ├── admin_navigator.dart   ← legacy stub — prefer AppNavigator.toAdminShell
│   │   │   └── app_routes.dart        ← route name constants (not actively used)
│   │   ├── providers/
│   │   │   ├── auth_state_provider.dart   ← currentUserProvider, isLoggedInProvider
│   │   │   ├── dio_provider.dart          ← dioProvider (Dio HTTP client)
│   │   │   └── shared_prefs_provider.dart ← sharedPrefsProvider (injected in main)
│   │   ├── utils/
│   │   │   ├── extensions.dart        ← BuildContext extensions
│   │   │   ├── helpers.dart           ← Helpers (getInitials, showSuccessSnackBar, etc.)
│   │   │   └── validators.dart        ← Validators.name / .email / .password
│   │   └── widgets/                   ← shared reusable widgets (see Reusable Widgets)
│   │
│   ├── features/
│   │   ├── admin/                     ← admin panel (single app, email-gated routing)
│   │   │   ├── dishes/
│   │   │   │   └── admin_dishes_notifier.dart  ← AdminDishesNotifier + AdminDishesState
│   │   │   ├── menu/
│   │   │   │   ├── admin_menu_screen.dart      ← 3-col grid + category filter pills
│   │   │   │   └── meal_editor_drawer.dart     ← slide-in drawer (create/edit dish)
│   │   │   ├── orders/
│   │   │   │   ├── admin_orders_notifier.dart  ← AdminOrdersNotifier + AdminOrdersState
│   │   │   │   └── admin_orders_screen.dart    ← filter tabs + list/detail split view
│   │   │   ├── shell/
│   │   │   │   └── admin_shell_screen.dart     ← desktop sidebar shell
│   │   │   └── widgets/
│   │   │       ├── availability_switch.dart    ← animated on/off toggle
│   │   │       ├── menu_card.dart              ← dish card for menu grid
│   │   │       ├── notifications_panel.dart    ← bell dropdown (static demo data)
│   │   │       ├── status_chip.dart            ← customer app order badge (Material colors)
│   │   │       └── status_pill.dart            ← admin order badge (exact JSX colors)
│   │   │
│   │   ├── auth/
│   │   │   ├── auth_screen.dart              ← login + signup; routes to AdminShell or Shell
│   │   │   ├── providers/auth_notifier.dart
│   │   │   └── widgets/auth_text.dart
│   │   │
│   │   ├── cart/
│   │   │   ├── cart_screen.dart
│   │   │   └── providers/cart_notifier.dart
│   │   │
│   │   ├── chat/
│   │   │   ├── chat_screen.dart              ← Gemini AI support chat
│   │   │   └── providers/chat_notifier.dart
│   │   │
│   │   ├── checkout/
│   │   │   ├── checkout_screen.dart
│   │   │   └── providers/checkout_notifier.dart
│   │   │
│   │   ├── favorites/
│   │   │   ├── favorites_screen.dart
│   │   │   └── providers/favorites_notifier.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart              ← tab 0 of ShellScreen (single-restaurant design)
│   │   │   ├── menu_all_screen.dart          ← full menu with category pills + MealListRow list
│   │   │   ├── category_grid_screen.dart     ← left-rail + 2-col grid browse view
│   │   │   ├── providers/home_notifier.dart
│   │   │   └── widgets/
│   │   │       └── meal_detail_view.dart     ← MealDetailView + showMealDetail() helper
│   │   │
│   │   ├── onboarding/
│   │   │   ├── data/onboarding_data.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/pageview_design.dart
│   │   │
│   │   ├── orders/
│   │   │   ├── active_orders_screen.dart    ← list of all active orders; tap → TrackingScreen
│   │   │   ├── order_history_screen.dart
│   │   │   ├── order_success_screen.dart
│   │   │   └── providers/
│   │   │       ├── active_order_notifier.dart   ← activeOrderNotifierProvider (List<OrderModel>)
│   │   │       └── order_history_notifier.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart           ← tab 3 of ShellScreen
│   │   │   ├── providers/profile_notifier.dart
│   │   │   ├── address/
│   │   │   │   ├── address_screen.dart
│   │   │   │   └── providers/address_notifier.dart
│   │   │   ├── edit/edit_profile_screen.dart
│   │   │   ├── invite/invite_screen.dart
│   │   │   ├── notifications/notifications_screen.dart
│   │   │   ├── payment/
│   │   │   │   ├── payment_screen.dart
│   │   │   │   └── providers/payment_notifier.dart
│   │   │   └── preferences/preferences_screen.dart
│   │   │
│   │   ├── restaurant/
│   │   │   ├── restaurant_detail_screen.dart
│   │   │   └── providers/restaurant_detail_notifier.dart   ← family notifier
│   │   │
│   │   ├── shell/
│   │   │   └── shell_screen.dart             ← IndexedStack + CustomBottomNavBar
│   │   │
│   │   ├── splash/
│   │   │   └── splash_screen.dart            ← app entry, auth routing (admin-aware)
│   │   │
│   │   └── tracking/
│   │       ├── tracking_screen.dart
│   │       └── providers/tracking_notifier.dart  ← polls every 15s
│   │
│   ├── models/
│   │   ├── address_model.dart
│   │   ├── cart_item_model.dart
│   │   ├── category_model.dart
│   │   ├── chat_message_model.dart
│   │   ├── dish_model.dart
│   │   ├── onboard_model.dart
│   │   ├── order_model.dart          ← includes OrderStatus enum
│   │   ├── payment_method_model.dart ← includes PaymentType enum
│   │   ├── restaurant_model.dart
│   │   └── user_model.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart      ← auth + profile upsert on signup
│   │   ├── cart_repository.dart      ← local only (SharedPreferences)
│   │   ├── dish_repository.dart      ← Supabase dishes table + admin CRUD
│   │   ├── order_repository.dart     ← Supabase orders table
│   │   ├── profile_repository.dart   ← profiles, addresses, payment_methods
│   │   └── restaurant_repository.dart ← Supabase restaurants + favorites
│   │
│   ├── services/
│   │   ├── api_service.dart          ← Dio-based service (supplemental)
│   │   ├── auth_service.dart         ← thin wrapper over Supabase Auth
│   │   ├── storage_service.dart      ← Supabase Storage (file/image upload)
│   │   └── stripe_service.dart       ← Stripe payment sheet (v11 API)
│   │
│   ├── theme/
│   │   └── app_theme.dart            ← AppTheme, AppThemeColors ThemeExtension
│   │
│   └── main.dart                     ← single app entry point (customer + admin)
│
├── supabase/
│   └── schema.sql                    ← full DB schema + RLS + seed data
├── .env                              ← secrets (NOT in git)
├── .env.example                      ← template (safe to commit)
└── pubspec.yaml
```

---

## Navigation Map

### App Entry Point

Single entry: `lib/main.dart` → `CraveApp` → `SplashScreen`. There is **no separate admin entry point** — the same app routes to either `ShellScreen` (customer) or `AdminShellScreen` (admin) based on email.

### Authentication Flow

```
SplashScreen (2s delay)
  │
  ├── onboarding NOT seen ──────────────► OnboardingScreen
  │                                              │
  │                                              └─ "Get Started" ──► AuthScreen
  │
  ├── onboarding seen, NO session ──────► AuthScreen
  │                                              │
  │                                              ├─ admin email login ──► AdminShellScreen
  │                                              └─ other email login  ──► ShellScreen
  │
  └── onboarding seen, session EXISTS
        ├── email == Env.adminEmail ──────► AdminShellScreen
        └── other email ─────────────────► ShellScreen
```

**Admin email** is set via `ADMIN_EMAIL` in `.env`. The check runs in both `AuthScreen._submitForm()` and `SplashScreen._navigate()`.

### Customer App — Main Navigation

`ShellScreen` owns the bottom nav bar (`CustomBottomNavBar`) and hosts 4 tabs via `IndexedStack`:

```
ShellScreen (tabs)
  ├── [0] HomeScreen      (home_rounded icon)
  ├── [1] FavoritesScreen (favorite_rounded icon)
  ├── [2] CartScreen      (shopping_bag_rounded icon)
  ├── [3] ChatScreen      (smart_toy_rounded icon — "AI Chat")
  └── [4] ProfileScreen   (person_rounded icon)
```

Screens pushed on top of the shell (standard `Navigator.push`):
```
HomeScreen
  └── RestaurantDetailScreen(restaurantId)
        └── CartScreen (via AppNavigator.toCart)
              └── CheckoutScreen
                    └── OrderSuccessScreen
                          └── TrackingScreen(orderId)

ProfileScreen
  ├── OrderHistoryScreen
  ├── AddressScreen
  ├── PaymentScreen
  ├── EditProfileScreen
  ├── NotificationsScreen
  ├── InviteScreen
  └── PreferencesScreen

Any screen
  └── ChatScreen (Gemini support)
```

### Admin App — Main Navigation

```
AdminShellScreen (desktop sidebar shell)
  ├── [orders tab] AdminOrdersScreen
  │     ├── Filter tabs: Active | On the way | History
  │     └── Split view: order list (left) + order detail (right)
  └── [menu tab]   AdminMenuScreen
        ├── Category filter pills (horizontal scroll)
        ├── 3-column dish grid (MenuCard widgets)
        └── MealEditorDrawer (slide-in overlay — not a separate route)
              triggered by: adminDishesProvider.editingDishId != null
```

Admin logout: `Supabase.instance.client.auth.signOut()` → `AppNavigator.toAuth(context)` (in sidebar user card).

### AppNavigator Methods (all 21)

| Method | Behaviour | Destination |
|---|---|---|
| `toOnboarding` | `pushReplacement` | OnboardingScreen |
| `toAuth` | `pushReplacement` | AuthScreen |
| `toHome` | `pushAndRemoveUntil` (clears stack) | ShellScreen |
| `toAdminShell` | `pushAndRemoveUntil` (clears stack) | AdminShellScreen |
| `toCheckout` | `push` | CheckoutScreen |
| `toTracking(orderId)` | `push` | TrackingScreen |
| `toRestaurantDetail(restaurantId)` | `push` | RestaurantDetailScreen |
| `toCart` | `push` | CartScreen |
| `toChat` | `push` | ChatScreen |
| `toOrderSuccess(order)` | `push` | OrderSuccessScreen |
| `toActiveOrders` | `push` | ActiveOrdersScreen |
| `toOrderHistory` | `push` | OrderHistoryScreen |
| `toAddresses` | `push` | AddressScreen |
| `toPaymentMethods` | `push` | PaymentScreen |
| `toEditProfile` | `push` | EditProfileScreen |
| `toNotifications` | `push` | NotificationsScreen |
| `toInvite` | `push` | InviteScreen |
| `toPreferences` | `push` | PreferencesScreen |
| `toMenuAll` | `push` | MenuAllScreen — full menu with category pills |
| `toCategoryGrid` | `push` | CategoryGridScreen — left-rail + grid browse |
| `back` | `Navigator.pop` | — |

> `admin_navigator.dart` exists as legacy code with a `toAdminDashboard` stub. It is not used — prefer `AppNavigator.toAdminShell`.

---

## Theme System

### Files Responsible for Theme

| File | Responsibility |
|---|---|
| `lib/theme/app_theme.dart` | `AppTheme`, `AppThemeColors` — everything theme-related |
| `lib/core/constants/app_colors.dart` | `AppColors` static constants, `AppGradients.primary` |
| `lib/core/constants/app_dimensions.dart` | `AppDimensions` spacing/radius constants |

### Color System

**Seed color:** `Color(0xFFFF5A1F)` — Material 3 `ColorScheme.fromSeed` generates the full palette. `primary` is forced to exactly `#FF5A1F` via `.copyWith(primary: Color(0xFFFF5A1F), onPrimary: Colors.white)` — without this, `fromSeed` with `tonalSpot` produces a shifted tone.

**Custom extension — `AppThemeColors`** (accessed as `Theme.of(context).extension<AppThemeColors>()!` → `ac`):

| Token | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `ac.background` | `#FFF8F3` (neutral warm white) | `#1A1714` | Scaffold backgrounds |
| `ac.surface` | `#FFFFFF` (pure white) | `#1C1917` | Cards, input fills |
| `ac.creamSurface` | `#FCEEE3` | `#26211D` | Stats bar, image fallbacks, category chips |
| `ac.softAccentSurface` | `#FFE8DC` | `#33261E` | Light orange surfaces; admin onTheWay status bg |
| `ac.primaryText` | `#1A1612` (near black) | `#FFF6EF` | Body text; admin sidebar bg |
| `ac.secondaryText` | `#5A4F47` | `#D3C7BE` | Subtitles |
| `ac.mutedText` | `#8C7E73` | `#A89B91` | Hints, placeholders |
| `ac.border` | `#EFE7DF` | `#3B332E` | Card/container borders |
| `ac.navbarBackground` | `#1A1612` (dark) | `#1C1917` | Floating pill nav bar; admin sidebar |
| `ac.inputFill` | `#FFFFFF` (pure white) | `#1C1917` | TextField fill |
| `ac.success` | `#2DBE60` | `#4ADE80` | Order status: delivered; availability switch ON |
| `ac.warning` | `#FFB400` | `#FBBF24` | Warnings |
| `ac.primaryGradientStart` | `#EF9F27` | `#EF9F27` | Gradient start (orange) |
| `ac.primaryGradientEnd` | `#D85A30` | `#D85A30` | Gradient end (red-orange) |
| `ac.cardShadow` | 4% black, 12px blur | 10% black | `boxShadow` on cards |
| `ac.buttonShadow` | 32% orange glow | 40% orange | `GradientButton` shadow |
| `ac.navbarShadow` | 25% black, 40px blur | 38% black | Bottom nav shadow |

**`AppColors` static constants** (for colors with no `AppThemeColors` equivalent):

```dart
// Gradients
AppColors.primaryGradientStart  // Color(0xFFEF9F27)
AppColors.primaryGradientEnd    // Color(0xFFD85A30)
AppColors.success               // Color(0xFF2DBE60)
AppColors.warning               // Color(0xFFFFB400)

// Admin status pill — exact JSX statusMeta values
AppColors.statusNewBg           // Color(0xFFE1F0FF)
AppColors.statusNewFg           // Color(0xFF2563EB)
AppColors.statusPreparingBg     // Color(0xFFFFF1D6)
AppColors.statusPreparingFg     // Color(0xFFB7791F)
AppColors.statusDeliveredBg     // Color(0xFFE2F6E9)
AppColors.statusDeliveredFg     // Color(0xFF1F8A4C)
AppColors.statusCancelledBg     // Color(0xFFFBEAEA)
AppColors.statusCancelledFg     // Color(0xFFDC2626)

// Admin misc
AppColors.switchOff             // Color(0xFFD8D0C6)  — availability switch OFF
AppColors.tagSpicy              // Color(0xFFE14B3B)  — spicy tag badge
AppColors.adminBackground       // Color(0xFFF7F4EF)  — admin content area bg
AppColors.storeOpenBorder       // Color(0xFFBFE8CD)  — "Store open" badge border

AppGradients.primary            // LinearGradient(primaryGradientStart → primaryGradientEnd)
```

**Admin JSX design token mapping** (`C.xxx` → Flutter equivalent):

| JSX token | Value | Flutter |
|---|---|---|
| `C.primary` | `#FF5A1F` | `cs.primary` |
| `C.ink` | `#1A1612` | `ac.primaryText` / `ac.navbarBackground` |
| `C.inkSoft` | `#5A4F47` | `ac.secondaryText` |
| `C.mute` | `#8C7E73` | `ac.mutedText` |
| `C.line` | `#EFE7DF` | `ac.border` |
| `C.cream` | `#FCEFE3` | `ac.creamSurface` |
| `C.primarySoft` | `#FFE8DC` | `ac.softAccentSurface` |
| `C.success` | `#2DBE60` | `ac.success` |

### Typography System

Two fonts applied globally in `AppTheme._textTheme()`:

| Style category | Font | Examples |
|---|---|---|
| `displayLarge/Medium/Small` | **Bricolage Grotesque** | Hero text |
| `headlineLarge/Medium/Small` | **Bricolage Grotesque** | Screen titles |
| `titleLarge/Medium/Small` | **DM Sans** | Section headers, card titles |
| `bodyLarge/Medium/Small` | **DM Sans** | Body text, labels |
| `labelSmall` | **DM Sans** | Badges, caps labels |

Base font family: `GoogleFonts.dmSans().fontFamily` (fallback for all other text).

### Spacing System — `AppDimensions`

| Constant | Value | Usage |
|---|---|---|
| `AppDimensions.xs` | 4 | Tiny gaps |
| `AppDimensions.sm` | 8 | Small gaps |
| `AppDimensions.md` | 16 | Standard padding |
| `AppDimensions.lg` | 24 | Section padding |
| `AppDimensions.xl` | 32 | Large gaps |
| `AppDimensions.xxl` | 48 | Extra-large gaps |
| `AppDimensions.radiusMd` | 16 | Card/tile radius |
| `AppDimensions.radiusLg` | 24 | Sheet/modal radius |
| `AppDimensions.radiusCircle` | 999 | Pill/circle shapes |
| `AppDimensions.screenPadding` | 20 | Horizontal screen margin |

### Applying the Theme in Widgets

```dart
final cs = Theme.of(context).colorScheme;    // Material 3 color scheme
final ac = Theme.of(context).extension<AppThemeColors>()!;  // custom tokens
final tt = Theme.of(context).textTheme;      // typography
```

---

## Feature Registry

---

### Splash

**Purpose:** App entry point. Checks session and onboarding state, routes accordingly.

**Screens:** `SplashScreen` — `lib/features/splash/splash_screen.dart`

**Providers:** `sharedPrefsProvider`, `isLoggedInProvider`

**Logic:** After 2-second delay:
- `!onboardingSeen` → Onboarding
- `session == null` → Auth
- `session.user.email == Env.adminEmail` → AdminShellScreen
- else → ShellScreen

**Important Files:** `lib/features/splash/splash_screen.dart`

---

### Onboarding

**Purpose:** First-launch walkthrough. Sets `onboardingSeen = true` in SharedPreferences.

**Screens:** `OnboardingScreen` — `lib/features/onboarding/onboarding_screen.dart`

**Providers:** `sharedPrefsProvider` (to write flag)

**Important Files:**
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/data/onboarding_data.dart`

---

### Auth

**Purpose:** Email/password login and account creation. Wired to Supabase Auth. Routes to admin or customer shell based on email.

**Screens:** `AuthScreen` — `lib/features/auth/auth_screen.dart`

**Providers:** `authNotifierProvider` (`AuthNotifier`, `AuthState`)

**Repositories:** `AuthRepository` (wraps `AuthService` + writes `profiles` row on signup)

**Services:** `AuthService` — `lib/services/auth_service.dart`

**Models:** `UserModel`

**Flow:**
1. Login → `AuthRepository.login()` → `AuthService.login()` → Supabase signIn → `_fetchProfile()` → `UserModel`
2. Signup → `AuthService.signup()` → Supabase signUp → `profiles.upsert()` → `_fetchProfile()` → `UserModel`
3. On success:
   - `_email == Env.adminEmail` → `AppNavigator.toAdminShell(context)`
   - otherwise → `AppNavigator.toHome(context)`

**Important Files:**
- `lib/features/auth/auth_screen.dart`
- `lib/features/auth/providers/auth_notifier.dart`
- `lib/repositories/auth_repository.dart`
- `lib/services/auth_service.dart`

---

### Shell (Tab Container)

**Purpose:** Root scaffold for the customer app. Hosts 4 tabs via `IndexedStack` and owns the floating bottom nav bar.

**Screens:** `ShellScreen` — `lib/features/shell/shell_screen.dart`

**Widgets:** `CustomBottomNavBar` — `lib/core/widgets/custom_bottom_nav_bar.dart`

**Tabs:**
| Index | Screen | Icon |
|---|---|---|
| 0 | `HomeScreen` | home_rounded |
| 1 | `FavoritesScreen` | favorite_rounded |
| 2 | `CartScreen` | shopping_bag_rounded |
| 3 | `ProfileScreen` | person_rounded |

**Important note:** The bottom nav bar lives in `ShellScreen`, NOT in any tab screen. Never add `bottomNavigationBar` to a tab screen's `Scaffold`.

**Important Files:**
- `lib/features/shell/shell_screen.dart`
- `lib/core/widgets/custom_bottom_nav_bar.dart`

---

### Home

**Purpose:** Single-restaurant discovery screen. Full-bleed hero image with gradient overlay, restaurant meta strip, sticky category pills, popular dish cards (horizontal), full menu by category (MealListRow), ratings & reviews section, restaurant info section.

**Screens:** `HomeScreen` — `lib/features/home/home_screen.dart`

**Providers:** `homeNotifierProvider` (`HomeNotifier`, `HomeState`)

**Repositories:** `DishRepository` (`getPopularDishesByRestaurant`, `getAllDishesByRestaurant`), `RestaurantRepository` (`getFirstRestaurant`)

**Models:** `DishModel`, `RestaurantModel`, `CategoryModel`

**State:**
```dart
HomeState {
  restaurant: RestaurantModel?         // the single restaurant record
  popularDishes: List<DishModel>       // popular=true dishes (horizontal row)
  dishes: List<DishModel>              // filteredMenuDishes — active category or popular
  menuByCategory: Map<String, List<DishModel>>  // all dishes keyed by categoryId
  categories: List<CategoryModel>      // fetched from DB (replaces static list)
  selectedCategoryId: String?          // active filter (null = popular)
  isLoading: bool
  error: String?
}
// Getter: filteredMenuDishes → dishes (semantic alias)
```

**Methods:** `fetchRestaurantData()` (replaces `fetchAll()`), `selectCategory(String?)`, `toggleDishFavorite(int index)` (operates on popularDishes)

**Categories:** Now fetched from Supabase `categories` table in `fetchRestaurantData()`. `CategoryModel.fromJson` updated with defaults for missing `emoji`/`bg_color`.

**Screen design:**
- No `SafeArea` on body — hero image extends under status bar
- `Sliver 1`: Hero Stack 280px (`CachedNetworkImage` + dual gradient overlay + `Positioned` top bar with location tap → `toAddresses`, notification bell → `toNotifications` + `Positioned` bottom with restaurant name `GoogleFonts.bricolageGrotesque(fontSize:32,w800)` + cuisine chip)
- `Sliver 2`: Meta strip (rating · delivery time · Free delivery) + "See menu →" `TextButton` → `AppNavigator.toMenuAll`
- `Sliver 2b`: Search bar pill (50px) — `GestureDetector` → `AppNavigator.toMenuAll`
- `Sliver 2c`: Offer strip — dark `ac.primaryText` background, "The Stack Combo" promo + "Order" button → `AppNavigator.toSearch(query:'burger')`
- `Sliver 2d`: Active order banner — shown only when `activeOrderNotifierProvider.state.isNotEmpty`; displays count ("You have N active orders"), taps → `AppNavigator.toActiveOrders`
- `Sliver 3`: Sticky `SliverPersistentHeader(pinned:true)` using `_CategoryPillsDelegate` (52px, "Popular" + DB categories, `AnimatedContainer` selection)
- `Sliver 4`: Popular row — `SectionHeader` + horizontal `ListView` of `PopularMealCard` (hidden when category selected)
- `Sliver 5`: Full menu — `_buildAllMenuSlivers` (category headings + `MealListRow` per category) or filtered `SliverList`
- `Sliver 6`: Ratings & Reviews — "4.8" `GoogleFonts.bricolageGrotesque(fontSize:56)`, 3 hardcoded `_kReviews` as review cards
- `Sliver 7`: Restaurant Info — address, hours, phone in bordered `Container`
- `Sliver 8`: `SizedBox(height:104)` bottom padding

**Important Files:**
- `lib/features/home/home_screen.dart`
- `lib/features/home/menu_all_screen.dart` (`ConsumerStatefulWidget` — local `_selectedCategoryId` state, reuses `homeNotifierProvider` data)
- `lib/features/home/providers/home_notifier.dart`

---

### Restaurant Detail

**Purpose:** Shows restaurant info + full dish menu for a specific restaurant.

**Screens:** `RestaurantDetailScreen(restaurantId)` — `lib/features/restaurant/restaurant_detail_screen.dart`

**Providers:** `restaurantDetailProvider` — **family notifier** parameterised by `restaurantId`:
```dart
final restaurantDetailProvider = NotifierProvider.family<
    RestaurantDetailNotifier, RestaurantDetailState, String>(RestaurantDetailNotifier.new);

// Usage in widget:
ref.watch(restaurantDetailProvider(restaurantId))
```

**Repositories:** `RestaurantRepository`, `DishRepository`

**Models:** `RestaurantModel`, `DishModel`

**Important Files:**
- `lib/features/restaurant/restaurant_detail_screen.dart`
- `lib/features/restaurant/providers/restaurant_detail_notifier.dart`

---

### Cart

**Purpose:** Cart management — add/remove dishes, adjust quantities, apply promo codes, view totals.

**Screens:** `CartScreen` — `lib/features/cart/cart_screen.dart`

**Providers:** `cartNotifierProvider` (`CartNotifier`, `List<CartItemModel>`)

**Repositories:** `CartRepository` — LOCAL ONLY (SharedPreferences, not Supabase)

**Models:** `CartItemModel` (+ `selectedSize`, `addonNames`, `unitPriceRs` fields), `DishModel`

**State:** `List<CartItemModel>` (the state IS the cart items list)

**Computed getters on CartNotifier:**
- `subtotalRs` — sum of all item totals
- `deliveryFeeRs` — fixed Rs 50
- `totalRs` — subtotal + delivery - discount
- `itemCount` — total quantity of all items

**CartNotifier extra fields (not part of `List<CartItemModel>` state):**
- `selectedPaymentMethod` (String, default `"Visa"`) — set via `setPaymentMethod(method)`
- `deliveryAddress` (getter, returns `"Home — DHA Phase 5, Lahore"`)

**`addItem` signature:** `addItem(DishModel dish, {String? selectedSize, List<String> addonNames, int? unitPriceRs})` — quick-add buttons pass no extras (defaults to base price); `MealDetailView` passes selected size, addon names, and the computed `_unitPriceRs`. Same dish + same size → increments quantity. Same dish + different size → separate cart row.

**Promo codes (hardcoded for FYP demo):**
| Code | Discount |
|---|---|
| `CRAVE10` | Rs 100 |
| `FIRST50` | Rs 50 |
| `SAVE20` | Rs 200 |

**Important Files:**
- `lib/features/cart/cart_screen.dart`
- `lib/features/cart/providers/cart_notifier.dart`
- `lib/repositories/cart_repository.dart`

---

### Checkout

**Purpose:** Address selection, payment method selection, order placement, Stripe payment sheet trigger.

**Screens:** `CheckoutScreen` — `lib/features/checkout/checkout_screen.dart`

**Providers:**
- `checkoutNotifierProvider` (`CheckoutNotifier`, `CheckoutState`)
- `addressNotifierProvider` — reads saved addresses
- `paymentNotifierProvider` — reads saved payment methods
- `cartNotifierProvider` — reads cart items

**Repositories:** `OrderRepository`

**Services:** `StripeService` — `lib/services/stripe_service.dart` (uses `paymentSheetParameters` — Stripe v11 API)

**Models:** `AddressModel`, `PaymentMethodModel`, `OrderModel`

**Flow:**
1. Screen auto-selects default address and payment on load (via `addPostFrameCallback`)
2. User taps "Place Order" → Stripe payment sheet opens
3. Payment confirmed → `OrderRepository.placeOrder()` → `OrderModel`
4. Cart cleared → `AppNavigator.toOrderSuccess(order)`

**Important Files:**
- `lib/features/checkout/checkout_screen.dart`
- `lib/features/checkout/providers/checkout_notifier.dart`
- `lib/services/stripe_service.dart`

---

### Order Success

**Purpose:** Confirmation screen shown after successful order placement.

**Screens:** `OrderSuccessScreen(order)` — `lib/features/orders/order_success_screen.dart`

**Action:** "Track order" button → `AppNavigator.toTracking(orderId)`

**Important Files:** `lib/features/orders/order_success_screen.dart`

---

### Order Tracking

**Purpose:** Live order status display with ETA, courier info, and map.

**Screens:** `TrackingScreen(orderId)` — `lib/features/tracking/tracking_screen.dart`

**Providers:** `trackingNotifierProvider` (`TrackingNotifier`, `TrackingState`)

**Repositories:** `OrderRepository.trackOrder(orderId)`

**Polling:** `Timer.periodic(15 seconds)` — auto-stops when `status == delivered`

**ETA logic:** `placedAt + 40 minutes` window — shows "Arrives in 30-45 min" for first ~15 min, then counts down to "Arriving in ~N min", then "Arriving any moment"; "Delivered!" on delivery; "Order cancelled" on cancellation

**Courier contact:** Copies phone to clipboard; falls back to chat if no phone

**Models:** `OrderModel` (uses `courierName`, `courierPhone`, `courierLat`, `courierLng`, `placedAt`, `status`)

**Important Files:**
- `lib/features/tracking/tracking_screen.dart`
- `lib/features/tracking/providers/tracking_notifier.dart`

---

### Order History

**Purpose:** List of past orders with status badges and formatted dates.

**Screens:** `OrderHistoryScreen` — `lib/features/orders/order_history_screen.dart`

**Providers:** `orderHistoryNotifierProvider`

**Repositories:** `OrderRepository.getOrderHistory()`

**Dependencies:** `intl` package (`DateFormat`) for date formatting

**Important Files:**
- `lib/features/orders/order_history_screen.dart`
- `lib/features/orders/providers/order_history_notifier.dart`

---

### Profile

**Purpose:** User profile hub — stats, settings navigation, logout.

**Screens:** `ProfileScreen` — `lib/features/profile/profile_screen.dart`

**Providers:** `profileNotifierProvider` (`ProfileNotifier`, `ProfileState`)

**Sub-screens (all via AppNavigator):**

| Screen | File | Purpose |
|---|---|---|
| `EditProfileScreen` | `profile/edit/edit_profile_screen.dart` | Name/phone update |
| `AddressScreen` | `profile/address/address_screen.dart` | Saved addresses CRUD |
| `PaymentScreen` | `profile/payment/payment_screen.dart` | Payment methods CRUD |
| `NotificationsScreen` | `profile/notifications/notifications_screen.dart` | Push notification toggles |
| `InviteScreen` | `profile/invite/invite_screen.dart` | Referral code + sharing |
| `PreferencesScreen` | `profile/preferences/preferences_screen.dart` | Theme, compact mode, haptics |

**Providers per sub-feature:**
- `addressNotifierProvider` → `AddressNotifier`, `AddressState`
- `paymentNotifierProvider` → `PaymentNotifier`, `PaymentState`

**Repositories:** `ProfileRepository` (profiles, addresses, payment_methods)

**ProfileRepository methods:**
- `getProfile()`, `updateProfile(name, phone, avatarUrl?)`
- `getSavedAddresses()`, `addAddress()`, `setDefaultAddress()`, `deleteAddress()`
- `getPaymentMethods()`, `addPaymentMethod()`, `setDefaultPayment()`, `deletePaymentMethod()`

**Important Files:**
- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/providers/profile_notifier.dart`
- `lib/repositories/profile_repository.dart`

---

### Favorites

**Purpose:** Saved/favourite dishes and restaurants.

**Screens:** `FavoritesScreen` — `lib/features/favorites/favorites_screen.dart`

**Providers:** `favoritesNotifierProvider`

**Repositories:** `DishRepository.getFavoriteDishes()`, `RestaurantRepository.getFavoriteRestaurants()`

**Important Files:**
- `lib/features/favorites/favorites_screen.dart`
- `lib/features/favorites/providers/favorites_notifier.dart`

---

### Chat (AI Support)

**Purpose:** Gemini 1.5 Flash powered support chat. Answers order, payment, and delivery questions.

**Screens:** `ChatScreen` — `lib/features/chat/chat_screen.dart`

**Providers:** `chatNotifierProvider` (`ChatNotifier`, `ChatState`)

**Models:** `ChatMessageModel` (id, text, isFromUser, sentAt, quickReplies)

**AI Config:**
- Model: `gemini-1.5-flash`
- API key: `Env.geminiApiKey`
- System prompt: "crave. support assistant, Pakistan context, Rs currency"
- Quick replies on first message: `['Track my order', 'Cancel order', 'Payment issue', 'Other']`

**Important Files:**
- `lib/features/chat/chat_screen.dart`
- `lib/features/chat/providers/chat_notifier.dart`

---

### Admin Panel

The admin panel is **part of the same Flutter app** — no separate entry point or `main_admin.dart`. Routing is email-gated: login with `Env.adminEmail` goes to `AdminShellScreen`; any other email goes to the customer `ShellScreen`.

#### Shell — `AdminShellScreen`

**File:** `lib/features/admin/shell/admin_shell_screen.dart`

**Layout:** Responsive via `LayoutBuilder` — breakpoint at **600px**:

| Screen width | Layout |
|---|---|
| `< 600px` (phone) | `AppBar` + `BottomNavigationBar` + `IndexedStack` body |
| `≥ 600px` (tablet/desktop) | Fixed sidebar + top bar (original desktop layout) |

**Desktop layout (`≥ 600px`):**
```
Scaffold(body: Stack([
  Row(
    _AdminSidebar (248px, ac.navbarBackground bg)
    Column(
      _AdminTopBar (76px, white bg, border-bottom)
      Expanded(IndexedStack body, padding 28/24)
    )
  )
  NotificationsPanel overlay (when _showNotif)
  MealEditorDrawer overlay (SizedBox width:440, when editingDishId != null)
]))
```

**Mobile layout (`< 600px`):**
```
Scaffold(
  AppBar (ac.navbarBackground, title+subtitle, add/bell/logout actions)
  body: Stack([
    IndexedStack (Padding all:16)
    MealEditorDrawer overlay (Positioned.fill, when editingDishId != null)
  ])
  bottomNavigationBar: _BottomNavItem row
)
```

**`_AdminSidebar` (desktop only):**
- Brand: "S" circle + "Smoke & Stack" / "Merchant console"
- Nav items: Orders (receipt icon + newOrder badge count) | Menu (kitchen icon)
- Settings row (decorative)
- User card: avatar initial, displayName, logout button → `auth.signOut()` + `AppNavigator.toAuth()`

**`_AdminTopBar` (desktop only):**
- Title/subtitle (changes per tab; menu subtitle reads `adminDishesProvider` for counts)
- Decorative search pill
- "Add item" button (menu tab only) → `adminDishesProvider.notifier.openEditor('new')`
- "Store open" badge (`AppColors.statusDeliveredBg/Fg/storeOpenBorder`)
- Bell button (42×42) → toggles `_showNotif` → `NotificationsPanel` Stack overlay

**Mobile AppBar actions:**
- "Add item" Container button (menu tab only)
- Bell → `showModalBottomSheet` with `NotificationsPanel`
- Logout icon → `_logout()` method

**Mobile bottom nav (`_BottomNavItem`):**
- 2 items: Orders (with newOrder badge) + Menu
- Active: `cs.primary` tint bg + primary-colored icon/label
- Inactive: transparent bg + 55%-alpha white icon/label

**Tab state:** `int _tabIndex` — `0 = orders`, `1 = menu`; `String get _tab` derives `'orders'`/`'menu'`

**Data fetching:** `initState` uses `Future.microtask` → `fetchOrders()` + `fetchDishes()`

**MealEditorDrawer overlay:**
- Desktop: `Positioned(top:0, bottom:0, right:0, child: SizedBox(width:440, child: MealEditorDrawer(...)))`
- Mobile: `Positioned.fill(child: MealEditorDrawer(...))` — takes full screen width

---

#### Orders Screen — `AdminOrdersScreen`

**File:** `lib/features/admin/orders/admin_orders_screen.dart`

**Provider:** `adminOrdersProvider` (`AdminOrdersNotifier`, `AdminOrdersState`)

**Layout (mobile — single column):**
```
Column(
  _FilterTabsRow (Active | On the way | Delivered — horizontally scrollable)
  SizedBox(14)
  Expanded(_OrderListCard — full width)
)
```
Tapping a row calls `notifier.selectOrder(id)` then opens `showModalBottomSheet` (82% screen height) containing `_OrderDetailCard`.

**`_OrderListCard`:** `Container(clipBehavior: Clip.hardEdge)` wrapping `ListView.separated` (no desktop header row)

**`_OrderListRow` (mobile layout):**
```
Row(avatar 38×38, name+id/time, Spacer, Column(StatusPill, Rs amount), chevron_right)
```

**`_OrderDetailCard`:** Full `Column` (no outer Container — sheet's `shape`+`clipBehavior` handles rounding):
- Drag handle at top
- Order id + time header + `StatusPill`
- Customer avatar + name + address + phone icon
- `Expanded(SingleChildScrollView(items list + summary rows))`
- Status-based action buttons at bottom (each calls `Navigator.pop` after action):
  - `newOrder` → Reject (outlined) + "Accept & start cooking" (primary, 2/3 width)
  - `preparing` → "Out for Delivery" (primary, full width, delivery icon)
  - `on_the_way` → "Mark as Delivered" (green `#2DBE60`, full width, check icon)
  - `delivered` / `cancelled` → no button

**State:**
```dart
AdminOrdersState {
  orders: List<OrderModel>
  filterTab: String          // 'active' | 'ontheway' | 'delivered'
  selectedOrderId: String?
  isLoading: bool
  error: String?
}
// Extension getters:
filteredOrders  // orders filtered by filterTab
selectedOrder   // OrderModel? by selectedOrderId
```

**Notifier methods:** `fetchOrders()`, `setFilter(tab)`, `selectOrder(id)`, `acceptOrder(id)` (→ preparing), `rejectOrder(id)` (→ cancelled), `markOnTheWay(id)` (→ on_the_way), `markDelivered(id)` (→ delivered)

**Optimistic UI:** All status-change methods update `state.orders` immediately before the Supabase call. On error, rolls back via `fetchOrders()`.

**Auto-selection:** `fetchOrders()` auto-selects first active order if `selectedOrderId` is not yet set.

---

#### Menu Screen — `AdminMenuScreen` + `MealEditorDrawer`

**Files:**
- `lib/features/admin/menu/admin_menu_screen.dart`
- `lib/features/admin/menu/meal_editor_drawer.dart`

**Provider:** `adminDishesProvider` (`AdminDishesNotifier`, `AdminDishesState`)

**`AdminMenuScreen` layout:**
```
Column(
  _CategoryFilterRow (horizontal scroll: "All items" + categories from DB)
  SizedBox(20)
  Expanded(
    GridView.builder(crossAxisCount:2, crossAxisSpacing:16, mainAxisSpacing:16, mainAxisExtent:270)
  )
)
```

**Category filter pills:**
- Active: `ac.primaryText` bg, white text, white-18%-alpha count badge
- Inactive: white bg, `ac.secondaryText` text, `const Color(0xFFF0EBE3)` count badge
- Tap → `notifier.setCategory(id)`

**Grid items:** `MenuCard(dish, categoryName, onEdit, onDelete, onToggleAvailability)`
- `onEdit` → `notifier.openEditor(dish.id)`
- `onDelete` → `notifier.deleteDish(dish.id)` (optimistic)
- `onToggleAvailability` → `notifier.toggleAvailability(dish.id, !dish.isAvailable)` (optimistic)

**`MealEditorDrawer`:**

Rendered in `AdminShellScreen`'s `Stack` when `dishesState.editingDishId != null`. Width is determined by the parent `Positioned` — no fixed width inside the widget itself:
- Desktop: `Positioned(top:0, bottom:0, right:0, child: SizedBox(width:440, child: MealEditorDrawer(...)))`
- Mobile: `Positioned.fill(child: MealEditorDrawer(...))` — full screen width

`dishId == 'new'` → create mode (empty form, defaults to first category)
`dishId == UUID` → edit mode (pre-populated from `state.dishes`)

**Fields:** image area (168px, shows `dish.imageUrl` or camera placeholder), item name, price (Rs), calories (kcal), category chip selector, badge chip selector (`'' / 'Bestseller' / 'Spicy' / 'Chef pick' / 'Hot' / 'New'`), description, availability toggle

**Chip styling:** Active chip → `ac.softAccentSurface` bg, `cs.primary` border+text; Inactive → white bg, `ac.border` border, `ac.secondaryText` text

**Save:** builds `fields` map → `createDish(fields)` or `updateDish(dishId, fields)`. Both automatically close the editor on success (`clearEditingDishId: true` in notifier state update).

**State:**
```dart
AdminDishesState {
  dishes: List<DishModel>
  categories: List<({String id, String name})>  // fetched from 'categories' table
  selectedCategoryId: String  // 'all' or a UUID
  editingDishId: String?      // null=closed, 'new'=creating, UUID=editing
  isLoading: bool
  error: String?
}
// Extension getters:
displayedDishes   // filtered by selectedCategoryId
availableCount    // count of isAvailable dishes
restaurantId      // first dish's restaurantId (used when creating new dish)
```

**`fetchDishes()`** fetches both dishes (via `DishRepository`) and categories (directly via Supabase `_db.from('categories').select('id, name').order('name')`).

**Notifier methods:** `fetchDishes()`, `setCategory(id)`, `openEditor(dishId)`, `closeEditor()`, `toggleAvailability(id, val)`, `deleteDish(id)`, `createDish(fields)`, `updateDish(id, fields)`

---

#### Admin Widgets

All in `lib/features/admin/widgets/`:

| Widget | Purpose | File |
|---|---|---|
| `StatusPill` | Admin order status badge — exact JSX colors, dot + label | `status_pill.dart` |
| `AvailabilitySwitch` | Animated 42×24 toggle — green (`AppColors.success`) / gray (`AppColors.switchOff`) | `availability_switch.dart` |
| `MenuCard` | Dish card for menu grid — 130px image, tag badge, name, cat/kcal, price, availability row | `menu_card.dart` |
| `NotificationsPanel` | Bell dropdown overlay — static demo data, 380px wide | `notifications_panel.dart` |
| `StatusChip` | **Customer app** order status badge — uses Material color scheme (not admin-specific colors) | `status_chip.dart` |

`StatusPill` vs `StatusChip`:
- `StatusPill` — used in `AdminOrdersScreen`; exact JSX `statusMeta` colors from `AppColors`
- `StatusChip` — used in `OrderHistoryScreen` (customer app); uses `cs.primary`, `cs.tertiary`, `cs.error`

---

#### Admin Auth Routing

| Condition | Action |
|---|---|
| Login success, `email == Env.adminEmail` | `AppNavigator.toAdminShell(context)` |
| Login success, other email | `AppNavigator.toHome(context)` |
| Splash, session exists, `email == Env.adminEmail` | `AppNavigator.toAdminShell(context)` |
| Splash, session exists, other email | `AppNavigator.toHome(context)` |
| Admin logout (sidebar) | `Supabase.auth.signOut()` → `AppNavigator.toAuth(context)` |

**Required `.env` key:** `ADMIN_EMAIL=your-admin@email.com`

---

## State Management Map

### Customer App Providers

| Provider | Notifier | State Type | Location |
|---|---|---|---|
| `authNotifierProvider` | `AuthNotifier` | `AuthState` | `features/auth/providers/auth_notifier.dart` |
| `homeNotifierProvider` | `HomeNotifier` | `HomeState` | `features/home/providers/home_notifier.dart` |
| `cartNotifierProvider` | `CartNotifier` | `List<CartItemModel>` | `features/cart/providers/cart_notifier.dart` |
| `checkoutNotifierProvider` | `CheckoutNotifier` | `CheckoutState` | `features/checkout/providers/checkout_notifier.dart` |
| `addressNotifierProvider` | `AddressNotifier` | `AddressState` | `features/profile/address/providers/address_notifier.dart` |
| `paymentNotifierProvider` | `PaymentNotifier` | `PaymentState` | `features/profile/payment/providers/payment_notifier.dart` |
| `profileNotifierProvider` | `ProfileNotifier` | `ProfileState` | `features/profile/providers/profile_notifier.dart` |
| `restaurantDetailProvider` | `RestaurantDetailNotifier` (family) | `RestaurantDetailState` | `features/restaurant/providers/restaurant_detail_notifier.dart` |
| `trackingNotifierProvider` | `TrackingNotifier` | `TrackingState` | `features/tracking/providers/tracking_notifier.dart` |
| `activeOrderNotifierProvider` | `ActiveOrderNotifier` | `List<OrderModel>` | `features/orders/providers/active_order_notifier.dart` |
| `orderHistoryNotifierProvider` | `OrderHistoryNotifier` | order history state | `features/orders/providers/order_history_notifier.dart` |
| `favoritesNotifierProvider` | `FavoritesNotifier` | favorites state | `features/favorites/providers/favorites_notifier.dart` |
| `chatNotifierProvider` | `ChatNotifier` | `ChatState` | `features/chat/providers/chat_notifier.dart` |

### Utility Providers

| Provider | Type | Purpose | Location |
|---|---|---|---|
| `currentUserProvider` | `Provider<User?>` | Current Supabase user | `core/providers/auth_state_provider.dart` |
| `isLoggedInProvider` | `Provider<bool>` | Session existence check | `core/providers/auth_state_provider.dart` |
| `sharedPrefsProvider` | `Provider<SharedPreferences>` | Injected in `main.dart` | `core/providers/shared_prefs_provider.dart` |
| `dioProvider` | `Provider<Dio>` | HTTP client | `core/providers/dio_provider.dart` |

### Admin Providers

| Provider | Notifier | State Type | Location |
|---|---|---|---|
| `adminOrdersProvider` | `AdminOrdersNotifier` | `AdminOrdersState` | `features/admin/orders/admin_orders_notifier.dart` |
| `adminDishesProvider` | `AdminDishesNotifier` | `AdminDishesState` | `features/admin/dishes/admin_dishes_notifier.dart` |

### Family Notifier Pattern

`restaurantDetailProvider` is the only family notifier:

```dart
// Declaration
final restaurantDetailProvider = NotifierProvider.family<
    RestaurantDetailNotifier, RestaurantDetailState, String>(RestaurantDetailNotifier.new);

// In Notifier:
class RestaurantDetailNotifier extends FamilyNotifier<RestaurantDetailState, String> {
  RestaurantDetailState build(String restaurantId) { ... }
  Future<void> refresh() => _load(arg);  // arg == restaurantId
}

// In Widget:
ref.watch(restaurantDetailProvider(restaurantId))
ref.read(restaurantDetailProvider(restaurantId).notifier).refresh()
```

---

## Repository Registry

| Repository | Provider | Purpose | Backend |
|---|---|---|---|
| `AuthRepository` | `authRepositoryProvider` | Supabase auth + profile creation on signup | Supabase Auth + `profiles` table |
| `CartRepository` | `cartRepositoryProvider` | Cart persistence | Local — SharedPreferences only |
| `DishRepository` | `dishRepositoryProvider` | Dish CRUD + favorites + admin CRUD | Supabase `dishes` + `favorites` |
| `OrderRepository` | `orderRepositoryProvider` | Place order, history, tracking, status update | Supabase `orders` |
| `ProfileRepository` | `profileRepositoryProvider` | Profile + addresses + payment methods | Supabase `profiles`, `addresses`, `payment_methods` |
| `RestaurantRepository` | `restaurantRepositoryProvider` | Restaurant list + search + favorites | Supabase `restaurants` + `favorites` |

### Repository Method Reference

**DishRepository:**
- `getPopularDishes()` — top 20 dishes
- `getDishesByCategory(categoryId)` — filtered by category
- `getDishesByRestaurant(restaurantId)` — for restaurant detail screen
- `getPopularDishesByRestaurant(restaurantId)` — popular=true, limit 10 (home popular row)
- `getAllDishesByRestaurant(restaurantId)` — is_available=true, ordered by category_id (full menu)
- `getFavoriteDishes()` — joins `favorites` → `dishes`
- `toggleFavoriteDish(dishId)` — insert/delete in `favorites`
- `getAllDishes()` — all dishes ordered by `created_at desc` (admin)
- `toggleAvailability(dishId, newValue)` — admin availability toggle
- `deleteDish(dishId)` — admin delete
- `createDish(fields)` → `DishModel` — admin create
- `updateDish(dishId, fields)` → `DishModel` — admin update

**RestaurantRepository:**
- `getPopularRestaurants()` — top 20 by rating
- `searchRestaurants(query)` — ilike name search
- `getRestaurantById(id)` — single restaurant by ID
- `getFirstRestaurant()` — fetches the single restaurant (limit 1) for single-restaurant home
- `getFavoriteRestaurants()` — joins `favorites` → `restaurants`
- `toggleFavorite(restaurantId)` — insert/delete in `favorites`

**OrderRepository:**
- `placeOrder({items, deliveryAddress, paymentMethodId, deliveryFeeRs, discountRs})` → `OrderModel`
- `getOrderHistory()` — user's orders desc by placed_at
- `getActiveOrders()` — all non-delivered orders for current user (status IN new/preparing/on_the_way), ordered by placed_at desc; returns `List<OrderModel>`
- `trackOrder(orderId)` → `OrderModel`
- `updateStatus(orderId, status)` — admin use
- `getAllOrdersAdmin()` — all orders (admin, ordered by placed_at desc)
- `updateOrderStatus(orderId, status)` — admin status update

**ProfileRepository:**
- `getProfile()`, `updateProfile(name, phone, avatarUrl?)`
- `getSavedAddresses()`, `addAddress()`, `setDefaultAddress()`, `deleteAddress()`
- `getPaymentMethods()`, `addPaymentMethod()`, `setDefaultPayment()`, `deletePaymentMethod()`

---

## API Registry

### Supabase

| Field | Value |
|---|---|
| **Purpose** | Primary database, authentication, and storage backend |
| **Env vars** | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| **Init** | `main.dart` — `Supabase.initialize(url:, anonKey:)` |
| **Client** | `Supabase.instance.client` — used directly in all repositories |
| **Auth** | `_db.auth.signInWithPassword()` / `signUp()` / `signOut()` |
| **Database** | `_db.from('table').select()/.insert()/.update()/.delete()` |
| **RLS** | Enabled on all tables. `restaurants` and `dishes` are public-read. All user tables require `auth.uid() = user_id` |

### Stripe

| Field | Value |
|---|---|
| **Purpose** | Payment processing — shows native payment sheet |
| **Env vars** | `STRIPE_PUBLISHABLE_KEY`, `STRIPE_SECRET_KEY` |
| **Init** | `main.dart` — `Stripe.publishableKey = Env.stripePublishableKey` |
| **API version** | flutter_stripe v11 — uses `paymentSheetParameters` (not the old `paymentSheetData`) |
| **Files** | `lib/services/stripe_service.dart` |

### Gemini AI

| Field | Value |
|---|---|
| **Purpose** | AI-powered customer support chat |
| **Env var** | `GEMINI_API_KEY` |
| **Model** | `gemini-1.5-flash` |
| **Files** | `lib/features/chat/providers/chat_notifier.dart` |
| **Pattern** | `GenerativeModel` → `startChat()` → persistent `ChatSession` per provider instance |

### OpenStreetMap

| Field | Value |
|---|---|
| **Purpose** | Delivery location map in tracking screen |
| **API Key** | None required |
| **Package** | flutter_map ^7.0.2 + latlong2 ^0.9.1 |

---

## Environment Variables

All variables live in `.env` at the project root (never committed to git). Accessed only via `lib/core/constants/env.dart`:

```dart
class Env {
  static String get supabaseUrl          => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey      => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey         => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey      => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  static String get baseUrl              => dotenv.env['BASE_URL'] ?? '';
  static String get adminEmail           => dotenv.env['ADMIN_EMAIL'] ?? '';
}
```

**Required variables:**

| Variable | Where to get it | Notes |
|---|---|---|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API | e.g. `https://xxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Settings → API | `anon` / `public` key |
| `GEMINI_API_KEY` | Google AI Studio | Free tier available |
| `STRIPE_PUBLISHABLE_KEY` | Stripe Dashboard → Developers → API keys | `pk_test_...` for dev |
| `STRIPE_SECRET_KEY` | Stripe Dashboard → Developers → API keys | `sk_test_...` — used client-side (FYP only) |
| `BASE_URL` | Your API server (if any) | Optional — Dio base URL |
| `ADMIN_EMAIL` | Your admin account email | Routes login to AdminShellScreen |

**Template** (`.env.example`, safe to commit):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY=your-gemini-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key
STRIPE_SECRET_KEY=sk_test_your-key
BASE_URL=https://your-api.com
ADMIN_EMAIL=admin@yourrestaurant.com
```

---

## Database Schema Summary

See full SQL in `supabase/schema.sql`. Run it once in Supabase Dashboard → SQL Editor.

| Table | Purpose | Key columns |
|---|---|---|
| `restaurants` | Restaurant listings | `id`, `name`, `cuisine_tags[]`, `rating`, `delivery_time_min`, `min_order_rs` |
| `dishes` | Menu items | `id`, `name`, `restaurant_id`, `restaurant_name`, `price_rs`, `calories`, `tag`, `category_id`, `description`, `is_available`, `rating`, `prep_time_min`, `popular` |
| `categories` | Menu categories | `id`, `name` (fetched by admin panel for filter pills and MealEditor) |
| `profiles` | Extended user data (linked to auth.users) | `id`, `full_name`, `email`, `phone`, `avatar_url`, `total_orders`, `points` |
| `addresses` | Saved delivery addresses per user | `id`, `user_id`, `label`, `full_address`, `lat`, `lng`, `is_default` |
| `payment_methods` | Saved payment methods per user | `id`, `user_id`, `type` (card/cash/wallet), `label`, `last_four`, `is_default` |
| `orders` | Order records | `id`, `user_id`, `items` (jsonb), `status`, `placed_at`, `subtotal_rs`, `total_rs`, courier fields |
| `favorites` | User favourites (dishes + restaurants) | `id`, `user_id`, `dish_id`, `restaurant_id`, `type` |

**RLS summary:**
- `restaurants`, `dishes` — public SELECT (anyone can read)
- All other tables — owner-only (`auth.uid() = user_id` or `id`)

**Auto-trigger:** `handle_new_user()` creates a `profiles` row on every new Supabase Auth signup.

**OrderStatus enum values (in code):** `newOrder` | `preparing` | `onTheWay` | `delivered` | `cancelled`

**PaymentType enum values:** `card` | `cash` | `wallet`

---

## Reusable Widgets

All in `lib/core/widgets/`.

| Widget | Purpose | File |
|---|---|---|
| `DishCard` | Dish card with padding-all-around, floating 18px-radius image, favorite toggle, add-to-cart | `dish_card.dart` |
| `DishCardSkeleton` | Shimmer loading placeholder for DishCard | `skeleton_loader.dart` |
| `RestaurantCard` | Restaurant listing card with cuisine tags, rating, ETA | `restaurant_card.dart` |
| `RestaurantCardSkeleton` | Shimmer loading placeholder for RestaurantCard | `restaurant_card.dart` |
| `CategoryChip` | Tappable category filter chip with emoji icon | `category_chip.dart` |
| `CustomBottomNavBar` | Floating dark pill nav bar (used only in ShellScreen) | `custom_bottom_nav_bar.dart` |
| `CustomSearchBar` | Styled search input field | `custom_search_bar.dart` |
| `CustomTextField` | Reusable text form field | `custom_text_field.dart` |
| `GradientButton` | Primary gradient button with loading spinner | `gradient_button.dart` |
| `PrimaryButton` | Solid primary colour button | `primary_button.dart` |
| `OutlinedPillButton` | Pill-shaped outlined button | `outlined_pill_button.dart` |
| `QuantityControl` | +/- quantity control with count display | `quantity_control.dart` |
| `PriceRow` | Label + price display row | `price_row.dart` |
| `SectionHeader` | Section title with optional "See all" action | `section_header.dart` |
| `EmptyStateWidget` | Empty state with icon, title, subtitle | `empty_state_widget.dart` |
| `ErrorStateWidget` | Error message with retry callback | `error_state_widget.dart` |
| `SkeletonBox` | Shimmer placeholder box (configurable size) | `skeleton_loader.dart` |
| `MealListRow` | Horizontal dish row (72×72 image, name/desc/⭐ rating·time/price, add button) | `meal_list_row.dart` |
| `PopularMealCard` | 160×240 dish card (image stack+badge, name, ⭐ rating·kcal, price, add circle) | `popular_meal_card.dart` |

**Admin-only widgets** in `lib/features/admin/widgets/`:

| Widget | Purpose | Used by |
|---|---|---|
| `StatusPill` | Admin order status badge (exact JSX colors, dot + label) | `AdminOrdersScreen` |
| `AvailabilitySwitch` | Animated 42×24 on/off toggle | `MenuCard`, `MealEditorDrawer` |
| `MenuCard` | Full dish card for 3-col grid (image, tag overlay, details, toggle) | `AdminMenuScreen` |
| `NotificationsPanel` | Bell overlay (380px, static demo data) | `AdminShellScreen` |
| `StatusChip` | Customer app order status badge (Material colors) | `OrderHistoryScreen` |

---

## Known Limitations

1. **`.env` credentials required** — placeholder values cause runtime failures; the app cannot function without real Supabase/Gemini/Stripe keys. Add `ADMIN_EMAIL` to use the admin panel.

2. **Google OAuth not implemented** — the "Continue with Google" button navigates directly to `ShellScreen` as a dev shortcut. Full OAuth via Supabase would require deep link handling.

3. **Menu categories now live (customer home)** — categories are fetched from the Supabase `categories` table in `fetchRestaurantData()`. `CategoryModel.fromJson` uses null-safe defaults (`emoji='🍽'`, `bgColor=0xFFFFE8DC`) for missing columns.

4. **No push notifications** — order status changes are shown only when the user is on the tracking screen (polling) or refreshes manually.

5. **Stripe client-side only** — `STRIPE_SECRET_KEY` is used in `stripe_service.dart` directly in the app (acceptable for FYP demo; production requires a backend API to create `PaymentIntent`).

6. **No real geocoding** — address coordinates (`lat`, `lng`) must be entered manually or default to `0, 0`. No address-to-coordinate lookup is implemented.

7. **Cart is local-only** — cart data lives in `SharedPreferences` via `CartRepository`. It is not synced to Supabase (no server-side cart).

8. **No real-time updates** — tracking polls every 15 seconds. Admin order list requires manual refresh. No Supabase realtime subscriptions used.

9. **`BASE_URL` env var** — defined in `Env` and `dio_provider.dart` but Dio is not used for the main data flow (Supabase client handles all DB calls).

10. **Single restaurant** — the app is designed for exactly one restaurant. The admin panel restaurant name ("Smoke & Stack") is hardcoded. `restaurant_id` for new dishes is inferred from the first existing dish in `adminDishesProvider.state.restaurantId`.

11. **Image upload (MealEditor)** — fully implemented. `MealEditorDrawer` uses `image_picker ^1.1.2` to pick from device gallery, uploads binary to Supabase Storage bucket `dish-images` (public), and stores the CDN URL in `dish.image_url`. Android: `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` permissions in `AndroidManifest.xml`. iOS: `NSPhotoLibraryUsageDescription` in `Info.plist`.

12. **Admin panel is responsive** — `AdminShellScreen` uses `LayoutBuilder` to switch at 600px: phone gets AppBar + bottom nav, tablet/desktop gets the full sidebar layout.

---

## Common Tasks

### Add a New Screen

1. Create `lib/features/<feature>/<screen_name>_screen.dart`
2. Add navigation method to `lib/core/navigation/app_navigator.dart`:
   ```dart
   static void toMyScreen(BuildContext context) {
     Navigator.push(context, MaterialPageRoute(builder: (_) => const MyScreen()));
   }
   ```
3. Add import at top of `app_navigator.dart`
4. Call `AppNavigator.toMyScreen(context)` from the relevant screen

### Add a New Provider / Notifier

1. Create `lib/features/<feature>/providers/<feature>_notifier.dart`
2. Define your state class with `copyWith`
3. Define your notifier extending `Notifier<MyState>`
4. Register at bottom of file:
   ```dart
   final myNotifierProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
   ```
5. In your widget, use `ConsumerWidget` or `ConsumerStatefulWidget` and `ref.watch`/`ref.read`

### Add a New Repository

1. Create `lib/repositories/<name>_repository.dart`
2. Add `final _db = Supabase.instance.client;` for DB access
3. Register at bottom:
   ```dart
   final myRepositoryProvider = Provider<MyRepository>((_) => MyRepository());
   ```
4. Read in notifiers via `ref.read(myRepositoryProvider)`

### Add a New Model

1. Create `lib/models/<name>_model.dart`
2. Implement `fromJson(Map<String, dynamic>)`, `toJson()`, `copyWith()`
3. Add matching Supabase table in `supabase/schema.sql` with RLS policy

### Add a New Supabase Table

1. Add the `CREATE TABLE` statement to `supabase/schema.sql`
2. Add `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
3. Add appropriate `CREATE POLICY` statements
4. Run the new SQL in Supabase Dashboard → SQL Editor

### Add a New API Integration

1. Add env var to `.env` and `.env.example`
2. Add getter to `lib/core/constants/env.dart`
3. Create service in `lib/services/<name>_service.dart`
4. Create a `Provider<T>` for the service if needed

### Modify the Theme

1. Edit `lib/theme/app_theme.dart` only
2. To add a new `AppThemeColors` token: add field to the class, add to both `lightTheme()` and `darkTheme()` calls, add to `copyWith()` and `lerp()`
3. Never add theme logic to individual screen files
4. New color constants with no `AppThemeColors` equivalent → add to `AppColors` in `app_colors.dart`

---

## AI Instructions

When an AI agent works on this project:

1. **Read this document first.** It contains the exact file paths, patterns, and constraints you need.

2. **Read only the files listed for the affected feature.** The Feature Registry and State Management Map tell you exactly which files to open. Do not scan the entire codebase.

3. **Preserve these non-negotiable constraints:**
   - Only `Provider<T>` and `NotifierProvider<T, S>` — never FutureProvider, StreamProvider, StateProvider, AsyncNotifierProvider
   - Standard `Navigator` only — never go_router
   - `AppThemeColors` tokens (`ac.xxx`) — never hardcode `Color(0xFF...)` in widget files
   - New color constants → `AppColors` in `app_colors.dart` — never inline in widgets
   - `AppDimensions` — never hardcode pixel values
   - All secrets via `Env.xxx` — never hardcode in source files
   - Dart 3 wildcard `(_, _)` — never `(_, _2)` or `(_, __)`
   - `activeThumbColor` not `activeColor` on `SwitchListTile`
   - `SegmentedButton<T>` not deprecated `RadioListTile` grouping
   - `DropdownMenu<T>` not deprecated `DropdownButtonFormField`

4. **Widget type rules:**
   - Any widget that uses `ref` must be `ConsumerWidget` or `ConsumerStatefulWidget`
   - Never call Riverpod `ref` inside a plain `StatelessWidget` or `StatefulWidget`

5. **After every code change, run `flutter analyze --no-pub` and fix all issues before reporting done.**

6. **Navigation is centralised.** Never call `Navigator.push(...)` in a screen directly. Always use `AppNavigator` (both customer and admin screens use `AppNavigator`).

7. **The bottom nav bar is in `ShellScreen`, not in any tab screen.** Never add `bottomNavigationBar` to `HomeScreen`, `FavoritesScreen`, `CartScreen`, or `ProfileScreen`.

8. **Admin and customer are the same app.** The routing split happens in `AuthScreen` and `SplashScreen` based on `Env.adminEmail`. Do not create a separate `main_admin.dart`.

9. **`MealEditorDrawer` is rendered in `AdminShellScreen`'s Stack**, not as a separate route. It is driven by `adminDishesProvider.editingDishId` — set via `openEditor(id)` / `closeEditor()` on the notifier.

---

## Last Updated

| Field | Value |
|---|---|
| **Date** | 2026-06-16 |
| **Flutter Analyze** | ✅ No issues (`flutter analyze --no-pub`) |
| **Recent Changes** | [Profile stats fix] (1) `profile_repository.dart`: replaced `Future.wait<dynamic>([...])` with sequential typed `await` calls for profile, orders, and favorites queries — eliminates type-coercion failures that silently made the whole fetch throw. (2) `profile_notifier.dart`: `updateProfile()`, `updateAvatar()`, and `_uploadAvatar()` all now call `fetchProfile()` after the update instead of `state = ProfileState(user: repositoryResult)` — the repository's `updateProfile` returns the raw profile row (which has 0 for live stats), so using `fetchProfile()` preserves the live counts. (3) `profile_screen.dart`: added `RefreshIndicator` wrapping `SingleChildScrollView` — user can pull down to refresh stats after placing orders or adding favorites. [Previous session] | [Order status progression + ETA] (1) `admin_orders_notifier.dart`: added `markOnTheWay(id)` (→ on_the_way) and `markDelivered(id)` (→ delivered) — both optimistic, roll back via `fetchOrders()` on error. (2) `admin_orders_screen.dart`: `_OrderDetailCard` action buttons are now status-aware — `newOrder`: Reject + Accept (existing); `preparing`: "Out for Delivery" full-width primary button; `on_the_way`: "Mark as Delivered" full-width green button; `delivered`/`cancelled`: no button. `showDetail` passes two new callbacks `onMarkOnTheWay` and `onMarkDelivered`. (3) `tracking_screen.dart`: `_computeEta` updated — uses `placedAt + 40 min` window; shows "Arrives in 30-45 min" for first ~15 min, then counts down, then "Arriving any moment"; handles `cancelled` status. [Active Orders + Tracking fixes] (1) `order_repository.dart`: `getActiveOrder()` → `getActiveOrders()` returning `List<OrderModel>`; uses `.inFilter('status', ['new','preparing','on_the_way'])` list query (removes `.maybeSingle()` 406 error). (2) `active_order_notifier.dart` (NEW): `NotifierProvider<ActiveOrderNotifier, List<OrderModel>>`; `build()` returns `[]` and fires `Future.microtask(refresh)`; `refresh()` fetches and sets state. (3) `active_orders_screen.dart` (NEW): `ConsumerWidget` listing all active orders with `RefreshIndicator`; `_ActiveOrderCard` taps to `AppNavigator.toTracking`. (4) `app_navigator.dart`: added `toActiveOrders` (method 21). (5) `home_screen.dart`: `_HomeScreenState` now mixes in `RouteAware`; `initState` fires `Future.microtask(() => refresh())`; `didChangeDependencies` subscribes to `routeObserver`; `didPopNext` calls `refresh()`; banner now shows count and navigates to `toActiveOrders`. (6) `main.dart`: added global `RouteObserver<ModalRoute<void>> routeObserver`; wired to `MaterialApp.navigatorObservers`. (7) `tracking_notifier.dart` (REWRITTEN): `ref.onDispose` moved to `build()` (fixes Riverpod 2.x Bad-state error); old timer cancelled before new one (fixes timer accumulation); state reset to loading on `startTracking` (fixes stale loading spinner); `_trackedOrderId` guard prevents stale async responses. (8) `tracking_screen.dart`: added error state UI (icon + message + Retry button) between spinner and map. (9) `dish_model.dart`: JSONB cast `as int?` → `(as num?)?.toInt()`. (10) `cart_item_model.dart`: JSONB cast `as int` → `(as num).toInt()`. [Phase 4.3 fix] Wired `MealDetailView` customisation through to cart: (1) `CartItemModel` — added `unitPriceRs` field (defaults to `dish.priceRs`); `totalPriceRs = unitPriceRs × quantity`; `fromJson`/`toJson`/`copyWith` updated; removed `const` from constructor. (2) `CartRepository.addItem` — extended with `selectedSize`, `addonNames`, `unitPriceRs` optional params; dedup now matches on `dish.id + selectedSize` so different sizes are separate rows. (3) `CartNotifier.addItem` — extended with same optional params, passes through to repo. (4) `MealDetailView._addToCart` — now passes `selectedSize: _selectedSize`, `addonNames: _selectedAddons.toList()`, `unitPriceRs: _unitPriceRs`. (5) `CartScreen` — cart item subtitle shows selected size + add-on count (e.g. "Double · 2 extras") instead of restaurantName when size is set. [Verification] End-to-end JSX design verification pass: (1) `MealListRow` — added ⭐ rating · X min row below description; replaced hardcoded `12` → `AppDimensions.radiusSm` for ClipRRect/fallback; replaced `SizedBox(height:4)` → `AppDimensions.xs`. (2) `PopularMealCard` — added ⭐ rating · kcal meta row between name and price. (3) `HomeScreen` — added Sliver 2b (search bar pill, 50px, taps → `toMenuAll`) and Sliver 2c (offer strip, dark ink bg, "The Stack Combo" + tappable "Order" button → `toMenuAll`); notifications bell icon wired to `AppNavigator.toNotifications`; fixed `SizedBox(height:6)` → `AppDimensions.xs`, `SizedBox(width:12)` → `AppDimensions.radiusSm`. (4) `MealDetailView` — added `Rs price` to title row (right side); moved tag badge to below-name position. (5) `AI_PROJECT_CONTEXT.md` — AppNavigator count 18→20, added `toCategoryGrid` to methods table, `toMenuAll` description updated, `menu_all_screen.dart`/`category_grid_screen.dart` added to folder tree, HomeScreen sliver list updated, widget descriptions updated. [Phase 7] Regression verified: `dart analyze lib/` zero issues, no old enum/field refs, no raw `Navigator.push` in screens, ShellScreen 4 tabs unchanged, admin screens unaffected, `flutter build apk --debug` ✅. [Phase 5.5] `CartScreen` updated: delivery address row (`notifier.deliveryAddress` + "Change" → `AppNavigator.toAddresses`), collapsed promo banner (`_promoExpanded` toggle, expands to show text field), "Pay with" chips (Visa/Apple Pay/Wallet, local `_paymentMethod` state synced to `notifier.selectedPaymentMethod`), button text "Proceed to checkout" → "Place order". Hardcoded `Color(0xFF2DBE60)` → `ac.success`. [Phase 5.4] `FavoritesScreen` redesigned: header "Your favorites" → "Saved & loved"; filter row: All/Dishes/Kitchens + new "Lists" pill; GridView of DishCard → `_FavoriteDishRow` vertical list (image + name/desc/price + ❤ remove + 🛒 add-to-cart); `_KitchenRow` replaces `RestaurantCard`; Lists tab shows "No lists yet" empty state; `isEmpty` via Dart 3 switch expression; `_FilterChip` → `_FilterPill` using `ac.xxx`/`AppDimensions` tokens. [Phase 5.3] `CategoryGridScreen` created: `ConsumerStatefulWidget`, split-pane `Row` layout — left 80px category rail (`AnimatedContainer` with primary left-border + tinted bg, emoji + name), `VerticalDivider`, right `Expanded` `GridView.builder(crossAxisCount:2, childAspectRatio:0.70)` of `PopularMealCard`; defaults to first category without `setState`; loading/error states. `AppNavigator.toCategoryGrid` added (method 20). Phase 6 AppNavigator additions now complete. [Phase 5.2] `MenuAllScreen` fully implemented: `ConsumerStatefulWidget` with local `_selectedCategoryId`; AppBar + back arrow; horizontal `AnimatedContainer` category pills ("All" + DB categories, 52px row); `CustomScrollView` with `SliverFillRemaining` for loading/error; `_buildAllSlivers` (category emoji+name headings + `MealListRow` per category) for all view; filtered `SliverList` for single category; `showMealDetail` + `cartNotifier.addItem` wired. [Phase 5.1] `HomeScreen` completely redesigned: full-bleed 280px hero with gradient overlay, top bar, restaurant name (Bricolage Grotesque 32px), meta strip, sticky `SliverPersistentHeader` category pills (`_CategoryPillsDelegate`, 52px), popular cards horizontal row (`PopularMealCard`), full menu slivers by category (`MealListRow`), ratings & reviews (3 mock, 4.8 avg), restaurant info (address/hours/phone). `SafeArea` removed. `AppNavigator.toMenuAll` added → `MenuAllScreen` stub created. (1) `HomeScreen`: `SafeArea(bottom:false)` moved to wrap the entire `Scaffold.body` — was only on first sliver, causing status-bar overlap. (2) `supabase/schema.sql`: full rewrite — now starts with `drop table if exists … cascade` for all tables, seed dishes include `image_url` (30 Unsplash CDN URLs), storage bucket `dish-images` created with public-read + auth-write policies. (3) `MealEditorDrawer`: `image_picker ^1.1.2` wired up — gallery pick → Supabase Storage binary upload → CDN URL stored in `image_url`. (4) `pubspec.yaml`: `image_picker: ^1.1.2` added. (5) Android `READ_MEDIA_IMAGES` permission + iOS `NSPhotoLibraryUsageDescription` added. (10) [Phase 4] New widgets: `MealListRow` (core/widgets), `PopularMealCard` (core/widgets), `MealDetailView` + `showMealDetail()` (features/home/widgets). MealDetailView: ConsumerStatefulWidget, DraggableScrollableSheet, size selector (Single/Double/Triple with price), spice level chips, addon checkboxes, sticky add-to-cart bar. (9) [Phase 3] `home_notifier.dart`: full rewrite — removed static categories + `restaurants` list; added `restaurant`, `popularDishes`, `menuByCategory` to `HomeState`; `fetchAll` → `fetchRestaurantData()`; categories now fetched from DB. `favorites_notifier.dart`: `FavoritesFilter.restaurants` → `.kitchens`, added `.lists`; `FavoritesState` gains `lists` field. `cart_notifier.dart`: added `selectedPaymentMethod`, `deliveryAddress`, `setPaymentMethod()`. `category_model.dart`: `fromJson` now uses defaults for missing `emoji`/`bg_color`. `favorites_screen.dart` + `home_screen.dart`: updated to compile with new state shapes. (8) [Phase 2] `dish_repository.dart`: added `getPopularDishesByRestaurant(restaurantId)` (popular=true, limit 10) and `getAllDishesByRestaurant(restaurantId)` (available only, ordered by category_id). `restaurant_repository.dart`: added `getFirstRestaurant()` — fetches the single restaurant row (limit 1). (7) [Phase 1] `cart_item_model.dart`: added `selectedSize` (String?) and `addonNames` (List\<String\>) fields with `fromJson`/`toJson`/`copyWith` support — enables MealDetailView size+addon selections to be stored in cart. (6) [Phase 0] `app_theme.dart`: light `ac.background` updated from `#FFF0E6` to `#FFF8F3` (new JSX `C.bg` token). Typography (Bricolage Grotesque + DM Sans) and `creamSurface (#FCEFE3)` were already correct; `ac.primaryText (#1A1612)` serves as `C.ink`. `google_fonts ^8.1.0` already in pubspec. |
| **Remaining Blockers** | `.env` credentials required (Supabase, Gemini, Stripe, `ADMIN_EMAIL`) |
