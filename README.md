# EA XAUUSD Standar M15


Berikut adalah penjelasan fitur-fitur yang ada dalam EA ini:  

### **1. Moving Average (MA) sebagai Indikator Utama**  
- **MA53 dan MA82** digunakan untuk menentukan arah tren utama.  
- **MA35** digunakan sebagai konfirmasi tren dan level pullback sebelum entry.  

### **2. Konfirmasi Entry Berdasarkan Breakout & Konsolidasi**  
- Entry hanya dilakukan jika harga melewati MA35 dan MA82, kemudian mengalami pullback ke MA35 atau konsolidasi dalam beberapa candle.  
- Konsolidasi diukur menggunakan ATR agar memastikan harga benar-benar stabil sebelum melanjutkan tren.  

### **3. Filter ADX & RSI untuk Validasi Tren**  
- **ADX > 25** digunakan untuk memastikan tren cukup kuat sebelum entry.  
- **RSI > 70 (overbought) atau < 30 (oversold)** mencegah entry di kondisi ekstrem yang bisa menyebabkan reversal.  

### **4. Multi-Timeframe Analysis (M15 & H1)**  
- Entry hanya dilakukan jika tren di M15 searah dengan tren di H1 untuk menghindari sinyal palsu.  

### **5. Take Profit & Stop Loss Dinamis**  
- **Take Profit disesuaikan dengan news dan pembalikan tren** agar tidak keluar terlalu cepat.  
- **Stop Loss berdasarkan ATR** untuk menyesuaikan dengan volatilitas harga.  
- **Trailing Stop & Break-even Stop** otomatis mengunci profit jika harga bergerak sesuai tren.  

### **6. Time Filter untuk Optimalisasi Trading**  
- EA hanya akan trading dalam jam tertentu yang dapat dikonfigurasi (misalnya hanya saat sesi London & New York).  

### **7. Eksekusi Order Otomatis & Manajemen Risiko**  
- Lot size dihitung berdasarkan equity dan persentase risiko yang ditentukan.  
- Hanya satu order per persilangan MA untuk menghindari overtrading.  
- Hedging Mode untuk membuka posisi Buy & Sell bersamaan jika ada sinyal yang mendukung.  

---

### **Cara Menggunakan EA di MetaTrader 5**  
1. **Install EA** di folder `Experts` di terminal MetaTrader 5.  
2. **Tambahkan ke chart XAUUSD timeframe M15.**  
3. **Sesuaikan parameter input** seperti periode MA, ADX, RSI, ATR, dan waktu trading.  
4. **Aktifkan AutoTrading** agar EA dapat melakukan eksekusi order secara otomatis.  
5. **Uji coba di akun demo** untuk melihat performanya sebelum digunakan di akun real.  

---

EA ini sudah memiliki sistem yang lebih optimal dalam mengikuti tren dan mengamankan profit. 

---
### *"Author Didit Farafat**
