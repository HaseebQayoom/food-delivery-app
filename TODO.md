# Crave Food Delivery — Complete Development TODO

> **Legend:** `[ ]` = pending · `[x]` = done · `[~]` = partial / needs fix
> **Stack:** Flutter · Clean Architecture · Feature-first · MVVM · Riverpod · Materialpageroute · Dio · Material 3

---

## STATUS SNAPSHOT (existing code audit)

| File | Design Match | Architecture | Theme Usage | Notes |
|------|-------------|--------------|-------------|-------|
| `splash_screen.dart` | ~80% | ❌ wrong folder | ~60% | formKey in build(), hardcoded colors |
| `onboarding_screen.dart` | ~75% | ❌ wrong folder | ~70% | hardcoded Colors.deepOrange |
| `auth_screen.dart` | ~60% | ❌ wrong folder | ~50% | formKey in build(), hardcoded colors, phone field missing |
| `app_theme.dart` | — | ✅ good base | ✅ | missing gradient, shadows, spacing tokens |
| `pageview_design.dart` | ~70% | ❌ wrong folder | ~65% | skip nav bug (goes to page 2 always) |
| `auth_text.dart` | ✅ | ❌ wrong folder | ✅ | fine, just relocate |

---

## PHASE 0 — PROJECT SETUP & ARCHITECTURE REFACTOR

### 0.1 Folder Structure Refactor
- [ ] Create `lib/core/` directory
- [ ] Create `lib/core/constants/` directory
- [ ] Create `lib/core/constants/app_colors.dart`
- [ ] Create `lib/core/constants/app_text_styles.dart`
- [ ] Create `lib/core/constants/app_dimensions.dart`
- [ ] Create `lib/core/constants/app_strings.dart`
- [ ] Create `lib/core/utils/` directory
- [ ] Create `lib/core/utils/helpers.dart`
- [ ] Create `lib/core/utils/validators.dart`
- [ ] Create `lib/core/utils/extensions.dart`
- [ ] Create `lib/core/widgets/` directory (shared reusable widgets)
- [ ] Create `lib/features/` directory
- [ ] Create `lib/features/splash/` directory
- [ ] Create `lib/features/onboarding/` directory
- [ ] Create `lib/features/auth/` directory
- [ ] Create `lib/features/home/` directory
- [ ] Create `lib/features/favorites/` directory
- [ ] Create `lib/features/cart/` directory
- [ ] Create `lib/features/checkout/` directory
- [ ] Create `lib/features/profile/` directory
- [ ] Create `lib/features/tracking/` directory
- [ ] Create `lib/features/chat/` directory
- [ ] Create `lib/models/` directory
- [ ] Create `lib/services/` directory
- [ ] Create `lib/repositories/` directory

### 0.2 Move Existing Files to Correct Locations
- [ ] Move `lib/screens/splash_screen.dart` → `lib/features/splash/splash_screen.dart`
- [ ] Move `lib/screens/onboarding_screen.dart` → `lib/features/onboarding/onboarding_screen.dart`
- [ ] Move `lib/screens/auth_screen.dart` → `lib/features/auth/auth_screen.dart`
- [ ] Move `lib/widgets/pageview_design.dart` → `lib/features/onboarding/widgets/pageview_design.dart`
- [ ] Move `lib/widgets/auth_text.dart` → `lib/features/auth/widgets/auth_text.dart`
- [ ] Move `lib/widgets/signup_text.dart` → delete (empty stub, unused)
- [ ] Move `lib/data/onbaording_data.dart` → `lib/features/onboarding/data/onboarding_data.dart` (fix typo in filename)
- [ ] Move `lib/model/onboard_model.dart` → `lib/models/onboard_model.dart`
- [ ] Update all import paths after moving files
- [ ] Verify `flutter analyze` passes with zero errors after moves

### 0.3 Package Installation
- [ ] Add `flutter_riverpod: ^2.6.1` to pubspec.yaml
- [ ] Add `riverpod_annotation: ^2.6.1` to pubspec.yaml
- [ ] Add `dio: ^5.7.0` to pubspec.yaml
- [ ] Add `flutter_dotenv: ^5.1.0` to pubspec.yaml
- [ ] Add `shared_preferences: ^2.3.2` to pubspec.yaml
- [ ] Add `cached_network_image: ^3.4.1` to pubspec.yaml
- [ ] Add `flutter_svg: ^2.0.10+1` to pubspec.yaml
- [ ] Add `intl: ^0.19.0` to pubspec.yaml
- [ ] Add `shimmer: ^3.0.0` to pubspec.yaml (skeleton loading)
- [ ] Add `gap: ^3.0.1` to pubspec.yaml (spacing utility)
- [ ] Add `build_runner: ^2.4.12` to dev_dependencies
- [ ] Add `riverpod_generator: ^2.4.3` to dev_dependencies
- [ ] Add `custom_riverpod_lint` (optional) for code quality
- [ ] Run `flutter pub get`
- [ ] Verify no version conflicts

### 0.4 Environment Variables Setup
- [ ] Create `.env` file at project root
- [ ] Add `.env` to `.gitignore` (create `.gitignore` if missing)
- [ ] Create `.env.example` with placeholder keys (safe to commit)
- [ ] Add `BASE_URL=` to `.env`
- [ ] Add `SUPABASE_URL=` to `.env`
- [ ] Add `SUPABASE_ANON_KEY=` to `.env`
- [ ] ~~Add `GOOGLE_MAPS_API_KEY=`~~ — using OpenStreetMap (no API key needed)
- [ ] Add `assets: - .env` under `flutter:` in pubspec.yaml
- [ ] Create `lib/core/constants/env.dart` that loads dotenv values
    - [ ] Add `static String get baseUrl => dotenv.env['BASE_URL'] ?? ''`
    - [ ] Add `static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? ''`
    - [ ] Add `static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? ''`
    - [ ] ~~Add `googleMapsKey`~~ — no key needed, OpenStreetMap is free/open
- [ ] Initialize `dotenv.load()` in `main()` before `runApp()`
- [ ] Wrap `runApp()` in `ProviderScope()` for Riverpod

### 0.5 Navigation Setup (Navigator)
- [ ] Create `lib/core/navigation/app_routes.dart`
    - [ ] Define route name constants as static const strings:
        - [ ] `static const splash = '/splash'`
        - [ ] `static const onboarding = '/onboarding'`
        - [ ] `static const auth = '/auth'`
        - [ ] `static const shell = '/shell'`
        - [ ] `static const checkout = '/checkout'`
        - [ ] `static const tracking = '/tracking'`
        - [ ] `static const chat = '/chat'`
- [ ] Create `lib/core/navigation/app_navigator.dart`
    - [ ] Static helper methods to keep navigation calls clean:
        - [ ] `toOnboarding(context)` → `Navigator.pushReplacement(…OnboardingScreen)`
        - [ ] `toAuth(context)` → `Navigator.pushReplacement(…AuthScreen)`
        - [ ] `toHome(context)` → `Navigator.pushAndRemoveUntil(…ShellScreen, (r) => false)`
        - [ ] `toCheckout(context)` → `Navigator.push(…CheckoutScreen)`
        - [ ] `toTracking(context, orderId)` → `Navigator.push(…TrackingScreen)`
        - [ ] `toChat(context)` → `Navigator.push(…ChatScreen)`
- [ ] Set `home: SplashScreen()` in `MaterialApp` (keep simple, no named routes needed)
- [ ] Use `MaterialPageRoute` for all navigation (already used in existing code)
- [ ] Use `pushReplacement` for one-way flows (splash → onboarding → auth → home)
- [ ] Use `push` for modal/detail screens (checkout, tracking, chat)
- [ ] Use `pushAndRemoveUntil` when landing on home after login (clears back stack)
- [ ] Check onboarding-seen flag in `SplashScreen.initState` and navigate accordingly:
    - [ ] Not seen → `AppNavigator.toOnboarding(context)`
    - [ ] Seen, not logged in → `AppNavigator.toAuth(context)`
    - [ ] Seen, logged in → `AppNavigator.toHome(context)`

### 0.6 Dependency Injection (Riverpod Providers)
- [ ] Create `lib/core/providers/` directory
- [ ] Create `lib/core/providers/dio_provider.dart`
    - [ ] Create `dioProvider` that returns configured `Dio` instance
    - [ ] Set base URL from `Env.baseUrl`
    - [ ] Add `ContentTypeInterceptor`
    - [ ] Add `AuthInterceptor` (attach Bearer token from storage)
    - [ ] Add `LoggingInterceptor` (dev only)
    - [ ] Set connect/receive timeout
- [ ] Create `lib/core/providers/shared_prefs_provider.dart`
    - [ ] Create `sharedPrefsProvider` (async, initialized once)
- [ ] Create `lib/core/providers/auth_state_provider.dart`
    - [ ] Track whether user is logged in (read from shared_prefs on startup)
    - [ ] No redirect logic needed — splash screen handles all nav decisions manually

---

## PHASE 1 — DESIGN SYSTEM

> ### Quick Reference — How to use colors & text in every widget
> ```dart
> // In any widget build method:
> final cs = Theme.of(context).colorScheme;       // short alias
> final tt = Theme.of(context).textTheme;         // short alias
> final ac = Theme.of(context).extension<AppThemeColors>()!; // custom colors
>
> // Colors (from seed — automatic light/dark)
> cs.primary          // brand orange #FF5A1F
> cs.onPrimary        // white (text/icons ON orange)
> cs.surface          // card background
> cs.onSurface        // primary text
> cs.onSurfaceVariant // secondary/muted text
> cs.outline          // borders and dividers
> cs.error            // red for errors
>
> // Custom colors (from AppThemeColors extension)
> ac.background       // warm white page bg
> ac.creamSurface     // cream card bg
> ac.navbarBackground // dark navbar bg
> ac.border           // subtle border
> ac.mutedText        // extra muted labels
>
> // Text
> tt.headlineLarge    // big screen headings
> tt.headlineSmall    // section titles / card headers
> tt.bodyMedium       // regular body copy
> tt.bodySmall        // small labels / captions
> tt.bodyMedium!.copyWith(color: cs.primary) // custom override
>
> // Gradient (only where needed — buttons, header, promo)
> AppGradients.primaryGradient  // orange gradient
> ```

### 1.1 Theme-First Color Approach
> **Rule:** Always use `Theme.of(context)` and `Theme.of(context).colorScheme` to access colors.
> Only fall back to `AppColors` for values not covered by the seed-generated scheme (gradients, custom surfaces).
> Never hardcode `Color(0xFF...)` directly in widget files.

