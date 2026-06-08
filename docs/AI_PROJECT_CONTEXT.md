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
| **Completion** | 99.2% (126/127 in-scope TODOs — only `.env` credentials remain) |
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
└──────────────┬────────────────────────────────┬────────────┘
               │ watches state                  │ calls method
               ▼                                ▼
┌──────────────────────────────────────────────────────────── ┐
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
- `AppThemeColors` tokens via `ac.xxx` — never hardcode `Color(0xFF...)`
- `AppDimensions.md` for spacing — never hardcode pixel values
- All secrets via `Env.xxx` from `.env` — never hardcode
- `SegmentedButton<T>` not deprecated `RadioListTile` group patterns
- `DropdownMenu<T>` not deprecated `DropdownButtonFormField`
- `activeThumbColor` not deprecated `activeColor` on `SwitchListTile`

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
│   │   │   ├── app_navigator.dart     ← AppNavigator (17 static methods, customer app)
│   │   │   ├── admin_navigator.dart   ← AdminNavigator (5 static methods, admin app)
│   │   │   └── app_routes.dart        ← route name constants
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
│   │   ├── admin/                     ← admin panel (separate app via main_admin.dart)
│   │   │   ├── auth/
│   │   │   │   ├── admin_auth_notifier.dart
│   │   │   │   └── admin_login_screen.dart
│   │   │   ├── categories/
│   │   │   │   ├── admin_categories_notifier.dart
│   │   │   │   ├── category_form_screen.dart
│   │   │   │   └── category_list_screen.dart
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_notifier.dart
│   │   │   │   └── dashboard_screen.dart
│   │   │   ├── dishes/
│   │   │   │   ├── admin_dishes_notifier.dart
│   │   │   │   ├── dish_form_screen.dart
│   │   │   │   └── dish_list_screen.dart
│   │   │   ├── orders/
│   │   │   │   ├── admin_orders_notifier.dart
│   │   │   │   ├── order_detail_screen.dart
│   │   │   │   └── order_list_screen.dart
│   │   │   ├── shell/
│   │   │   │   └── admin_shell_screen.dart   ← responsive shell (Rail/Bar)
│   │   │   └── widgets/
│   │   │       ├── admin_stat_card.dart
│   │   │       ├── color_picker_row.dart
│   │   │       └── status_chip.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── auth_screen.dart              ← login + signup with email/password
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
│   │   │   ├── home_screen.dart              ← tab 0 of ShellScreen
│   │   │   └── providers/home_notifier.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── data/onboarding_data.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/pageview_design.dart
│   │   │
│   │   ├── orders/
│   │   │   ├── order_history_screen.dart
│   │   │   ├── order_success_screen.dart
│   │   │   └── providers/order_history_notifier.dart
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
│   │   │   └── splash_screen.dart            ← app entry, auth routing
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
│   │   ├── dish_repository.dart      ← Supabase dishes table
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
│   ├── main.dart                     ← customer app entry point
│   └── main_admin.dart               ← admin panel entry point
│
├── supabase/
│   └── schema.sql                    ← full DB schema + RLS + seed data
├── .env                              ← secrets (NOT in git)
├── .env.example                      ← template (safe to commit)
└── pubspec.yaml
```

---

## Navigation Map

### App Entry Points

| Entry | File | Description |
|---|---|---|
| Customer app | `lib/main.dart` | `runApp(CraveApp())` → `SplashScreen` |
| Admin panel | `lib/main_admin.dart` | `runApp(AdminApp())` → `AdminLoginScreen` |

### Customer App — Authentication Flow

```
SplashScreen (2s delay)
  │
  ├── onboarding NOT seen ──────────────► OnboardingScreen
  │                                              │
  │                                              └─ "Get Started" ──► AuthScreen
  │
  ├── onboarding seen, NO session ──────► AuthScreen
  │                                              │
  │                                              └─ login/signup ──► ShellScreen
  │
  └── onboarding seen, session EXISTS ──► ShellScreen
