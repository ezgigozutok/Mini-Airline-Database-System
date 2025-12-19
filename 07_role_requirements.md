## Kullanıcı Rollerine Göre Gereksinimler

| Rol | Yetki / Yapabildikleri | Sistem Gereksinimi (Kısa) | İlgili Tablolar |
|-----|-------------------------|----------------------------|-----------------|
| Misafir Yolcu (Guest) | Uçuş arama, fiyat görme, rezervasyon oluşturma | Uçuşlar kalkış/varışa göre listelenebilmeli, fiyat gösterilmeli, rezervasyon alınabilmeli | Flights, Airports, Reservations |
| Misafir Yolcu (Guest) | Üye olmadan bilet satın alma | Üye olmadan yolcu kaydı ile bilet oluşturulabilmeli | Passengers, Tickets, Payments |
| Üye Yolcu (Member) | Üye olma / profil yönetimi | Üye kayıt, telefon/email benzersiz olmalı, puan bakiyesi tutulmalı | Members |
| Üye Yolcu (Member) | Bilet satın alma + puan kazanma | Satın alma sonrası puan hareketi kaydedilmeli (audit) | Tickets, MemberPointsTransactions |
| Üye Yolcu (Member) | Paket seçimi (15/20/25) | Paket seçimi ile bagaj hakkı ve koltuk seçimi politikası belirlenmeli | FarePackages, Tickets |
| Üye Yolcu (Member) | Bilet iptali ve iade | Paket kurallarına göre iade yüzdesi hesaplanmalı, iptal kaydı tutulmalı | FareRefundRules, Cancelled_Tickets, Tickets, Payments |
| Üye Yolcu (Member) | Online check-in ve boarding pass alma | Check-in sonrası biniş kartı otomatik üretilmeli | CheckIns, BoardingPasses |
| Üye Yolcu (Member) | Ekstra bagaj satın alma | Paket hakkını aşan kg için ek bagaj satın alma kaydı tutulmalı | ExtraBaggagePurchases |
| Check-in Görevlisi | Check-in yapma / iptal etme | Bir bilet için tek check-in olmalı, boarding pass üretimi garanti olmalı | CheckIns, BoardingPasses, Tickets |
| Operasyon Personeli | Uçuş durumu güncelleme (Delayed/Cancelled vb.) | Uçuş durum değişiklikleri tarihçeli tutulmalı (log) | Flight_Status, Flights |
| Operasyon Personeli | Uçuş–mürettebat atama | Bir uçuşa birden fazla crew atanabilmeli, N-N ilişki yönetilmeli | Crew, Flight_Crew, Flights |
| Bakım Teknisyeni | Bakım kaydı girme / görüntüleme | Uçaklara ait bakım kayıtları saklanmalı ve raporlanabilmeli | Maintenance, Airplanes |
| Finans Personeli | Ödeme kaydı görüntüleme / iade takibi | Ödeme durumları izlenebilmeli (Paid/Refunded/Failed) | Payments, Cancelled_Tickets |
| Sistem Yöneticisi (Admin) | Tanım verileri yönetimi | Hava yolu, uçak, havalimanı, koltuk tanımları güvenli şekilde yönetilmeli | Airlines, Airplanes, Airports, Seats |
| Sistem Yöneticisi (Admin) | Kampanya / promosyon yönetimi | Promosyon kodu tanımlanmalı, geçerlilik tarihleri kontrol edilmeli | PromoCodes, TicketPromoUsage |