- [ ] Keep `AppTheme.seedColor = Color(0xFFFF5A1F)` as the single source of truth
- [ ] Access colors in widgets via:
    - [ ] `Theme.of(context).colorScheme.primary` — brand orange
    - [ ] `Theme.of(context).colorScheme.onPrimary` — white (text on orange)
    - [ ] `Theme.of(context).colorScheme.surface` — card/input backgrounds
    - [ ] `Theme.of(context).colorScheme.onSurface` — primary text
    - [ ] `Theme.of(context).colorScheme.onSurfaceVariant` — secondary/muted text
    - [ ] `Theme.of(context).colorScheme.outline` — border/divider color
    - [ ] `Theme.of(context).colorScheme.error` — error/danger red
    - [ ] `Theme.of(context).scaffoldBackgroundColor` — main page background
- [ ] Access custom colors via `AppThemeColors` extension (already in app_theme.dart):
    - [ ] `Theme.of(context).extension<AppThemeColors>()!.background`
    - [ ] `Theme.of(context).extension<AppThemeColors>()!.creamSurface`
    - [ ] `Theme.of(context).extension<AppThemeColors>()!.navbarBackground`
    - [ ] `Theme.of(context).extension<AppThemeColors>()!.border`
    - [ ] `Theme.of(context).extension<AppThemeColors>()!.mutedText`
- [ ] Create shorthand extension for cleaner widget code:
    - [ ] `extension ContextTheme on BuildContext`
        - [ ] `get cs => Theme.of(this).colorScheme`
        - [ ] `get tt => Theme.of(this).textTheme`
        - [ ] `get appColors => Theme.of(this).extension<AppThemeColors>()!`
- [ ] Define `AppColors` ONLY for values with no theme equivalent:
    - [ ] `primaryGradientStart = Color(0xFFEF9F27)` — gradient (no scheme equivalent)
    - [ ] `primaryGradientEnd = Color(0xFFD85A30)` — gradient end
    - [ ] `success = Color(0xFF2DBE60)` — green success (not in M3 scheme by default)
    - [ ] `warning = Color(0xFFFFB400)` — yellow warning
- [ ] Define `AppGradients` class:
    - [ ] `primaryGradient` — `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd])`
    - [ ] Use this gradient for: login button, checkout button, profile header, logo area

### 1.2 AppTheme Audit — Required Additions
- [ ] **[AppTheme]** Add `AppThemeColors.success` color token (Color(0xFF2DBE60))
- [ ] **[AppTheme]** Add `AppThemeColors.warning` color token (Color(0xFFFFB400))
- [ ] **[AppTheme]** Add `AppThemeColors.primaryGradientStart` color token (for gradient-using widgets)
- [ ] **[AppTheme]** Add `AppThemeColors.primaryGradientEnd` color token
- [ ] **[AppTheme]** Replace all `Colors.deepOrange` hardcodes → `colorScheme.primary` (theme-aware)
- [ ] **[AppTheme]** Replace all `Colors.white` hardcodes → `colorScheme.onPrimary` or `colorScheme.surface`
- [ ] **[AppTheme]** Add `cardShadow` to `AppThemeColors` — `List<BoxShadow>`
- [ ] **[AppTheme]** Add `buttonShadow` to `AppThemeColors` — orange glow shadow
- [ ] **[AppTheme]** Add `navbarShadow` to `AppThemeColors` — dark bottom shadow
- [ ] **[AppTheme]** Extend `textTheme` with missing styles used across screens:
    - [ ] Verify `headlineSmall` (20px w700) — used for screen titles
    - [ ] Verify `titleMedium` (16px w600) — used for card titles
    - [ ] Verify `bodySmall` (12px w500 muted) — used for captions and labels
    - [ ] Add `labelSmall` override: 10px w600 letterSpacing 0.3 (badge text)
- [ ] **[AppTheme]** Add `AppDimensions` spacing constants (`lib/core/constants/app_dimensions.dart`)
    - [ ] `xs = 4.0`, `sm = 8.0`, `md = 16.0`, `lg = 24.0`, `xl = 32.0`, `xxl = 48.0`
    - [ ] `screenPadding = 20.0`
    - [ ] `cardRadius = 24.0`, `buttonRadius = 999.0`, `inputRadius = 16.0`
- [ ] **[AppTheme]** Add `NavigationBarTheme` with dark bg and orange indicator (for shell)
- [ ] **[AppTheme]** Add `copyWith` proper implementation on `AppThemeColors` (currently returns `this` — breaks dark mode)
- [ ] **[AppTheme]** Add `lerp` proper implementation on `AppThemeColors` (currently returns `this`)

### 1.3 Text Style Approach — Theme.of(context).textTheme
> **Rule:** Always use `Theme.of(context).textTheme.X` — the app_theme.dart already defines all styles.
> Use `.copyWith()` only to override a specific property (color, weight, size).

- [ ] The existing `textTheme` in `app_theme.dart` already maps correctly — use as-is:
    - [ ] `textTheme.displayLarge` — 40px Bricolage Grotesque w700
    - [ ] `textTheme.headlineLarge` — 28px Bricolage Grotesque w700 (screen headings)
    - [ ] `textTheme.headlineMedium` — 24px Bricolage Grotesque w700
    - [ ] `textTheme.headlineSmall` — 20px Bricolage Grotesque w700 (card titles)
    - [ ] `textTheme.titleLarge` — 18px DM Sans w700
    - [ ] `textTheme.titleMedium` — 16px DM Sans w600
    - [ ] `textTheme.titleSmall` — 14px DM Sans w600
    - [ ] `textTheme.bodyLarge` — 16px DM Sans w500
    - [ ] `textTheme.bodyMedium` — 14px DM Sans w500 secondaryText
    - [ ] `textTheme.bodySmall` — 12px DM Sans w500 mutedText
    - [ ] `textTheme.labelSmall` — use for 10px badges (override in AppTheme if needed)
- [ ] Common pattern in widgets:
    ```dart
    Text('Hello', style: Theme.of(context).textTheme.headlineMedium)
    Text('sub', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colorScheme.primary))
    ```
- [ ] Do NOT create a separate `AppTextStyles` file — keep everything in theme

### 1.4 AppDimensions (`lib/core/constants/app_dimensions.dart`)
- [ ] Define all spacing, radius, and size constants (see AppTheme audit above)

### 1.5 Assets Setup
- [ ] Verify `assets/image1.jpg` exists and is referenced correctly in pubspec.yaml
- [ ] Verify `assets/image2.jpg` exists and is referenced correctly in pubspec.yaml
- [ ] Verify `assets/image3.jpg` exists and is referenced correctly in pubspec.yaml
- [ ] Create `assets/icons/` folder for any SVG icons (if using flutter_svg)
- [ ] Create `assets/images/` folder and move jpg files there
    - [ ] Update pubspec.yaml asset paths accordingly
    - [ ] Update `onboarding_data.dart` Image.asset paths
- [ ] **[MISSING ASSET]** Hero promo banner image for Home screen — create placeholder or use gradient container
- [ ] **[MISSING ASSET]** User avatar placeholder image for Profile screen
- [ ] **[MISSING ASSET]** Empty state illustration for Favorites screen
- [ ] **[MISSING ASSET]** Empty state illustration for Cart screen
- [ ] **[MISSING ASSET]** Google logo icon for auth social login button
- [ ] Add all new asset paths to pubspec.yaml under `assets:`

---

## PHASE 2 — CORE SHARED WIDGETS

### 2.1 PrimaryButton (`lib/core/widgets/primary_button.dart`)
- [ ] Create `PrimaryButton` StatelessWidget
    - [ ] Props: `text`, `onPressed`, `isDark` (bool, default false), `isLoading` (bool, default false), `icon` (optional Widget)
    - [ ] Height: 56px, width: full or wrap_content
    - [ ] Background: `Theme.of(context).colorScheme.primary` (or `colorScheme.onSurface` if isDark)
    - [ ] Border radius: `AppDimensions.buttonRadius` (999)
    - [ ] Box shadow: `Theme.of(context).extension<AppThemeColors>()!.buttonShadow`
    - [ ] Show `CircularProgressIndicator` when `isLoading = true`
    - [ ] Disable `onPressed` when `isLoading = true`
    - [ ] Text style: `Theme.of(context).textTheme.bodyLarge!.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)`
    - [ ] Support leading icon

### 2.2 OutlinedPillButton (`lib/core/widgets/outlined_pill_button.dart`)
- [ ] Create `OutlinedPillButton` StatelessWidget
    - [ ] Props: `text`, `onPressed`, `icon` (optional), `borderColor`, `textColor`
    - [ ] Height: 56px, border radius: 999
    - [ ] Bordered, no fill

### 2.3 GradientButton (`lib/core/widgets/gradient_button.dart`)
- [ ] Create `GradientButton` StatelessWidget
    - [ ] Uses `AppGradients.primaryGradient` as background
    - [ ] Props: `text`, `onPressed`, `isLoading`, `height` (default 56)
    - [ ] Border radius: 999
    - [ ] Orange shadow

### 2.4 CustomBottomNavBar (`lib/core/widgets/custom_bottom_nav_bar.dart`)
- [ ] Create `CustomBottomNavBar` StatelessWidget
    - [ ] Props: `currentIndex`, `onTap`
    - [ ] Floating pill shape: margin H:12 V:18, height: 68, borderRadius: 26
    - [ ] Background: `Theme.of(context).extension<AppThemeColors>()!.navbarBackground`
    - [ ] Items: Home (Icons.home_rounded), Saved (Icons.favorite_rounded), Cart (Icons.shopping_bag_rounded), Account (Icons.person_rounded)
    - [ ] Active item: `colorScheme.primary` icon + label + `colorScheme.primary.withValues(alpha:0.14)` bg chip
    - [ ] Inactive item: `Colors.white.withValues(alpha:0.6)` icon + label
    - [ ] Box shadow: `appColors.navbarShadow`
    - [ ] Icon size: 22px
    - [ ] Label size: 11px w500

### 2.5 RestaurantCard (`lib/core/widgets/restaurant_card.dart`)
- [ ] Create `RestaurantCard` StatelessWidget
    - [ ] Props: `restaurant` (RestaurantModel), `onTap`, `isFavorite`, `onFavoriteToggle`
    - [ ] Layout: Row — image 70x70 + details column
    - [ ] Image: rounded square, emoji/cached image fallback
    - [ ] Details: name (14px w500), cuisine tags (11px muted), rating star + time + min order (11px)
    - [ ] Optional: heart icon in top-right
    - [ ] Border: 0.5px `AppColors.line`
    - [ ] Border radius: 16
    - [ ] Padding: 8

### 2.6 DishCard (`lib/core/widgets/dish_card.dart`)
- [ ] Create `DishCard` StatelessWidget
    - [ ] Props: `dish` (DishModel), `isFavorite`, `onFavoriteToggle`, `onAddToCart`
    - [ ] Width: 200, border radius: 24, border: `AppColors.line`
    - [ ] Image area: 130px height, borderRadius 18, cream bg fallback
    - [ ] Tag badge (top-left): dark bg, white text, 10px w600, rounded 999
    - [ ] Favorite button (top-right): white circle 32x32, heart icon 16px
    - [ ] Dish name: 15px w600, max 2 lines
    - [ ] Restaurant + kcal: 12px muted
    - [ ] Price: 16px w700 (Rs format)
    - [ ] Add button: orange circle 30x30 with + icon

