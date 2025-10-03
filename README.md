# 📊 Crypto Portfolio Tracker

A Flutter application to track cryptocurrency portfolio using **CoinGecko API**, built with **BLoC state management** and local persistence.  
Includes polished UI, animations, error handling, and bonus features.

---

## 🎯 Features
- **Splash Screen** with fade animation  
- **Add/Remove Assets** (search coins, enter quantity)  
- **Portfolio Persistence** (stored locally with SharedPreferences)  
- **Real-Time Prices** (via CoinGecko API)  
- **Total Portfolio Value** prominently displayed  
- **Pull-to-Refresh** for live updates  
- **Sorting** by Name or Holding Value  
- **Price Change Indicator** (green 🔼 / red 🔽 since last refresh)  
- **Coin Logos** fetched from API  
- **Swipe-to-Delete** for assets  
- **Periodic Auto Refresh** (every 3 mins)  
- **Error Handling** with retry & global SnackBars  
- **Modern UI** (gradient background, shadow cards, smooth animations)

---

## 🏗 Architecture
**Layered Clean Approach**:
- **Data Layer**
  - `CoinGeckoApi` → Networking (Dio)
  - `PortfolioRepo` → Persistence + API integration
- **Logic Layer**
  - `PortfolioBloc` → Portfolio state, refresh, add/remove/sort, error handling
- **UI Layer**
  - `PortfolioPage` → Portfolio dashboard
  - `AddAssetSheet` → Add asset modal
  - `HoldingTile` → Asset list item with logo & indicators

---

## 🔧 Tech & Packages
- **flutter_bloc** → State management  
- **dio** → API calls  
- **shared_preferences** → Local storage  
- **intl** → Currency formatting  
- **equatable** → Value equality for Bloc states  
- **cached_network_image** → Coin logos  

---

## ⚡ Error Handling
- API & storage errors caught in Bloc → state set as `failed`  
- **BlocListener** in UI shows `SnackBar` with error message  
- Retry button shown on failure UI  
- Silent fallback to cached prices if network fails  

---

## 📦 Setup
1. Clone repo  
   ```bash
   git clone https://github.com/your-username/crypto_portfolio_tracker.git
   cd crypto_portfolio_tracker
