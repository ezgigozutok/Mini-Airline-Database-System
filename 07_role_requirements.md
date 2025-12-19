## Kullanıcı Rollerine Göre Gereksinimler

| Rol | Yapabildikleri (Gereksinimler) | İlgili Tablolar |
|-----|--------------------------------|-----------------|
| Misafir Yolcu (Guest) | • Uçuş arama 
• Fiyat görüntüleme 
• Rezervasyon oluşturma 
• Üye olmadan bilet satın alma | Flights, Airports, Reservations, Passengers, Tickets, Payments |
| Üye Yolcu (Member) | • Üye olma ve profil yönetimi • Bilet satın alma • Paket seçimi (15/20/25 kg) • Puan kazanma/harcama • Bilet iptali ve iade alma • Online check-in • Boarding pass alma • Ekstra bagaj satın alma | Members, Tickets, FarePackages, FareRefundRules, MemberPointsTransactions, Cancelled_Tickets, CheckIns, BoardingPasses, ExtraBaggagePurchases |
| Check-in Görevlisi | • Check-in işlemi yapma • Boarding pass üretimini kontrol etme • Check-in iptali | CheckIns, BoardingPasses, Tickets |
| Operasyon Personeli | • Uçuş durumu güncelleme (Delayed, Cancelled vb.) • Mürettebat atama | Flight_Status, Flights, Crew, Flight_Crew |
| Bakım Teknisyeni | • Uçak bakım kaydı oluşturma • Bakım geçmişini görüntüleme | Maintenance, Airplanes |
| Finans Personeli | • Ödeme kayıtlarını görüntüleme • İade işlemlerini takip etme | Payments, Cancelled_Tickets |
| Sistem Yöneticisi (Admin) | • Sistem tanım verilerini yönetme (hava yolu, uçak, koltuk, havalimanı) • Promosyon ve kampanya tanımlama | Airlines, Airplanes, Seats, Airports, PromoCodes |