### 2.7 CategoryChip (`lib/core/widgets/category_chip.dart`)
- [ ] Create `CategoryChip` StatelessWidget
    - [ ] Props: `label`, `icon` (emoji or widget), `isSelected`, `onTap`, `bgColor`
    - [ ] Container: 52x52 icon area with rounded corners (12), colored bg
    - [ ] Label text: 11px below icon
    - [ ] Tap scales down slightly (GestureDetector with feedback)

### 2.8 SearchBar (`lib/core/widgets/custom_search_bar.dart`)
- [ ] Create `CustomSearchBar` StatelessWidget
    - [ ] Props: `hint`, `onChanged`, `onSubmitted`, `onFilterTap`, `readOnly`, `onTap`
    - [ ] Leading search icon (grey, 16px)
    - [ ] Trailing mic icon (right side)
    - [ ] Filter button (sliders icon, separate button to the right)
    - [ ] Fill color: white, border: `AppColors.line`, borderRadius: 16
    - [ ] Height: 52px

### 2.9 SkeletonLoader (`lib/core/widgets/skeleton_loader.dart`)
- [ ] Create `SkeletonBox` StatelessWidget (uses shimmer package)
    - [ ] Props: `width`, `height`, `borderRadius`
    - [ ] Shimmer gradient: grey50 → grey200 → grey50
- [ ] Create `RestaurantCardSkeleton` using SkeletonBox
- [ ] Create `DishCardSkeleton` using SkeletonBox
- [ ] Create `HomeHeaderSkeleton`

### 2.10 ErrorStateWidget (`lib/core/widgets/error_state_widget.dart`)
- [ ] Create `ErrorStateWidget` StatelessWidget
    - [ ] Props: `message`, `onRetry`
    - [ ] Shows error icon, message text, retry button
    - [ ] Centered layout

### 2.11 EmptyStateWidget (`lib/core/widgets/empty_state_widget.dart`)
- [ ] Create `EmptyStateWidget` StatelessWidget
    - [ ] Props: `title`, `subtitle`, `illustration` (optional Widget), `actionLabel`, `onAction`
    - [ ] Centered layout with illustration placeholder

### 2.12 QuantityControl (`lib/core/widgets/quantity_control.dart`)
- [ ] Create `QuantityControl` StatelessWidget
    - [ ] Props: `quantity`, `onIncrement`, `onDecrement`
    - [ ] Row: `−` button | quantity number | `+` button
    - [ ] Buttons: 28x28 white bg, rounded 6
    - [ ] Disable `−` when quantity is 0 or 1 (configurable)

### 2.13 SectionHeader (`lib/core/widgets/section_header.dart`)
- [ ] Create `SectionHeader` StatelessWidget
    - [ ] Props: `title`, `actionLabel` (optional "See all"), `onAction`
    - [ ] Row: title (18px w700) + spacer + action text (13px primary color)

### 2.14 PriceRow (`lib/core/widgets/price_row.dart`)
- [ ] Create `PriceRow` StatelessWidget
    - [ ] Props: `label`, `amount`, `isBold`, `currency` (default 'Rs')
    - [ ] Row: label text + spacer + price text (Rs format)

---

## PHASE 3 — MODELS

### 3.1 UserModel (`lib/models/user_model.dart`)
- [ ] Define `UserModel` class
    - [ ] `id`, `fullName`, `email`, `phone`, `avatarUrl`
    - [ ] `isCravePlusMember` (bool)
    - [ ] `totalOrders`, `favoriteCount`, `points` (int — for profile stats)
    - [ ] `fromJson(Map)` factory
    - [ ] `toJson()` method
    - [ ] `copyWith()` method

### 3.2 RestaurantModel (`lib/models/restaurant_model.dart`)
- [ ] Define `RestaurantModel` class
    - [ ] `id`, `name`, `imageUrl`, `cuisineTags` (List<String>)
    - [ ] `rating` (double), `deliveryTimeMin` (int), `minOrderRs` (int)
    - [ ] `isFavorite` (bool)
    - [ ] `fromJson(Map)` factory
    - [ ] `toJson()` method
    - [ ] `copyWith()` method

### 3.3 DishModel (`lib/models/dish_model.dart`)
- [ ] Define `DishModel` class
    - [ ] `id`, `name`, `imageUrl`, `restaurantId`, `restaurantName`
    - [ ] `priceRs` (int), `calories` (int), `tag` (String — badge label)
    - [ ] `isFavorite` (bool)
    - [ ] `fromJson(Map)` factory
    - [ ] `toJson()` method
    - [ ] `copyWith()` method

### 3.4 CategoryModel (`lib/models/category_model.dart`)
- [ ] Define `CategoryModel` class
    - [ ] `id`, `name`, `emoji`, `bgColor` (Color)
    - [ ] `fromJson(Map)` factory

### 3.5 CartItemModel (`lib/models/cart_item_model.dart`)
- [ ] Define `CartItemModel` class
    - [ ] `dish` (DishModel), `quantity` (int)
    - [ ] `get totalPriceRs` → `dish.priceRs * quantity`
    - [ ] `copyWith()` method

### 3.6 OrderModel (`lib/models/order_model.dart`)
- [ ] Define `OrderModel` class
    - [ ] `id`, `items` (List<CartItemModel>), `status` (OrderStatus enum)
    - [ ] `restaurantName`, `deliveryAddress`, `placedAt` (DateTime)
    - [ ] `subtotalRs`, `deliveryFeeRs`, `totalRs`, `discountRs`
    - [ ] `courierName`, `courierPhone`, `courierLat`, `courierLng`
    - [ ] `fromJson(Map)` factory
    - [ ] `toJson()` method
- [ ] Define `OrderStatus` enum
    - [ ] `placed`, `preparing`, `picked`, `delivered`

### 3.7 AddressModel (`lib/models/address_model.dart`)
- [ ] Define `AddressModel` class
    - [ ] `id`, `label`, `fullAddress`, `lat`, `lng`, `isDefault` (bool)
    - [ ] `fromJson(Map)` factory

### 3.8 PaymentMethodModel (`lib/models/payment_method_model.dart`)
- [ ] Define `PaymentMethodModel` class
    - [ ] `id`, `type` (PaymentType enum: card, cash, wallet), `label`, `lastFour`
    - [ ] `isDefault` (bool)

### 3.9 ChatMessageModel (`lib/models/chat_message_model.dart`)
- [ ] Define `ChatMessageModel` class
    - [ ] `id`, `text`, `isFromUser` (bool), `sentAt` (DateTime)
    - [ ] `quickReplies` (List<String>? — for bot responses)

---

## PHASE 4 — SERVICES LAYER

### 4.1 ApiService (`lib/services/api_service.dart`)
- [ ] Create `ApiService` class (injected with Dio)
    - [ ] Generic `get<T>(path)` method with error handling
    - [ ] Generic `post<T>(path, data)` method
    - [ ] Generic `put<T>(path, data)` method
    - [ ] Generic `delete<T>(path)` method
    - [ ] Handle `DioException` → map to `AppException`
- [ ] Create `AppException` class
    - [ ] `message`, `statusCode`, `type` (network / server / auth / unknown)
- [ ] Create `ApiInterceptor` (auth token attachment)
- [ ] Create `LoggingInterceptor` (dev only, print request/response)

### 4.2 AuthService (`lib/services/auth_service.dart`)
> **Using Supabase** — `supabase_flutter` handles tokens, session refresh, and persistence automatically. No manual token storage needed.
- [ ] Initialize Supabase in `main()`:
    ```dart
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
    ```
- [ ] Create `AuthService` class wrapping `Supabase.instance.client.auth`
    - [ ] `login(email, password)` → `supabase.auth.signInWithPassword(email, password)`
    - [ ] `signup(name, email, phone, password)` → `supabase.auth.signUp(email, password, data: {name, phone})`
    - [ ] `logout()` → `supabase.auth.signOut()`
    - [ ] `getCurrentUser()` → `supabase.auth.currentUser`
    - [ ] `isLoggedIn()` → `supabase.auth.currentSession != null`
    - [ ] `onAuthStateChange` stream → `supabase.auth.onAuthStateChange`
- [ ] Deep linking setup (for email verify / password reset):
    - [ ] Add `supabase_flutter: ^2.8.4` to pubspec.yaml (see Phase 0.3)
    - [ ] Set redirect URL in Supabase dashboard: `io.supabase.crave://login-callback/`
    - [ ] **Android** — add intent filter to `android/app/src/main/AndroidManifest.xml`:
        ```xml
        <intent-filter>
          <action android:name="android.intent.action.VIEW"/>
          <category android:name="android.intent.category.DEFAULT"/>
          <category android:name="android.intent.category.BROWSABLE"/>
          <data android:scheme="io.supabase.crave" android:host="login-callback"/>
        </intent-filter>
        ```
    - [ ] **iOS** — add to `ios/Runner/Info.plist`:
        ```xml
        <key>CFBundleURLTypes</key>
        <array>
          <dict>
            <key>CFBundleURLSchemes</key>
            <array><string>io.supabase.crave</string></array>
          </dict>
        </array>
        ```

### 4.3 StorageService (`lib/services/storage_service.dart`)
- [ ] Create `StorageService` class (wraps SharedPreferences)
    - [ ] `saveString(key, value)`, `getString(key)`
    - [ ] `saveBool(key, value)`, `getBool(key)`
    - [ ] `remove(key)`
    - [ ] Key constants: `tokenKey`, `userKey`, `onboardingSeenKey`

---

## PHASE 5 — REPOSITORIES

### 5.1 AuthRepository (`lib/repositories/auth_repository.dart`)
- [ ] Create `AuthRepository` class
    - [ ] `login(email, password)` → calls `AuthService.login()` → returns `supabase.auth.currentUser`
    - [ ] `signup(name, email, phone, password)` → calls `AuthService.signup()` → returns user
    - [ ] `logout()`
    - [ ] `getStoredUser()` → `UserModel?`
- [ ] Create `authRepositoryProvider` (Riverpod)

### 5.2 RestaurantRepository (`lib/repositories/restaurant_repository.dart`)
- [ ] Create `RestaurantRepository` class
    - [ ] `getPopularRestaurants()` → `List<RestaurantModel>`
    - [ ] `searchRestaurants(query)` → `List<RestaurantModel>`
    - [ ] `getRestaurantById(id)` → `RestaurantModel`
    - [ ] `getFavoriteRestaurants()` → `List<RestaurantModel>`
    - [ ] `toggleFavorite(restaurantId)` → void
- [ ] Create `restaurantRepositoryProvider` (Riverpod)

