## 📌 Fungsi ESX_KEDIP

1. **Render Ulang (Solo Session)**
2. **Freeze Player Saat Kedip**
3. **Notifikasi ke Sekitar**
   
## 🛡️ Anti Abuse

* 🚫 **Cooldown**
* 🚫 **Tidak bisa saat mati/pingsan**
* 🚫 **Tidak bisa di kendaraan**
* 🚫 **Tidak bisa sambil pegang senjata**
* 🚫 **Tidak bisa saat combat**
* 🚫 **Tidak bisa di saat berenang**
* 🚫 **Tidak bisa saat jatuh / ragdoll**
⚙️ Semua bisa diatur di Config.lua

## 📊 Performance

* **Resmon 0.00ms** idle.
* Tidak ada thread looping berat.
* Semua jalan pakai event/command.

## 🎯 Kegunaan

1. **Mengurangi bug render** (player/vehicle hilang muncul).
2. **Anti abuse** karena ada filter kondisi lengkap.
3. **Bikin server lebih smooth** tanpa harus relog.
4. **Lebih immersive** karena ada notifikasi ke sekitar.

## 📌 Notif yang di gunakan di script ini
exports['mythic_notify']:DoCustomHudText('inform', 'text',5000)