```

### Customer App — Main Navigation

`ShellScreen` owns the bottom nav bar (`CustomBottomNavBar`) and hosts 5 tabs via `IndexedStack`:

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

### AppNavigator Methods (all 17)

| Method | Behaviour | Destination |
|---|---|---|
| `toOnboarding` | `pushReplacement` | OnboardingScreen |
| `toAuth` | `pushReplacement` | AuthScreen |
| `toHome` | `pushAndRemoveUntil` (clears stack) | ShellScreen |
| `toCheckout` | `push` | CheckoutScreen |
| `toTracking(orderId)` | `push` | TrackingScreen |
| `toRestaurantDetail(restaurantId)` | `push` | RestaurantDetailScreen |
| `toCart` | `push` | CartScreen |
| `toChat` | `push` | ChatScreen |
| `toOrderSuccess(order)` | `pushReplacement` | OrderSuccessScreen |
| `toOrderHistory` | `push` | OrderHistoryScreen |
| `toAddresses` | `push` | AddressScreen |
| `toPaymentMethods` | `push` | PaymentScreen |
| `toEditProfile` | `push` | EditProfileScreen |
| `toNotifications` | `push` | NotificationsScreen |
| `toInvite` | `push` | InviteScreen |
| `toPreferences` | `push` | PreferencesScreen |
| `back` | `Navigator.pop` | — |

### Admin Navigation Flow

```
AdminApp (main_admin.dart)
  └── AdminLoginScreen
        └── AdminShellScreen (responsive shell)
              ├── DashboardScreen
              ├── OrderListScreen → OrderDetailScreen
              ├── DishListScreen  → DishFormScreen (add/edit)
              └── CategoryListScreen → CategoryFormScreen (add/edit)
```

### AdminNavigator Methods

| Method | Destination |
|---|---|
| `toAdminLogin` | AdminLoginScreen (clears stack) |
| `toAdminDashboard` | AdminShellScreen (clears stack) |
| `toAdminDishForm({dish?})` | DishFormScreen (null = create, non-null = edit) |
| `toCategoryForm({category?})` | CategoryFormScreen |
| `toOrderDetail(orderId)` | OrderDetailScreen |
| `back` | `Navigator.pop` |

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
| `ac.background` | `#FFF0E6` (warm cream) | `#1A1714` | Scaffold backgrounds |
| `ac.surface` | `#FFFFFF` (pure white) | `#1C1917` | Cards, input fills |
| `ac.creamSurface` | `#FCEEE3` | `#26211D` | Stats bar, image fallbacks, category chips |
| `ac.softAccentSurface` | `#FFE8DC` | `#33261E` | Light orange surfaces |
| `ac.primaryText` | `#1A1612` (near black) | `#FFF6EF` | Body text, DishCard tag badge |
| `ac.secondaryText` | `#5A4F47` | `#D3C7BE` | Subtitles |
| `ac.mutedText` | `#8C7E73` | `#A89B91` | Hints, placeholders |
| `ac.border` | `#EFE7DF` | `#3B332E` | Card/container borders |
| `ac.navbarBackground` | `#1A1612` (dark) | `#1C1917` | Floating pill nav bar |
| `ac.inputFill` | `#FFFFFF` (pure white) | `#1C1917` | TextField fill |
| `ac.success` | `#2DBE60` | `#4ADE80` | Order status: delivered |
| `ac.warning` | `#FFB400` | `#FBBF24` | Warnings |
| `ac.primaryGradientStart` | `#EF9F27` | `#EF9F27` | Gradient start (orange) |
| `ac.primaryGradientEnd` | `#D85A30` | `#D85A30` | Gradient end (red-orange) |
| `ac.cardShadow` | 4% black, 12px blur | 10% black | `boxShadow` on cards |
| `ac.buttonShadow` | 32% orange glow | 40% orange | `GradientButton` shadow |
| `ac.navbarShadow` | 25% black, 40px blur | 38% black | Bottom nav shadow |

**`AppColors` static constants** (for use outside widgets):
```dart
AppColors.primaryGradientStart  // Color(0xFFEF9F27)
AppColors.primaryGradientEnd    // Color(0xFFD85A30)
AppColors.success               // Color(0xFF2DBE60)
AppColors.warning               // Color(0xFFFFB400)
AppGradients.primary            // LinearGradient(primaryGradientStart → primaryGradientEnd)
```

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

**Logic:** After 2-second delay: `!onboardingSeen` → Onboarding | `session == null` → Auth | else → ShellScreen

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

**Purpose:** Email/password login and account creation. Wired to Supabase Auth.

**Screens:** `AuthScreen` — `lib/features/auth/auth_screen.dart`

**Providers:** `authNotifierProvider` (`AuthNotifier`, `AuthState`)