### 5.3 DishRepository (`lib/repositories/dish_repository.dart`)
- [ ] Create `DishRepository` class
    - [ ] `getPopularDishes()` → `List<DishModel>`
    - [ ] `getDishesByCategory(categoryId)` → `List<DishModel>`
    - [ ] `getDishesByRestaurant(restaurantId)` → `List<DishModel>`
    - [ ] `getFavoriteDishes()` → `List<DishModel>`
    - [ ] `toggleFavoriteDish(dishId)` → void
- [ ] Create `dishRepositoryProvider` (Riverpod)

### 5.4 CartRepository (`lib/repositories/cart_repository.dart`)
- [ ] Create `CartRepository` class (local state, persisted to storage)
    - [ ] `getCart()` → `List<CartItemModel>`
    - [ ] `addItem(DishModel)` → void (increment if exists)
    - [ ] `removeItem(dishId)` → void
    - [ ] `updateQuantity(dishId, quantity)` → void
    - [ ] `clearCart()` → void
    - [ ] `applyPromoCode(code)` → `int discountRs`
    - [ ] Persist cart to SharedPreferences on every change
- [ ] Create `cartRepositoryProvider` (Riverpod)

### 5.5 OrderRepository (`lib/repositories/order_repository.dart`)
- [ ] Create `OrderRepository` class
    - [ ] `placeOrder(cartItems, addressId, paymentMethodId)` → `OrderModel`
    - [ ] `getOrderHistory()` → `List<OrderModel>`
    - [ ] `getActiveOrder()` → `OrderModel?`
    - [ ] `trackOrder(orderId)` → `OrderModel` (polling or stream)
- [ ] Create `orderRepositoryProvider` (Riverpod)

### 5.6 ProfileRepository (`lib/repositories/profile_repository.dart`)
- [ ] Create `ProfileRepository` class
    - [ ] `getProfile()` → `UserModel`
    - [ ] `updateProfile(name, phone, avatarUrl)` → `UserModel`
    - [ ] `getSavedAddresses()` → `List<AddressModel>`
    - [ ] `addAddress(AddressModel)` → void
    - [ ] `setDefaultAddress(addressId)` → void
    - [ ] `deleteAddress(addressId)` → void
    - [ ] `getPaymentMethods()` → `List<PaymentMethodModel>`
    - [ ] `addPaymentMethod(PaymentMethodModel)` → void
    - [ ] `setDefaultPayment(paymentId)` → void
- [ ] Create `profileRepositoryProvider` (Riverpod)

---

## PHASE 6 — FEATURE: SPLASH SCREEN

### 6.1 Audit Existing SplashScreen
- [ ] **[BUG]** Fix: `formKey` is defined in build() in `auth_screen.dart` — move to State
- [ ] **[CLEANUP]** Remove all commented-out code blocks in `splash_screen.dart`
- [ ] **[REFACTOR]** Replace `const Color(0xFFFF5A1F)` hardcode → `AppColors.primary`
- [ ] **[REFACTOR]** Replace `colorScheme.surfaceContainerLowest` with explicit `Colors.white.withValues(alpha:.7)` for loader
- [ ] **[REFACTOR]** Use `AppTextStyles` instead of `.copyWith()` overrides
- [ ] **[REFACTOR]** Replace inline `Navigator.pushReplacement` calls with `AppNavigator.toOnboarding(context)` / `toAuth()` / `toHome()`

### 6.2 UI Polish
- [ ] Add ambient gradient blob decorations behind the logo (optional, from design)
- [ ] Verify logo card is 120x120 white rounded rect rotated -6°
- [ ] Verify "crave." text is 80px Bricolage Grotesque bold white
- [ ] Verify "EAT WHAT YOU CRAVE" tagline is 20px, letterSpacing 1.5, white80
- [ ] Verify ink-drop loading indicator is shown at the bottom
- [ ] Reduce splash delay from 4s → 2.5s (better UX)
- [ ] Add check in `initState`: if onboarding already seen → navigate to `/auth` or `/home`

### 6.3 State Management
- [ ] Create `splashProvider` (Riverpod AsyncNotifier)
    - [ ] On init: check `StorageService.onboardingSeenKey`
    - [ ] Navigate accordingly via router

---

## PHASE 7 — FEATURE: ONBOARDING

### 7.1 Audit Existing OnboardingScreen
- [ ] **[BUG FIX]** `pageview_design.dart` line 61: Skip always goes to page 2 — fix to `onboardingData.length - 1`
- [ ] **[REFACTOR]** Replace `Colors.deepOrange` → `AppColors.primary` (onboarding_screen.dart lines 66, 82, 86)
- [ ] **[REFACTOR]** Use `AppRouter` constants instead of inline `MaterialPageRoute`
- [ ] **[REFACTOR]** Move `ExpandingDotsEffect` colors to AppColors constants
- [ ] **[REFACTOR]** Remove typo from filename `onbaording_data.dart` → `onboarding_data.dart`

### 7.2 UI Polish
- [ ] Verify page image card height is capped at 450px with `ClipRRect`
- [ ] Verify badge chip border radius is 20, color from `onbaordingD.color`
- [ ] Verify skip/next button styling matches design
- [ ] Verify title font is Bricolage Grotesque 35px w700
- [ ] Verify body text is DM Sans 15px centered
- [ ] Verify smooth page indicator dots: active = deepOrange, inactive = grey
- [ ] Verify circular forward button is 56x56 deepOrange with arrow_forward_ios icon
- [ ] Add fade+slide page transition between onboarding slides

### 7.3 State Management
- [ ] Create `onboardingProvider` (Riverpod Notifier)
    - [ ] Tracks current page index
    - [ ] `nextPage()` method
    - [ ] `markSeen()` → saves to StorageService
- [ ] On final page navigation to auth, call `markSeen()`

---

## PHASE 8 — FEATURE: AUTH

### 8.1 Audit Existing AuthScreen
- [ ] **[BUG]** Move `formKey = GlobalKey<FormState>()` out of `build()` → declare as `State` field
- [ ] **[BUG]** Move `name`, `email`, `password` variables to `State` fields
- [ ] **[BUG]** Move `submitForm()` function to `State` class (not inside `build()`)
- [ ] **[MISSING]** Phone number field for login (design shows phone + password for login)
- [ ] **[MISSING]** Phone number field for signup (design: name + email + phone + password)
- [ ] **[MISSING]** Password visibility toggle ("Show" button)
- [ ] **[MISSING]** "Remember me" checkbox (login)
- [ ] **[MISSING]** "Terms & conditions" checkbox (signup)
- [ ] **[MISSING]** Forgot password link (login mode)
- [ ] **[MISSING]** Apple social login button (design shows Apple + Google)
- [ ] **[REFACTOR]** `_buildCustomField` → extract to `lib/core/widgets/custom_text_field.dart`
- [ ] **[REFACTOR]** Replace hardcoded `Colors.deepOrange` → `AppColors.primary`
- [ ] **[REFACTOR]** Replace hardcoded `Colors.white` in container → `AppColors.white`
- [ ] **[REFACTOR]** Fix the spacer `MediaQuery.of(context).size.height/5.92` — use `Spacer()` or fixed gap
- [ ] **[REFACTOR]** On successful login/signup → `AppNavigator.toHome(context)` (pushAndRemoveUntil)

### 8.2 UI — Login Mode
- [ ] Back button top-left (if navigated from splash, hide it)
- [ ] Logo/icon at top center: 56x56 gradient circle with emoji/letter
- [ ] Heading: "Welcome back." (headlineMedium, w700)
- [ ] Sub: "Login to order delicious food" (bodyMedium, secondary color)
- [ ] Animated toggle: "Log In" / "Sign Up" (existing, keep)
- [ ] Phone number field (type: phone, leading phone icon)
- [ ] Password field (obscure, trailing "Show" toggle button)
- [ ] "Forgot password?" text link (right-aligned, below password)
- [ ] "Remember me" checkbox row
- [ ] "Log in" button (full width, gradient or primary color, 56px)
- [ ] "or continue with" divider row
- [ ] Google button (outlined, Google logo icon, full width)
- [ ] Apple button (outlined, Apple logo icon, full width)
- [ ] "Don't have an account? Sign up" text at bottom

### 8.3 UI — Sign Up Mode
- [ ] Heading: "Let's get you fed." 
- [ ] Sub: "Create an account in under a minute."
- [ ] Full name field (leading person icon)
- [ ] Email field (leading mail icon)
- [ ] Phone number field (leading phone icon)
- [ ] Password field (obscure, trailing "Show" toggle)
- [ ] "I agree to Terms & Conditions" checkbox
- [ ] "Create account" button (full width, 56px)
- [ ] "or continue with" divider
- [ ] Google button
- [ ] Apple button
- [ ] "Already have an account? Log in" text at bottom

### 8.4 State Management
- [ ] Create `authNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] `isLogin` bool state
    - [ ] `toggleMode()` method
    - [ ] `login(phone, password)` → calls AuthRepository → navigates to home
    - [ ] `signup(name, email, phone, password)` → calls AuthRepository → navigates to home
    - [ ] `loginWithGoogle()` → future implementation
    - [ ] `loginWithApple()` → future implementation
    - [ ] Expose `AsyncValue` loading/error state

### 8.5 Validation (move to `lib/core/utils/validators.dart`)
- [ ] `validateName(String?)` → not empty, min 2 chars
- [ ] `validateEmail(String?)` → regex validation
- [ ] `validatePhone(String?)` → Pakistani format (+92 / 03xx)
- [ ] `validatePassword(String?)` → min 6 chars

---

## PHASE 9 — NAVIGATION SHELL (Bottom Nav)

### 9.1 Shell Screen (`lib/features/shell/shell_screen.dart`)
- [ ] Create `ShellScreen` StatefulWidget
    - [ ] Holds `currentIndex` state (0=Home, 1=Favorites, 2=Cart, 3=Profile)
    - [ ] Uses `CustomBottomNavBar` (from Phase 2.4)
    - [ ] Uses `IndexedStack` to preserve tab state (screens stay alive when switching tabs)
        - [ ] `children: [HomeScreen(), FavoritesScreen(), CartScreen(), ProfileScreen()]`
        - [ ] `currentIndex` controls which child is visible
    - [ ] Cart tab badge: shows item count from `cartProvider`
    - [ ] Notification bell (not in bottom nav — in app bars per screen)
- [ ] Navigate TO `ShellScreen` via `AppNavigator.toHome(context)` (pushAndRemoveUntil)

---

## PHASE 10 — FEATURE: HOME

### 10.1 State Management
- [ ] Create `homeNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] Fetch popular restaurants on init
    - [ ] Fetch popular dishes on init
    - [ ] Fetch categories on init
    - [ ] `selectedCategory` state
    - [ ] `selectCategory(CategoryModel)` → filters dishes
    - [ ] Expose `AsyncValue` loading/error states

### 10.2 UI — HomeScreen (`lib/features/home/home_screen.dart`)

