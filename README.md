# Hava Yolları Takip Sistemi
Bir havayolu operasyonunu uçtan uca izlemek için tasarlanmış ilişkisel veritabanıdır. Sistem; uçuş planlamayı, yolcu rezervasyon ve bilet süreçlerini, koltuk atamalarını, mürettebat görev dağılımını, bagaj takibini, ödeme kayıtlarını ve uçak bakım geçmişini merkezi olarak yönetir. Microsoft SQL Server üzerinde tasarlanmıştır.

## 📂 Proje Yapısı

- **database/**
  - `01_schema.sql` – Tüm tablolar, primary key, foreign key ve kısıtlar
  - `02_seed_data.sql` – Test ve demo amaçlı örnek veriler
  - `03_procedures.sql` – Stored procedure tanımları
  - `04_triggers.sql` – Trigger tanımları
  - `05_transactions_demo.sql` – COMMIT / ROLLBACK transaction senaryoları
  - `06_test_queries.sql` – Gereksinim bazlı test sorguları
  - `07_role_requirements.md` – Kullanıcı rollerine göre gereksinimler

- **README.md** – Projenin genel açıklaması ve çalıştırma adımları

## Tablo Açıklamaları

| İlişki | Tip | Açıklama |
|---|---:|---|
| Airline → Airplane | 1 → N | One airline operates multiple airplanes. |
| Airline → Crew | 1 → N | One airline employs many crew members. |
| Airplane → Flight | 1 → N | One airplane can operate many flights (over time). |
| Airplane → Seat | 1 → N | One airplane contains many seats. |
| Airplane → Maintenance | 1 → N | One airplane has many maintenance records. |
| Flight → Airport (Departs_From) | N → 1 | Many flights depart from one airport. |
| Flight → Airport (Arrives_At) | N → 1 | Many flights arrive at one airport. |
| Flight → Ticket | 1 → N | One flight can have many tickets sold. |
| Passenger → Ticket | 1 → N | One passenger can purchase many tickets. |
| Member → Ticket | 1 → N (optional on Ticket) | A ticket may belong to a member; a member can have many tickets. |
| Member → MemberPointsTransactions | 1 → N | One member has many points transactions. |
| FarePackage → Ticket | 1 → N | One package can be used by many tickets; each ticket uses exactly one package. |
| FarePackage → FareRefundRules | 1 → N | Each package can define multiple refund rules. |
| Seat → Ticket | 1 → N (flight+seat unique) | Seats can be assigned to tickets; double booking is prevented by unique (flight_id, seat_id). |
| Passenger → Reservation | 1 → N | One passenger can create many reservations. |
| Flight → Reservation | 1 → N | One flight can have many reservations. |
| Ticket → Payment | 1 → N | One ticket can have multiple payment records (paid/refund attempts). |
| Ticket → Baggage | 1 → N | One ticket can have multiple baggage records. |
| Ticket → ExtraBaggagePurchases | 1 → N | One ticket can have multiple extra baggage purchases. |
| Ticket → Cancelled_Tickets | 1 → 0..1 | A ticket may be cancelled; if cancelled it has one cancellation record. |
| Ticket → CheckIns | 1 → 0..1 | A ticket may have one online check-in record. |
| Ticket → BoardingPasses | 1 → 0..1 | A ticket may have one boarding pass. |
| Flight → Flight_Status | 1 → N | One flight can have many status history records. |
| PromoCodes → TicketPromoUsage | 1 → N | A promo code can be used in many ticket usages. |
| Ticket → TicketPromoUsage | 1 → 0..1 | A ticket may use at most one promo code (one usage record). |


## Tablolar Arası İlişkiler

| İlişki | Türü | Açıklama |
|------|------|---------|
| Airline → Airplane | 1 → N | Bir havayolunun birden fazla uçağı olabilir. |
| Airplane → Flight | 1 → N | Bir uçak farklı zamanlarda birçok uçuş gerçekleştirebilir. |
| Flight → Ticket | 1 → N | Her uçuşta birden fazla bilet satılabilir. |
| Passenger → Ticket | 1 → N | Bir yolcu birden fazla bilet satın alabilir. |
| Airline → Crew | 1 → N | Bir havayolunun birçok mürettebatı bulunur. |
| Flight → Crew | N → N | Bir uçuşta birden fazla mürettebat görev alabilir, bir mürettebat birden fazla uçuşta görev alabilir. |
| Airplane → Seat | 1 → N | Her uçakta birden fazla koltuk bulunur. |
| Passenger → Reservation | 1 → N | Bir yolcu birden fazla rezervasyon yapabilir. |
| Flight → Reservation | 1 → N | Bir uçuş için birden fazla rezervasyon oluşturulabilir. |
| Ticket → Payment | 1 → N | Bir bilet için bir veya birden fazla ödeme kaydı bulunabilir. |
| Ticket → Baggage | 1 → N | Bir bilete birden fazla bagaj kaydı eklenebilir. |
| Flight → Flight_Status | 1 → N | Bir uçuşun zaman içerisinde birden fazla durum kaydı olabilir. |
| Airplane → Maintenance | 1 → N | Bir uçak için birden fazla bakım kaydı tutulabilir. |
| Member → Ticket | 1 → N | Bir üye birden fazla bilet satın alabilir. |
| FarePackage → Ticket | 1 → N | Aynı paket türü birden fazla bilette kullanılabilir. |
| FarePackage → FareRefundRules | 1 → N | Her paket için birden fazla iade kuralı tanımlanabilir. |
| Ticket → CheckIn | 1 → 1 | Her bilet için yalnızca bir online check-in yapılabilir. |
| Ticket → BoardingPass | 1 → 1 | Her bilet için tek bir biniş kartı üretilir. |

## 🧑‍💼 Kullanıcı Rolleri

Sistem aşağıdaki kullanıcı rollerini destekleyecek şekilde tasarlanmıştır:
- Misafir Yolcu (Guest)
- Üye Yolcu (Member)
- Check-in Görevlisi
- Operasyon Personeli
- Bakım Teknisyeni
- Finans Personeli
- Sistem Yöneticisi (Admin)

Detaylı rol–gereksinim eşlemesi için:
📄 `database/04_role_requirements.md`

## ⚙️ Stored Procedures

Proje kapsamında aşağıdaki stored procedure’lar geliştirilmiştir:

- **sp_CancelTicketAndRefund**
  - Bilet iptali
  - Paket bazlı iade oranı hesaplama
  - İade kaydı oluşturma
  - Transaction yönetimi

- **sp_BookTicket**
  - Bilet satın alma işlemi
  - Ticket + Payment işlemlerini tek transaction içinde yürütme

- **sp_AddMemberPoints**
  - Üyelere puan ekleme
  - Puan hareketlerini kayıt altına alma (audit)

📄 Detaylar: `database/05_procedures.sql`


## 🔁 Triggers

Aşağıdaki trigger’lar sistemin otomatik çalışmasını sağlar:

- **tr_CheckIn_CreateBoardingPass**
  - Online check-in sonrası otomatik boarding pass üretir

- **tr_FlightStatus_CompensateMembers**
  - Uçuş gecikmesi veya iptali durumunda
    üyelere otomatik telafi puanı ekler

📄 Detaylar: `database/06_triggers.sql`


## 🔐 Transaction Yönetimi

Bilet satın alma süreci transaction kullanılarak tasarlanmıştır.

- Başarılı senaryo → COMMIT
- Aynı uçuşta aynı koltuk satılmaya çalışıldığında → ROLLBACK

Bu senaryolar:
📄 `database/07_transactions_demo.sql`
dosyasında detaylı olarak gösterilmiştir.


## 🧪 Test Queries

Sistemin gereksinimleri karşıladığını göstermek için
anlamlı test sorguları hazırlanmıştır.

Örnekler:
- Kalkış–varışa göre uçuş arama
- Üye bilet ve paket bilgileri
- Uçuş durum geçmişi
- Check-in ve boarding pass bilgileri
- İptal edilen biletler ve iadeler

📄 `database/08_test_queries.sql`

## 🎯 Sonuç

Bu proje ile:
- Gerçekçi bir havayolu veritabanı tasarlanmış
- İş kuralları stored procedure ve trigger’lar ile uygulanmış
- Transaction yönetimi ve test sorguları ile sistemin doğruluğu gösterilmiştir

Proje, **Veritabanı Yönetim Sistemleri** dersi dönem projesi kapsamında hazırlanmıştır.