**Repositories:** `AuthRepository` (wraps `AuthService` + writes `profiles` row on signup)

**Services:** `AuthService` — `lib/services/auth_service.dart`

**Models:** `UserModel`

**Flow:**
1. Login → `AuthRepository.login()` → `AuthService.login()` → Supabase signIn → `_fetchProfile()` → `UserModel`
2. Signup → `AuthService.signup()` → Supabase signUp → `profiles.upsert()` → `_fetchProfile()` → `UserModel`
3. On success → `AppNavigator.toHome(context)`

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

**Purpose:** Main discovery feed. Shows promo banner, category filter chips, horizontal dish list ("Hot right now"), and vertical restaurant list.

**Screens:** `HomeScreen` — `lib/features/home/home_screen.dart`

**Providers:** `homeNotifierProvider` (`HomeNotifier`, `HomeState`)

**Repositories:** `DishRepository`, `RestaurantRepository`

**Models:** `DishModel`, `RestaurantModel`, `CategoryModel`

**State:**
```dart
HomeState {
  restaurants: List<RestaurantModel>   // popular restaurants
  dishes: List<DishModel>              // popular or filtered dishes
  categories: List<CategoryModel>      // static list (5 categories)
  selectedCategoryId: String?          // active filter
  isLoading: bool
  error: String?
}
```

**Categories:** Static in `home_notifier.dart` (not fetched from DB):
- 1: Burgers 🍔, 2: Pizza 🍕, 3: Asian 🍜, 4: Salads 🥗, 5: Desserts 🍰

**Important Files:**
- `lib/features/home/home_screen.dart`
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

**Models:** `CartItemModel`, `DishModel`

**State:** `List<CartItemModel>` (the state IS the cart items list)

**Computed getters on CartNotifier:**
- `subtotalRs` — sum of all item totals
- `deliveryFeeRs` — fixed Rs 50
- `totalRs` — subtotal + delivery - discount
- `itemCount` — total quantity of all items

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

**ETA logic:** `placedAt + 35 minutes` → counts down to "Arriving in ~N min"

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