#### 10.2.1 Header Section
- [ ] Location row:
    - [ ] "Deliver to" label (12px secondary)
    - [ ] Location name with pin icon (14px w500, pin icon danger color)
    - [ ] Dropdown chevron icon next to location name
    - [ ] Tappable — shows city/address selection bottom sheet
- [ ] Bell icon button (top-right):
    - [ ] 36x36 circle, background cream
    - [ ] Tap → navigate to notifications (future screen)
    - [ ] Optional badge for unread count

#### 10.2.2 Greeting + Search Section
- [ ] Greeting text: "Hey [Name], what are you craving?" (headlineMedium)
    - [ ] Pulls user name from `authNotifier` or `profileProvider`
- [ ] Search bar (`CustomSearchBar`):
    - [ ] Placeholder: "Search restaurants or dishes"
    - [ ] Leading search icon
    - [ ] Trailing mic icon
    - [ ] Trailing filter icon button (separate)
    - [ ] Tap → navigates to search screen (or opens search mode inline)

#### 10.2.3 Hero Promo Card
- [ ] Gradient container (primaryGradientStart → primaryGradientEnd), borderRadius 20
- [ ] Badge text: "TODAY'S DEAL" (white, uppercase, small)
- [ ] Headline: "Get 20% off" (white, 24px w700)
- [ ] Subtext: "On orders above Rs 500" (white80, 14px)
- [ ] CTA button: "Order now" (white bg, dark text, small pill button)
- [ ] Illustration/image on the right side

#### 10.2.4 Categories Section
- [ ] Section header: "Categories" + "See all" button
- [ ] Horizontal scroll `ListView.builder`
- [ ] Each item: `CategoryChip` widget (from Phase 2.7)
- [ ] Categories from `homeNotifier.categories` or static data initially:
    - [ ] Burgers 🍔 (bg: #FFE8DC)
    - [ ] Pizza 🍕 (bg: danger-soft)
    - [ ] Asian 🍜 (bg: success-soft)
    - [ ] Salads 🥗 (bg: info-soft)
    - [ ] More categories from API
- [ ] Selected category highlighted with border or darker bg
- [ ] Tap category → filter "Hot right now" section

#### 10.2.5 Hot Right Now Section
- [ ] Section header: "Hot right now 🔥" + "See all"
- [ ] Horizontal scroll `ListView.builder`
- [ ] Each item: `DishCard` widget (from Phase 2.6)
- [ ] Loading state: `DishCardSkeleton` × 3
- [ ] Error state: `ErrorStateWidget`
- [ ] "Add to cart" on dish card → calls `cartRepository.addItem()`
- [ ] Heart on dish card → calls `dishRepository.toggleFavoriteDish()`

#### 10.2.6 Popular Restaurants Section
- [ ] Section header: "Popular restaurants" + "See all"
- [ ] Vertical list `ListView.builder` (non-scrolling, inside parent `CustomScrollView`)
- [ ] Each item: `RestaurantCard` widget (from Phase 2.5)
- [ ] Loading state: `RestaurantCardSkeleton` × 3
- [ ] Error state: `ErrorStateWidget`
- [ ] Tap restaurant → navigate to restaurant detail (future screen or bottom sheet)

#### 10.2.7 Layout & Scroll
- [ ] Whole screen uses `CustomScrollView` with slivers
    - [ ] `SliverToBoxAdapter` for header
    - [ ] `SliverToBoxAdapter` for greeting + search
    - [ ] `SliverToBoxAdapter` for promo card
    - [ ] `SliverToBoxAdapter` for categories
    - [ ] `SliverToBoxAdapter` for dishes section
    - [ ] `SliverList` for restaurants
- [ ] Safe area top padding
- [ ] Bottom padding for floating nav bar (68 + 18 + 18 = 104px)

#### 10.2.8 Loading & Error States
- [ ] Skeleton loading for entire screen on first load
- [ ] Pull-to-refresh (`RefreshIndicator`)
- [ ] Error snack bar on API failure with retry

---

## PHASE 11 — FEATURE: FAVORITES

### 11.1 State Management
- [ ] Create `favoritesNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] Fetch favorites on init
    - [ ] `selectedFilter` state: All / Dishes / Restaurants
    - [ ] `filterFavorites(type)` method
    - [ ] `removeFavorite(id)` method

### 11.2 UI — FavoritesScreen (`lib/features/favorites/favorites_screen.dart`)

#### 11.2.1 Header
- [ ] App bar: "Your favorites" title (headlineSmall, w700)
- [ ] No back button (main tab)

#### 11.2.2 Filter Chips Row
- [ ] Horizontal row of filter chips: "All", "Dishes", "Restaurants"
- [ ] Uses `FilterChip` or custom chip widget
- [ ] Selected: orange bg + white text
- [ ] Unselected: cream bg + dark text
- [ ] Single select only

#### 11.2.3 Favorites List
- [ ] If filter = "All" or "Restaurants": show `RestaurantCard` items (with filled heart)
- [ ] If filter = "Dishes": show `DishCard` items in a 2-column grid
- [ ] Heart icon always filled red on favorites screen
- [ ] Tap heart → remove from favorites (with confirmation snack bar + undo option)
- [ ] Loading state: skeleton loaders
- [ ] Empty state: `EmptyStateWidget`
    - [ ] Illustration placeholder
    - [ ] Title: "Nothing saved yet"
    - [ ] Subtitle: "Heart dishes and restaurants to save them here"
    - [ ] Button: "Explore food" → navigates to Home tab

#### 11.2.4 Bottom Padding
- [ ] 104px bottom padding for floating nav bar

---

## PHASE 12 — FEATURE: CART

### 12.1 State Management
- [ ] Create `cartNotifierProvider` (Riverpod Notifier)
    - [ ] State: `List<CartItemModel>`
    - [ ] Persist cart to SharedPreferences
    - [ ] `addItem(DishModel)` — increment qty if exists, else add
    - [ ] `removeItem(dishId)` — remove completely
    - [ ] `incrementQuantity(dishId)`
    - [ ] `decrementQuantity(dishId)` — remove if qty becomes 0
    - [ ] `clearCart()`
    - [ ] `applyPromoCode(code)` → validate → set discount
    - [ ] `promoCode` state (String?)
    - [ ] `discountRs` state (int, 0 if no promo)
    - [ ] Computed: `subtotalRs` → sum of all item totals
    - [ ] Computed: `deliveryFeeRs` → static Rs 50 (or from API)
    - [ ] Computed: `totalRs` → subtotal + delivery - discount
    - [ ] Computed: `itemCount` → total item count (for badge)

### 12.2 UI — CartScreen (`lib/features/cart/cart_screen.dart`)

#### 12.2.1 Header
- [ ] App bar: "Your cart" title (w700)
- [ ] "Clear all" text button (danger color) on right → shows confirmation dialog before clearing

#### 12.2.2 Empty Cart State
- [ ] `EmptyStateWidget`:
    - [ ] Illustration: shopping bag placeholder
    - [ ] Title: "Your cart is empty"
    - [ ] Subtitle: "Add items from restaurants to get started"
    - [ ] Button: "Browse food" → navigate to Home

#### 12.2.3 Cart Items List
- [ ] `ListView.builder` of cart items
- [ ] Each item card (cream bg, borderRadius 12):
    - [ ] Item image: 60x60 rounded (emoji fallback or `CachedNetworkImage`)
    - [ ] Name: 13px w500
    - [ ] Restaurant name: 11px muted
    - [ ] Price: 14px w700 (Rs format)
    - [ ] `QuantityControl` widget on right (from Phase 2.12)
    - [ ] Swipe to delete (Dismissible widget, red background)
- [ ] Animated add/remove with `AnimatedList` (or simple setState)

#### 12.2.4 Promo Code Row
- [ ] `TextFormField` with "Enter promo code" hint
- [ ] "Apply" button on right
- [ ] On valid code: show green check, discount applied message
- [ ] On invalid: show error message

#### 12.2.5 Price Summary Section
- [ ] Divider above section
- [ ] `PriceRow("Subtotal", Rs X)` (13px)
- [ ] `PriceRow("Delivery fee", Rs 50)` (13px)
- [ ] `PriceRow("Discount", −Rs X)` (13px, green if applied)
- [ ] Divider
- [ ] `PriceRow("Total", Rs X, isBold: true)` (15px w700)

#### 12.2.6 Checkout Button
- [ ] "Proceed to checkout" — `GradientButton` full width, 56px
- [ ] Disabled if cart is empty

#### 12.2.7 Layout
- [ ] `Scaffold` with `SafeArea`
- [ ] `SingleChildScrollView` or `Column` with flexible list
- [ ] Bottom padding for floating nav bar

---

## PHASE 13 — FEATURE: CHECKOUT / PAYMENT

### 13.1 State Management
- [ ] Create `checkoutNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] `selectedAddress` (AddressModel?)
    - [ ] `selectedPaymentMethod` (PaymentMethodModel?)
    - [ ] `specialInstructions` (String)
    - [ ] `selectedTipRs` (int, options: 0, 30, 50, 100)
    - [ ] `placeOrder()` → calls OrderRepository → navigates to tracking

### 13.2 UI — CheckoutScreen (`lib/features/checkout/checkout_screen.dart`)

#### 13.2.1 Header
- [ ] Back arrow (top-left)
- [ ] Title: "Checkout" (w700)

#### 13.2.2 Delivery Address Card
- [ ] Card with pin icon, address label, full address
- [ ] "Change" text button → shows address selection bottom sheet
- [ ] If no address: "Add address" button

#### 13.2.3 Payment Method Section
- [ ] Section title: "Payment method"
- [ ] Radio-style list of payment options
    - [ ] Credit/debit card (with last 4 digits)
    - [ ] Cash on delivery
    - [ ] Wallet/balance
- [ ] "Add payment method" option at bottom of list

#### 13.2.4 Order Summary
- [ ] Collapsed expandable section or always visible
- [ ] List of items (name + qty + price)
- [ ] Subtotal, delivery, discount, total

#### 13.2.5 Special Instructions
- [ ] `TextFormField` multiline, max 200 chars
- [ ] Hint: "Any special requests for the kitchen?"
- [ ] Character counter

#### 13.2.6 Tip Selection
- [ ] Title: "Add a tip for your courier"
- [ ] Row of pill buttons: Rs 0, Rs 30, Rs 50, Rs 100
- [ ] Selected pill: orange bg, white text
- [ ] Unselected: cream bg, dark text

#### 13.2.7 Place Order Button
- [ ] "Place order — Rs [total]" — `GradientButton` full width, 56px
- [ ] Loading state while API call is in progress
- [ ] On success → `AppNavigator.toTracking(context, orderId)`

---

## PHASE 14 — FEATURE: PROFILE

