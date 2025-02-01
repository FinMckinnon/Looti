# Looti Addon

The Looti addon is a simple scrolling loot notification tool for looted items and money.

## Installation
To install Looti, download **Looti.zip** then place it into your Addons folder for your World of Warcraft installation, regularly at  ```C:\Program Files (x86)\World of Warcraft\#GAMEVERSION#\Interface\AddOns``` where GAMEVERSION represents your Game Version of World of Warcraft.

# Looti - Lightweight Loot Notification System

Looti is a **super lightweight**, **simplistic**, scrolling loot notification system with customizable settings. The goal of this addon is to provide a **barebones loot notification system** using only **core WoW and Lua commands**, ensuring **minimal maintenance** and **low risk of errors** after all features are implemented.

## Accessing Settings
To open the settings panel, use the command:
```sh
/looti
```

---
## Enable Notifications
- Easily toggle notifications **for loot or money** (gold, silver, copper).
- Configure what types of loot notifications you want to see.
---

## Notification Threshold (Rarity)
Define a **rarity threshold** to control which items trigger notifications.  
Move the slider to your desired rarity—only items **at or above** that rarity will be displayed.

### Rarity Levels:
| Value | Rarity  | Color       |
|-------|---------|------------|
| **0** | Poor    | ⚫ Gray     |
| **1** | Common  | ⚪ White    |
| **2** | Uncommon | 🟢 Green   |
| **3** | Rare    | 🔵 Blue    |
| **4** | Epic    | 🟣 Purple  |
| **5** | Legendary | 🟠 Orange |
| **6** | Artifact | 🟡 Light Gold |
| **7** | Heirloom | 🔵 Blizzard Blue |

---
## Display Settings
Looti provides several customization options to fit your UI preferences:

- **Moveable notifications frame** – Place notifications anywhere on your screen.
- **Adjust notification direction** – Choose whether notifications scroll **up** or **down**.
- **Toggle background transparency** – Make notifications stand out or keep your screen clean.
- **Control display timing**:
  - **Set notification duration** – How long each notification stays visible.
  - **Adjust delay between notifications** – Customize how quickly new notifications appear.
---

## Test Looti
Once you save your settings with the save button, use the test looti button to test out the notifications.