See [Admin Panel](#admin-panel) section below.

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
| `adminDashboardNotifierProvider` | `DashboardNotifier` | `DashboardState` | `features/admin/dashboard/dashboard_notifier.dart` |
| `adminOrdersNotifierProvider` | `AdminOrdersNotifier` | `AdminOrdersState` | `features/admin/orders/admin_orders_notifier.dart` |
| `adminDishesNotifierProvider` | `AdminDishesNotifier` | `AdminDishesState` | `features/admin/dishes/admin_dishes_notifier.dart` |
| `adminCategoriesNotifierProvider` | `AdminCategoriesNotifier` | categories state | `features/admin/categories/admin_categories_notifier.dart` |

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
| `DishRepository` | `dishRepositoryProvider` | Dish CRUD + favorites | Supabase `dishes` + `favorites` |
| `OrderRepository` | `orderRepositoryProvider` | Place order, history, tracking, status update | Supabase `orders` |
| `ProfileRepository` | `profileRepositoryProvider` | Profile + addresses + payment methods | Supabase `profiles`, `addresses`, `payment_methods` |
| `RestaurantRepository` | `restaurantRepositoryProvider` | Restaurant list + search + favorites | Supabase `restaurants` + `favorites` |

### Repository Method Reference

**DishRepository:**
- `getPopularDishes()` — top 20 dishes
- `getDishesByCategory(categoryId)` — filtered by category
- `getDishesByRestaurant(restaurantId)` — for restaurant detail screen
- `getFavoriteDishes()` — joins `favorites` → `dishes`
- `toggleFavoriteDish(dishId)` — insert/delete in `favorites`

**RestaurantRepository:**
- `getPopularRestaurants()` — top 20 by rating
- `searchRestaurants(query)` — ilike name search
- `getRestaurantById(id)` — single restaurant
- `getFavoriteRestaurants()` — joins `favorites` → `restaurants`
- `toggleFavorite(restaurantId)` — insert/delete in `favorites`

**OrderRepository:**
- `placeOrder({items, deliveryAddress, paymentMethodId, deliveryFeeRs, discountRs})` → `OrderModel`
- `getOrderHistory()` — user's orders desc by placed_at
- `getActiveOrder()` — latest non-delivered order (placed/preparing/picked)
- `trackOrder(orderId)` → `OrderModel`
- `updateStatus(orderId, status)` — admin use

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
| **Init** | `main.dart` — `Supabase.initialize(url:, publishableKey:)` |
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
  static String get supabaseUrl       => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey   => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey      => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey   => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  static String get baseUrl           => dotenv.env['BASE_URL'] ?? '';
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

**Template** (`.env.example`, safe to commit):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY=your-gemini-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key
STRIPE_SECRET_KEY=sk_test_your-key
BASE_URL=https://your-api.com
```

---

## Database Schema Summary

See full SQL in `supabase/schema.sql`. Run it once in Supabase Dashboard → SQL Editor.

| Table | Purpose | Key columns |
|---|---|---|
| `restaurants` | Restaurant listings | `id`, `name`, `cuisine_tags[]`, `rating`, `delivery_time_min`, `min_order_rs` |
| `dishes` | Menu items | `id`, `name`, `restaurant_id`, `restaurant_name`, `price_rs`, `calories`, `tag`, `category_id` |
| `profiles` | Extended user data (linked to auth.users) | `id`, `full_name`, `email`, `phone`, `avatar_url`, `total_orders`, `points` |
| `addresses` | Saved delivery addresses per user | `id`, `user_id`, `label`, `full_address`, `lat`, `lng`, `is_default` |
| `payment_methods` | Saved payment methods per user | `id`, `user_id`, `type` (card/cash/wallet), `label`, `last_four`, `is_default` |
| `orders` | Order records | `id`, `user_id`, `items` (jsonb), `status`, `placed_at`, `subtotal_rs`, `total_rs`, courier fields |
| `favorites` | User favourites (dishes + restaurants) | `id`, `user_id`, `dish_id`, `restaurant_id`, `type` |

**RLS summary:**
- `restaurants`, `dishes` — public SELECT (anyone can read)
- All other tables — owner-only (`auth.uid() = user_id` or `id`)

**Auto-trigger:** `handle_new_user()` creates a `profiles` row on every new Supabase Auth signup.

**OrderStatus enum values:** `placed` | `preparing` | `picked` | `delivered`

**PaymentType enum values:** `card` | `cash` | `wallet`

---

## Admin Panel

The admin panel is a **separate Flutter app** sharing the same codebase.

**Entry point:** `lib/main_admin.dart` → `AdminApp` → `AdminLoginScreen`

**Shell:** `AdminShellScreen` — responsive layout:
- **≥ 600px width** → `NavigationRail` (sidebar, for tablet/desktop)
- **< 600px width** → `NavigationBar` (bottom bar, for phone)

### Dashboard

**Screen:** `lib/features/admin/dashboard/dashboard_screen.dart`

**Provider:** `adminDashboardNotifierProvider`

**Displays:**
- Stat cards: Total Users, Total Orders, Total Revenue, Total Dishes
- Recent orders list (last 5)

**Data sources:** Counts from `profiles`, `orders`, `dishes` tables

### Order Management

**Screens:**
- `OrderListScreen` — `lib/features/admin/orders/order_list_screen.dart`
- `OrderDetailScreen(orderId)` — `lib/features/admin/orders/order_detail_screen.dart`

**Provider:** `adminOrdersNotifierProvider` (`AdminOrdersNotifier`, `AdminOrdersState`)

**Features:**
- List all orders, sorted by `placed_at` descending
- Search by order ID or restaurant name
- Filter by `OrderStatus` (`placed` / `preparing` / `picked` / `delivered`)
- Update order status in-place

### Menu Management (Dishes)

**Screens:**
- `DishListScreen` — `lib/features/admin/dishes/dish_list_screen.dart`
- `DishFormScreen({dish?})` — `lib/features/admin/dishes/dish_form_screen.dart`

**Provider:** `adminDishesNotifierProvider`

**Features:**
- List all dishes with search
- Add new dish (DishFormScreen with `dish == null`)
- Edit dish (DishFormScreen with `dish != null`)
- Delete dish (with optimistic UI update)

### Category Management

**Screens:**
- `CategoryListScreen` — `lib/features/admin/categories/category_list_screen.dart`
- `CategoryFormScreen({category?})` — `lib/features/admin/categories/category_form_screen.dart`

**Provider:** `adminCategoriesNotifierProvider`

**Features:** Add, edit, delete menu categories.

### Admin Authentication

**Screen:** `AdminLoginScreen` — `lib/features/admin/auth/admin_login_screen.dart`

**Provider:** admin auth notifier — `lib/features/admin/auth/admin_auth_notifier.dart`

---

## Reusable Widgets

All in `lib/core/widgets/`.

| Widget | Purpose | File |
|---|---|---|
| `DishCard` | Dish card with padding-all-around, floating 18px-radius image, favorite toggle (primary orange when active, ink when inactive), add-to-cart | `dish_card.dart` |
| `DishCardSkeleton` | Shimmer loading placeholder for DishCard (matches new layout: padding + floating image) | `skeleton_loader.dart` |
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

**Admin-only widgets** in `lib/features/admin/widgets/`:

| Widget | Purpose | File |
|---|---|---|
| `AdminStatCard` | Dashboard metric card (icon, label, value) | `admin_stat_card.dart` |
| `StatusChip` | Coloured order status badge | `status_chip.dart` |
| `ColorPickerRow` | Category colour picker | `color_picker_row.dart` |

---

## Known Limitations

1. **`.env` credentials required** — placeholder values cause runtime failures; the app cannot function without real Supabase/Gemini/Stripe keys.

2. **Google OAuth not implemented** — the "Continue with Google" button shows a SnackBar. Full OAuth via Supabase would require deep link handling.

3. **Static menu categories** — the 5 home screen categories (Burgers, Pizza, Asian, Salads, Desserts) are hardcoded in `home_notifier.dart`, not fetched from Supabase. The `category_id` field in `dishes` is a plain string that matches these IDs (`'1'`–`'5'`).

4. **No push notifications** — order status changes are shown only when the user is on the tracking screen (polling) or refreshes manually.

5. **Stripe client-side only** — `STRIPE_SECRET_KEY` is used in `stripe_service.dart` directly in the app (acceptable for FYP demo; production requires a backend API to create `PaymentIntent`).

6. **No real geocoding** — address coordinates (`lat`, `lng`) must be entered manually or default to `0, 0`. No address-to-coordinate lookup is implemented.

7. **Cart is local-only** — cart data lives in `SharedPreferences` via `CartRepository`. It is not synced to Supabase (no server-side cart).

8. **No real-time updates** — tracking polls every 15 seconds. Admin order list requires manual refresh. No Supabase realtime subscriptions used.

9. **`BASE_URL` env var** — defined in `Env` and `dio_provider.dart` but Dio is not used for the main data flow (Supabase client handles all DB calls).

10. **Single restaurant** — the app is designed for exactly one restaurant. There is no multi-tenant restaurant management. Admin restaurant CRUD is explicitly out of scope.

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

---

## AI Instructions

When an AI agent works on this project:

1. **Read this document first.** It contains the exact file paths, patterns, and constraints you need.

2. **Read only the files listed for the affected feature.** The Feature Registry and State Management Map tell you exactly which files to open. Do not scan the entire codebase.

3. **Preserve these non-negotiable constraints:**
   - Only `Provider<T>` and `NotifierProvider<T, S>` — never FutureProvider, StreamProvider, StateProvider, AsyncNotifierProvider
   - Standard `Navigator` only — never go_router
   - `AppThemeColors` tokens (`ac.xxx`) — never hardcode `Color(0xFF...)`
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

6. **Navigation is centralised.** Never call `Navigator.push(...)` in a screen directly. Always use `AppNavigator` (customer) or `AdminNavigator` (admin).

7. **The bottom nav bar is in `ShellScreen`, not in any tab screen.** Never add `bottomNavigationBar` to `HomeScreen`, `FavoritesScreen`, `CartScreen`, or `ProfileScreen`.

8. **The admin panel (`main_admin.dart`) is a separate entry point.** Changes to admin screens should not affect the customer app and vice versa.

---

## Last Updated

| Field | Value |
|---|---|
| **Date** | 2026-06-07 |
| **Flutter Analyze** | ✅ No issues (`flutter analyze --no-pub`) |
| **Recent Changes** | Theme colors aligned to design spec; DishCard layout updated (floating image); nav bar expanded to 5 tabs (AI Chat added at index 3); ChatScreen no longer has explicit back button (auto-implied); `cs.primary` forced to exact `#FF5A1F` via `.copyWith()`; background warmed to `#FFF0E6` |
| **Remaining Blocker** | `.env` credentials (Gemini key required for AI Chat to work) |