### 14.1 State Management
- [ ] Create `profileNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] Fetch user profile on init
    - [ ] `updateProfile(name, phone)` method
    - [ ] `fetchOrderHistory()` method
    - [ ] `logout()` → clears storage → navigates to auth

### 14.2 UI — ProfileScreen (`lib/features/profile/profile_screen.dart`)

#### 14.2.1 Header / Avatar Section
- [ ] Gradient bg container (primaryGradientStart → End), height ~200
- [ ] Avatar: 80x80 circle with gradient bg, initials (if no photo) or `CachedNetworkImage`
- [ ] Edit icon overlay (small pen icon on avatar bottom-right)
- [ ] Name: 18px w500 (below avatar)
- [ ] Email: 13px secondary

#### 14.2.2 Stats Row
- [ ] 3-column row below header:
    - [ ] "Orders" count
    - [ ] "Favorites" count
    - [ ] "Points" count
- [ ] Each: big number (20px w700) + label (11px muted)
- [ ] Dividers between columns

#### 14.2.3 Account Section (menu items)
- [ ] Section label: "Account" (12px w600 muted, uppercase)
- [ ] Menu item row: icon + label + chevron-right
    - [ ] Edit profile (user icon)
    - [ ] Order history (clock icon)
    - [ ] Saved addresses (map-pin icon)
    - [ ] Payment methods (credit-card icon)

#### 14.2.4 Settings Section
- [ ] Section label: "Settings"
- [ ] Menu rows:
    - [ ] Notifications (bell icon)
    - [ ] Invite & earn (gift icon)
    - [ ] Preferences (sliders icon)

#### 14.2.5 Other Section
- [ ] Help & support (help icon)
- [ ] Log out (logout icon, red danger text, no chevron)
    - [ ] Tap → show confirmation bottom sheet "Are you sure?"
    - [ ] Confirm → `profileNotifier.logout()`

#### 14.2.6 Menu Item Row Widget
- [ ] Extract `ProfileMenuItem` StatelessWidget
    - [ ] Props: `icon`, `label`, `onTap`, `isDanger`, `trailing` (optional Widget)
    - [ ] Normal: dark icon + primary text + grey chevron
    - [ ] Danger: red icon + red text + no chevron
    - [ ] Hover/pressed state: cream bg tint

---

## PHASE 15 — FEATURE: ORDER TRACKING

### 15.1 State Management
- [ ] Create `trackingNotifierProvider` (Riverpod AsyncNotifier)
    - [ ] Fetch active order on init
    - [ ] Poll every 15s for status updates (or use SSE/websocket)
    - [ ] `currentStatus` (OrderStatus)
    - [ ] `etaMinutes` (int)
    - [ ] `courierLocation` (lat/lng)

### 15.2 UI — OrderTrackingScreen (`lib/features/tracking/tracking_screen.dart`)

#### 15.2.1 Map View (top half)
- [ ] Placeholder container (cream bg, map pin icon centered) for now
- [ ] Use `flutter_map` + OpenStreetMap tiles (free, no API key) — add `flutter_map: ^7.0.2` and `latlong2: ^0.9.1` to pubspec.yaml
- [ ] Restaurant marker and courier marker

#### 15.2.2 Order Card (bottom half, draggable bottom sheet)
- [ ] Handle bar at top of card
- [ ] ETA text: "Arriving in ~[X] minutes" (bold)
- [ ] Restaurant name + order ID

#### 15.2.3 Timeline Steps
- [ ] 4 steps: "Order placed" → "Preparing" → "On the way" → "Delivered"
- [ ] Each step: circle indicator (filled=done, orange=current, grey=upcoming) + label + timestamp
- [ ] Animated progress line between steps

#### 15.2.4 Courier Info Row
- [ ] Courier avatar (circle, initials fallback)
- [ ] Courier name + "Your courier"
- [ ] Call button (phone icon, outlined circle)
- [ ] Message button (chat icon, outlined circle)

#### 15.2.5 Back/Close
- [ ] Back arrow in top-left (over the map)

---

## PHASE 16 — FEATURE: CHAT SUPPORT

### 16.1 State Management
- [ ] Create `chatNotifierProvider` (Riverpod Notifier)
    - [ ] `messages` (List<ChatMessageModel>)
    - [ ] `sendMessage(text)` → adds user message → calls bot API → adds bot reply
    - [ ] `sendQuickReply(text)` → same as sendMessage
    - [ ] Bot greeting on init: "Hi! I'm your Crave assistant. How can I help?"
    - [ ] Quick replies on init: ["Track my order", "Cancel order", "Payment issue", "Other"]

### 16.2 UI — ChatScreen (`lib/features/chat/chat_screen.dart`)

#### 16.2.1 Header
- [ ] Back button
- [ ] "Support" title
- [ ] Bot avatar (orange circle with robot/chat emoji)
- [ ] "Online" status indicator (green dot)

#### 16.2.2 Messages List
- [ ] `ListView.builder` reversed (latest message at bottom)
- [ ] Bot message bubble: cream bg, left-aligned, bot avatar left
- [ ] User message bubble: orange gradient bg, white text, right-aligned
- [ ] Timestamp below each message (12px muted)
- [ ] Auto-scroll to bottom on new message

#### 16.2.3 Quick Reply Chips
- [ ] Row of tappable chips above input bar
- [ ] Only show when bot provides quick replies
- [ ] Disappear after user taps one

#### 16.2.4 Input Bar
- [ ] `TextFormField` + mic icon + send button
- [ ] Send button: orange circle, arrow-up icon
- [ ] Disabled send when field is empty
- [ ] Loading indicator when bot is "typing" (3-dot animation)

---

## PHASE 17 — VALIDATORS & UTILITIES

### 17.1 Validators (`lib/core/utils/validators.dart`)
- [ ] Consolidate all validation from `auth_screen.dart` into this file
- [ ] `validateName(String?)` → not empty, min 2 chars
- [ ] `validateEmail(String?)` → regex
- [ ] `validatePhone(String?)` → Pakistani mobile format
- [ ] `validatePassword(String?)` → min 6 chars
- [ ] `validateRequired(String?, fieldName)` → generic not-empty check
- [ ] `validatePromoCode(String?)` → not empty, uppercase

### 17.2 Extensions (`lib/core/utils/extensions.dart`)
- [ ] `extension StringExtension on String` → `toTitleCase()`
- [ ] `extension IntExtension on int` → `toRsFormat()` → "Rs 1,200"
- [ ] `extension DateTimeExtension on DateTime` → `toTimeAgo()`, `toOrderDate()`
- [ ] `extension ColorExtension on Color` → `withOpacityValue(double)` (replaces deprecated `withOpacity`)
- [ ] `extension ContextExtension on BuildContext` → `colors` shorthand for `Theme.of(context).extension<AppThemeColors>()!`

### 17.3 Helpers (`lib/core/utils/helpers.dart`)
- [ ] `formatRs(int amount)` → "Rs 1,200" (using intl package)
- [ ] `formatEta(int minutes)` → "25 min" or "1 hr 10 min"
- [ ] `getInitials(String name)` → "JD" from "John Doe"
- [ ] `showErrorSnackBar(BuildContext, String message)`
- [ ] `showSuccessSnackBar(BuildContext, String message)`
- [ ] `showConfirmationDialog(BuildContext, title, body)` → Future<bool>

---

## PHASE 18 — POLISH & ANIMATIONS

### 18.1 Page Transitions
- [ ] Custom `CustomTransitionPage` for go_router routes
    - [ ] Splash → Onboarding: fade
    - [ ] Onboarding → Auth: slide from right
    - [ ] Auth → Home: fade scale
    - [ ] Home → Checkout: slide from bottom
    - [ ] Home → Tracking: slide from bottom

### 18.2 Micro-interactions
- [ ] Heart button tap: scale animation (shrink then bounce back)
- [ ] Add to cart tap: brief scale + color flash
- [ ] `QuantityControl` increment/decrement: slide-fade number transition
- [ ] Bottom nav tab switch: animated icon scale
- [ ] Promo code apply: success shake or pulse animation

### 18.3 Skeleton Loading
- [ ] Home screen: show skeletons while data loads (3 dish cards + 2 restaurant cards)
- [ ] Favorites screen: show skeleton grid
- [ ] Cart screen: show item skeletons
- [ ] Profile screen: show header + stats skeleton

### 18.4 Error Handling
- [ ] Global error boundary (GoRouter `errorBuilder`)
- [ ] Network error banner at top of screen (no connection)
- [ ] Retry mechanism on all API calls (dio retry interceptor)
- [ ] Snack bar for non-critical errors (add to cart fail, favorite toggle fail)
- [ ] Full error screen for critical failures (auth fail, order fail)

### 18.5 Responsiveness
- [ ] Test on small screen (5" — 360×640)
- [ ] Test on medium screen (6" — 390×844)
- [ ] Test on large screen (6.7" — 430×932)
- [ ] Test on tablet (768×1024) — optional
- [ ] Ensure no pixel overflow in auth screen with keyboard open (`resizeToAvoidBottomInset: true`)
- [ ] Ensure list items don't overflow on small screens

---

## PHASE 19 — TESTING

### 19.1 Unit Tests
- [ ] Test `AuthRepository.login()` — success and failure cases
- [ ] Test `CartRepository` — add, remove, clear, quantity logic
- [ ] Test `validators.dart` — all validators
- [ ] Test `formatRs()`, `formatEta()`, `getInitials()` helpers
- [ ] Test `CartItemModel.totalPriceRs` computation
- [ ] Test `cartNotifier.subtotalRs` and `totalRs` computations

### 19.2 Widget Tests
- [ ] Test `PrimaryButton` renders correctly and triggers callback
- [ ] Test `QuantityControl` increments and decrements
- [ ] Test `CartScreen` shows empty state when cart is empty
- [ ] Test `AuthScreen` shows name field only in signup mode
- [ ] Test form validation in `AuthScreen`

### 19.3 Integration Tests
- [ ] Auth flow: open app → skip onboarding → login → see home
- [ ] Cart flow: add dish → open cart → change quantity → checkout
- [ ] Favorites flow: heart a dish → open favorites → see it there

---

## PHASE 20 — ADMIN PANEL

> **Scope:** Single-admin, FYP-appropriate. Material 3, responsive layout, reuses AppTheme.
> No role-based permissions, multi-admin, audit logs, or enterprise features.
> Admin panel is a **separate entry point** — not shown to regular users.

### 20.0 Admin Setup

#### 20.0.1 Entry Point
- [ ] Create `lib/features/admin/` directory and all subdirectories
- [ ] Create `lib/main_admin.dart` — separate `main()` with its own `runApp(AdminApp())`
    - [ ] Same `ProviderScope` + `AppTheme` as main app
    - [ ] Home: `AdminLoginScreen` (no splash, no onboarding)
- [ ] Add `admin` route constants to `AppRoutes`:
    - [ ] `static const adminLogin = '/admin/login'`
    - [ ] `static const adminShell = '/admin/shell'`
    - [ ] `static const adminDashboard = '/admin/dashboard'`
    - [ ] `static const adminDishes = '/admin/dishes'`
    - [ ] `static const adminDishForm = '/admin/dishes/form'`
    - [ ] `static const adminCategories = '/admin/categories'`
    - [ ] `static const adminCategoryForm = '/admin/categories/form'`
    - [ ] `static const adminOrders = '/admin/orders'`
    - [ ] `static const adminOrderDetail = '/admin/orders/detail'`
- [ ] Add `AdminNavigator` static helper class (`lib/core/navigation/admin_navigator.dart`)
    - [ ] `toAdminDashboard(context)` → pushAndRemoveUntil
    - [ ] `toAdminDishForm(context, {DishModel? dish})` → push (null = add, non-null = edit)
    - [ ] `toCategoryForm(context, {CategoryModel? category})` → push
    - [ ] `toOrderDetail(context, {required String orderId})` → push
    - [ ] `backToAdminShell(context)` → pop

#### 20.0.2 Admin Auth
- [ ] Reuse Supabase auth — admin is just a regular Supabase user with `role = 'admin'` metadata
- [ ] Create `lib/features/admin/auth/admin_login_screen.dart`
    - [ ] Email + password fields (reuse `CustomTextField` from Phase 8)
    - [ ] "Admin Login" gradient button
    - [ ] On success: check `user.userMetadata['role'] == 'admin'` — if not admin, show error and sign out
    - [ ] On success + admin: `AdminNavigator.toAdminDashboard(context)`
- [ ] Create `adminAuthNotifierProvider` (Riverpod NotifierProvider)
    - [ ] `login(email, password)` → Supabase signIn → verify role → navigate
    - [ ] Expose loading/error state

#### 20.0.3 Admin Shell
- [ ] Create `lib/features/admin/shell/admin_shell_screen.dart`
    - [ ] `NavigationRail` on left for tablet / `BottomNavigationBar` on phone (responsive)
    - [ ] 4 tabs: Dashboard, Dishes, Categories, Orders
    - [ ] Uses `IndexedStack` to preserve tab state
    - [ ] Top app bar: "crave. Admin" title + logout icon button

---

### 20.1 Dashboard

#### 20.1.1 State Management
- [ ] Create `lib/features/admin/dashboard/dashboard_notifier.dart`
- [ ] Create `adminDashboardNotifierProvider` (Riverpod NotifierProvider)
    - [ ] `totalUsers` (int)
    - [ ] `totalOrders` (int)
    - [ ] `totalRevenue` (int — sum of all order totals in Rs)
    - [ ] `totalDishes` (int)
    - [ ] `recentOrders` (List<OrderModel> — last 5)
    - [ ] `fetchAll()` — fetches all stats in parallel

#### 20.1.2 UI — DashboardScreen (`lib/features/admin/dashboard/dashboard_screen.dart`)
- [ ] Summary cards row (responsive: 2-col on phone, 4-col on tablet):
    - [ ] `_StatCard("Total Users", totalUsers, Icons.people_rounded, cs.primary)`
    - [ ] `_StatCard("Total Orders", totalOrders, Icons.receipt_long_rounded, success)`
    - [ ] `_StatCard("Revenue", "Rs X", Icons.payments_rounded, warning)`
    - [ ] `_StatCard("Total Dishes", totalDishes, Icons.restaurant_menu_rounded, cs.tertiary)`
- [ ] Extract `_StatCard` widget:
    - [ ] Props: `title`, `value` (String), `icon`, `color`
    - [ ] Card with colored icon circle + big value text + label
    - [ ] `ac.cardShadow` + `ac.surface` bg
- [ ] Recent orders section:
    - [ ] Section header "Recent Orders"
    - [ ] `ListView` of last 5 orders (non-scrolling, inside parent scroll)
    - [ ] Each row: order ID (truncated) + customer name + total + status chip
- [ ] Quick actions section:
    - [ ] "Add Dish" button → `AdminNavigator.toAdminDishForm(context)`
    - [ ] "Add Category" button → `AdminNavigator.toCategoryForm(context)`
- [ ] Loading state: shimmer skeleton for stat cards + list
- [ ] Error state: `ErrorStateWidget` with retry

---

### 20.2 Dish Management

#### 20.2.1 Model
- [ ] `DishModel` already created (Phase 2/3) — reuse as-is

#### 20.2.2 State Management
- [ ] Create `lib/features/admin/dishes/admin_dishes_notifier.dart`
- [ ] Create `adminDishesNotifierProvider` (Riverpod NotifierProvider)
    - [ ] `dishes` (List<DishModel>)
    - [ ] `searchQuery` (String)
    - [ ] `filteredDishes` getter — filter by name/restaurant/tag
    - [ ] `fetchDishes()` — load from Supabase
    - [ ] `addDish(DishModel)` → POST to API → refresh list
    - [ ] `updateDish(DishModel)` → PUT to API → refresh
    - [ ] `deleteDish(String id)` → DELETE → refresh
    - [ ] Expose loading/error state

#### 20.2.3 UI — DishListScreen (`lib/features/admin/dishes/dish_list_screen.dart`)
- [ ] App bar: "Dishes" + FAB (add icon) → `AdminNavigator.toAdminDishForm(context)`
- [ ] Search bar (`CustomSearchBar`, readOnly: false, no filter button)
- [ ] Dish list: `ListView.builder` of admin dish rows
    - [ ] Each row: thumbnail 56×56 + name + price + tag + edit icon + delete icon
    - [ ] Delete: show `showConfirmationDialog` before calling `deleteDish()`
    - [ ] Edit: `AdminNavigator.toAdminDishForm(context, dish: dish)`
- [ ] Loading: `DishCardSkeleton` × 5 in list layout
- [ ] Empty: `EmptyStateWidget(title: 'No dishes yet', subtitle: 'Add your first dish')`
- [ ] Error: `ErrorStateWidget` with retry

#### 20.2.4 UI — DishFormScreen (`lib/features/admin/dishes/dish_form_screen.dart`)
- [ ] App bar: "Add Dish" / "Edit Dish" + back button
- [ ] Fields (all validated):
    - [ ] Dish Name (required, min 2 chars)
    - [ ] Restaurant Name (required)
    - [ ] Price in Rs (number input, required, > 0)
    - [ ] Calories (number input, required, > 0)
    - [ ] Tag / Badge label (optional, e.g. "BESTSELLER")
    - [ ] Image URL (optional, validated as URL if provided)
- [ ] Image preview: if URL is valid, show `CachedNetworkImage` 200px tall
- [ ] Submit button: `GradientButton("Save Dish")` with `isLoading` state
- [ ] On save: call `addDish()` or `updateDish()` → pop on success → show success snackbar
- [ ] On error: show `showErrorSnackBar`
- [ ] Validation: use `Validators` class

---

### 20.3 Category Management

#### 20.3.1 Model
- [ ] `CategoryModel` already in plan (Phase 3.4) — create now if not yet done:
    ```dart
    class CategoryModel {
      final String id;
      final String name;
      final String emoji;
      final Color bgColor;
      factory CategoryModel.fromJson(Map<String, dynamic> json);
      Map<String, dynamic> toJson();
    }
    ```

#### 20.3.2 State Management
- [ ] Create `lib/features/admin/categories/admin_categories_notifier.dart`
- [ ] Create `adminCategoriesNotifierProvider` (Riverpod NotifierProvider)
    - [ ] `categories` (List<CategoryModel>)
    - [ ] `searchQuery` (String)
    - [ ] `filteredCategories` getter
    - [ ] `fetchCategories()`
    - [ ] `addCategory(CategoryModel)` → POST → refresh
    - [ ] `updateCategory(CategoryModel)` → PUT → refresh
    - [ ] `deleteCategory(String id)` → DELETE → refresh

#### 20.3.3 UI — CategoryListScreen (`lib/features/admin/categories/category_list_screen.dart`)
- [ ] App bar: "Categories" + FAB (add icon)
- [ ] Search bar (filter by name)
- [ ] Grid: `GridView.builder` 2-col, each card:
    - [ ] Emoji (centered, 32px) + category name + edit + delete icons
    - [ ] Background: `CategoryModel.bgColor`, radius 12
- [ ] Loading: shimmer grid
- [ ] Empty: `EmptyStateWidget`
- [ ] Error: `ErrorStateWidget`

#### 20.3.4 UI — CategoryFormScreen (`lib/features/admin/categories/category_form_screen.dart`)
- [ ] Fields:
    - [ ] Category Name (required)
    - [ ] Emoji (required, 1 character, emoji picker or text input)
    - [ ] Background Color — row of preset color chips to pick from:
        - [ ] `[Color(0xFFFFE8DC), Color(0xFFE8F4E5), Color(0xFFFFF1D6), Color(0xFFE8ECF8), Color(0xFFF5E8F8)]`
    - [ ] Color preview chip (shows selected color with emoji)
- [ ] Submit: `GradientButton("Save Category")`
- [ ] Validation: name required, emoji required and exactly 1 grapheme cluster

---

### 20.4 Order Management

#### 20.4.1 State Management
- [ ] Create `lib/features/admin/orders/admin_orders_notifier.dart`
- [ ] Create `adminOrdersNotifierProvider` (Riverpod NotifierProvider)
    - [ ] `orders` (List<OrderModel>)
    - [ ] `searchQuery` (String)
    - [ ] `statusFilter` (OrderStatus? — null = all)
    - [ ] `filteredOrders` getter
    - [ ] `fetchOrders()` — all orders from API
    - [ ] `updateStatus(String orderId, OrderStatus status)` → PATCH → refresh
    - [ ] `cancelOrder(String orderId)` → sets status to cancelled → refresh

#### 20.4.2 UI — OrderListScreen (`lib/features/admin/orders/order_list_screen.dart`)
- [ ] App bar: "Orders"
- [ ] Search bar: filter by order ID or customer name
- [ ] Status filter chips: All / Placed / Preparing / On the way / Delivered
    - [ ] Horizontal scrollable row of `FilterChip`
- [ ] Order list `ListView.builder`:
    - [ ] Each row: order ID (short) + customer name + total + `_StatusChip` + chevron-right
    - [ ] `_StatusChip`: colored pill using `OrderStatus`
        - [ ] Placed → `cs.primaryContainer` bg
        - [ ] Preparing → warning bg
        - [ ] On the way → `cs.tertiaryContainer` bg
        - [ ] Delivered → success bg
- [ ] Loading: shimmer list rows
- [ ] Empty: `EmptyStateWidget("No orders found", "Try adjusting your filters")`
- [ ] Error: `ErrorStateWidget`

#### 20.4.3 UI — OrderDetailScreen (`lib/features/admin/orders/order_detail_screen.dart`)
- [ ] App bar: "Order #[shortId]" + back button
- [ ] Section "Customer Info": name, email, phone
- [ ] Section "Delivery Address": full address
- [ ] Section "Order Items": list of items (name + qty + price)
- [ ] Section "Price Summary": `PriceRow` for subtotal, delivery, discount, total
- [ ] Section "Update Status":
    - [ ] Current status chip
    - [ ] Dropdown or segmented button: Placed / Preparing / On the way / Delivered
    - [ ] "Update Status" `PrimaryButton`
    - [ ] "Cancel Order" `OutlinedPillButton` (danger red borderColor, danger red textColor)
        - [ ] Show `showConfirmationDialog` before cancelling
- [ ] Loading state for status update button

---

### 20.5 Admin Shared Widgets (`lib/features/admin/widgets/`)

- [ ] `AdminStatCard` — colored stat card for dashboard
    - [ ] Props: `title`, `value`, `icon`, `color`
- [ ] `AdminListTile` — reusable list row for dish/category/order lists
    - [ ] Props: `leading`, `title`, `subtitle`, `trailing`, `onTap`, `onEdit`, `onDelete`
- [ ] `StatusChip` — colored pill for order status
    - [ ] Props: `status` (OrderStatus)
    - [ ] Returns correct bg color and label per status
- [ ] `ColorPickerRow` — horizontal row of selectable color circles
    - [ ] Props: `colors`, `selected`, `onSelect`
- [ ] `AdminSectionLabel` — uppercase muted section label (12px, letterSpacing 1.2)
    - [ ] Props: `label`

---

### 20.6 Admin Responsiveness
- [ ] `AdminShellScreen` uses `LayoutBuilder`:
    - [ ] Width < 600px → `BottomNavigationBar` (phone layout)
    - [ ] Width ≥ 600px → `NavigationRail` on left + content on right (tablet layout)
- [ ] Dashboard stat cards: `GridView` 2-col on phone, 4-col on tablet
- [ ] Form screens: max width 600px centered on tablet
- [ ] List screens: max width 800px centered on tablet

---

### 20.7 Admin Navigation (AppNavigator update)
- [ ] Add to `AppNavigator`:
    - [ ] `toAdminLogin(context)` → `Navigator.pushAndRemoveUntil(... AdminLoginScreen ...)`
    - [ ] (individual admin screen navigation in `AdminNavigator`)

---

## DELIVERABLES

---

### Complete Folder Structure (target state)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_strings.dart
│   │   └── env.dart
│   ├── utils/
│   │   ├── helpers.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   ├── navigation/
│   │   ├── app_routes.dart
│   │   └── app_navigator.dart
│   ├── providers/
│   │   ├── dio_provider.dart
│   │   ├── shared_prefs_provider.dart
│   │   └── auth_state_provider.dart
│   └── widgets/
│       ├── primary_button.dart
│       ├── gradient_button.dart
│       ├── outlined_pill_button.dart
│       ├── custom_bottom_nav_bar.dart
│       ├── restaurant_card.dart
│       ├── dish_card.dart
│       ├── category_chip.dart
│       ├── custom_search_bar.dart
│       ├── custom_text_field.dart
│       ├── quantity_control.dart
│       ├── section_header.dart
│       ├── price_row.dart
│       ├── skeleton_loader.dart
│       ├── error_state_widget.dart
│       └── empty_state_widget.dart
├── models/
│   ├── user_model.dart
│   ├── restaurant_model.dart
│   ├── dish_model.dart
│   ├── category_model.dart
│   ├── cart_item_model.dart
│   ├── order_model.dart
│   ├── address_model.dart
│   ├── payment_method_model.dart
│   └── chat_message_model.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── repositories/
│   ├── auth_repository.dart
│   ├── restaurant_repository.dart
│   ├── dish_repository.dart
│   ├── cart_repository.dart
│   ├── order_repository.dart
│   └── profile_repository.dart
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── data/
│   │   │   └── onboarding_data.dart
│   │   └── widgets/
│   │       └── pageview_design.dart
│   ├── auth/
│   │   ├── auth_screen.dart
│   │   └── widgets/
│   │       └── auth_text.dart
│   ├── shell/
│   │   └── shell_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       └── promo_card.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── checkout/
│   │   └── checkout_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── widgets/
│   │       └── profile_menu_item.dart
│   ├── tracking/
│   │   └── tracking_screen.dart
│   └── chat/
│       └── chat_screen.dart
└── theme/
    └── app_theme.dart

assets/
├── images/
│   ├── image1.jpg
│   ├── image2.jpg
│   └── image3.jpg
└── icons/
    └── (svg icons if any)

.env
.env.example
.gitignore
```

---

### Required Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8          # existing
  google_fonts: ^8.1.0              # existing
  loading_animation_widget: ^1.3.0  # existing
  smooth_page_indicator: ^2.0.1     # existing
  animated_toggle_switch: ^0.8.7    # existing
  flutter_dotenv: ^5.1.0            # NEW — env vars
  flutter_riverpod: ^2.6.1          # NEW — state management
  dio: ^5.7.0                       # NEW — HTTP client
  shared_preferences: ^2.3.2        # NEW — local storage
  cached_network_image: ^3.4.1      # NEW — network images
  flutter_svg: ^2.0.10              # NEW — SVG icons
  intl: ^0.19.0                     # NEW — number/date formatting
  shimmer: ^3.0.0                   # NEW — skeleton loading
  gap: ^3.0.1                       # NEW — spacing utility

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0             # existing
  build_runner: ^2.4.12             # NEW — code generation
  riverpod_annotation: ^2.6.1       # NEW — Riverpod codegen
  riverpod_generator: ^2.4.3        # NEW — Riverpod codegen
```

---

### Development Order (exact sequence)

```
1.  PHASE 0   — Project Setup & Architecture Refactor
2.  PHASE 1   — Design System (AppColors, AppTheme updates, AppDimensions)
3.  PHASE 2   — Core Shared Widgets
4.  PHASE 3   — Models (all 9 models)
5.  PHASE 4   — Services (ApiService, AuthService, StorageService)
6.  PHASE 5   — Repositories (all 6)
7.  PHASE 6   — Fix & polish Splash Screen
8.  PHASE 7   — Fix & polish Onboarding Screen
9.  PHASE 9   — Navigation Shell (bottom nav)
10. PHASE 8   — Fix & complete Auth Screen
11. PHASE 10  — Home Screen (main feature)
12. PHASE 12  — Cart Screen
13. PHASE 11  — Favorites Screen
14. PHASE 14  — Profile Screen
15. PHASE 13  — Checkout Screen
16. PHASE 15  — Order Tracking Screen
17. PHASE 16  — Chat Support Screen
18. PHASE 17  — Validators & Utilities (refactor)
19. PHASE 18  — Polish & Animations
20. PHASE 19  — Testing
21. PHASE 20  — Admin Panel (Dashboard, Dishes, Categories, Orders)
```

---

### Feature Dependency Map

```
Splash
  └── needs: StorageService (check onboarding seen), go_router

Onboarding
  └── needs: OnboardModel, OnboardingData, StorageService

Auth
  └── needs: AuthRepository, AuthService, StorageService, Validators
  └── navigates to: Shell (Home)

Shell (Bottom Nav)
  └── needs: CartNotifier (badge count), go_router ShellRoute
  └── contains: Home, Favorites, Cart, Profile

Home
  └── needs: RestaurantRepository, DishRepository, CategoryModel
  └── uses: RestaurantCard, DishCard, CategoryChip, SearchBar, PromoCard
  └── actions → Cart (add item), Favorites (toggle), Tracking (view order)

Favorites
  └── needs: DishRepository.getFavorites, RestaurantRepository.getFavorites
  └── uses: DishCard, RestaurantCard, EmptyStateWidget

Cart
  └── needs: CartRepository (persisted Riverpod Notifier)
  └── uses: QuantityControl, PriceRow, GradientButton
  └── navigates to: Checkout

Checkout
  └── needs: CartNotifier (items + total), ProfileRepository (addresses, payment)
  └── needs: OrderRepository (place order)
  └── navigates to: OrderTracking

Profile
  └── needs: ProfileRepository (user, addresses, payments, orders)
  └── navigates to: OrderTracking (from order history)

OrderTracking
  └── needs: OrderRepository.trackOrder
  └── uses: flutter_map + OpenStreetMap (no key needed)

Chat
  └── needs: ApiService (bot endpoint) or static bot logic initially
```

---

### Complexity Estimates

| Module | Complexity | Reason |
|--------|-----------|--------|
| Phase 0 — Setup & Refactor | **Medium** | Many files to move and rewire |
| Phase 1 — Design System | **Easy** | Mostly constants, low risk |
| Phase 2 — Shared Widgets | **Medium** | Many widgets, get details right |
| Phase 3 — Models | **Easy** | Pure data classes |
| Phase 4 — Services | **Medium** | Dio config + interceptors |
| Phase 5 — Repositories | **Medium** | Glue layer, straightforward |
| Phase 6 — Splash | **Easy** | Already 80% done |
| Phase 7 — Onboarding | **Easy** | Already 75% done, minor fixes |
| Phase 8 — Auth | **Medium** | Many fields, validation, state |
| Phase 9 — Shell | **Easy** | nav bar + ShellRoute |
| Phase 10 — Home | **Hard** | Most complex screen, many sections |
| Phase 11 — Favorites | **Easy** | Reuses existing widgets |
| Phase 12 — Cart | **Medium** | State logic + swipe-to-delete |
| Phase 13 — Checkout | **Medium** | Multi-section, address/payment |
| Phase 14 — Profile | **Medium** | Header gradient + menu rows |
| Phase 15 — Tracking | **Hard** | Map placeholder, timeline, polling |
| Phase 16 — Chat | **Medium** | Message bubbles, quick replies |
| Phase 17 — Utils | **Easy** | Pure functions |
| Phase 18 — Animations | **Hard** | Requires fine-tuning |
| Phase 19 — Testing | **Medium** | Time-consuming but straightforward |

---

### Missing Information / Ambiguities

| # | Item | Impact |
|---|------|--------|
| 1 | No backend API defined — endpoints, auth method (JWT/session?), response shapes all unknown | **HIGH** — repositories can be built with mock data first |
| 2 | Phone number format for login — is it +92 3xx or 03xx? Affects validator | Medium |
| 3 | Google/Apple auth — OAuth client IDs not in .env.example | Medium |
| 4 | Map integration — using flutter_map + OpenStreetMap (no API key, free tiles) | Low — no setup needed |
| 5 | Promo codes — no backend logic described; implement as static codes initially | Low |
| 6 | "Crave+ membership" — no info on pricing, tiers, or how it's earned | Low (UI only for now) |
| 7 | Chat bot — no AI API defined; implement as rule-based chatbot initially | Medium |
| 8 | Push notifications — no FCM setup described | Low (post-MVP) |
| 9 | Currency — design shows USD `$` in dish card code but description says Rs; confirm Rs throughout | Medium |
| 10 | Missing onboarding images (image1/2/3.jpg content) — assumed already in assets/ | Low (verify) |
