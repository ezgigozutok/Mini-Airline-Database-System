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

| Tablo Adı | Açıklama |
|---------|----------|
| Airlines | Havayolu şirketi bilgilerini tutar (airline_id, name, country). |
| Airports | Kalkış ve varış havalimanı bilgileri (airport_id, name, city, country). |
| Airplanes | Havayoluna ait uçak bilgileri (airplane_id, model, capacity, airline_id). |
| Flights | Uçuş (sefer) bilgileri (flight_id, flight_number, departure_time, arrival_time, airplane_id, departure_airport_id, arrival_airport_id). |
| Passengers | Yolcu bilgileri (passenger_id, name, surname, passport_number – UNIQUE). |
| Members | Sisteme üye olan yolcuların bilgileri ve puanları (member_id, first_name, last_name, phone_no, email, points). |
| MemberPointsTransactions | Üyelerin puan kazanma ve harcama hareketlerini tutar (txn_id, member_id, txn_time, txn_type, points, description). |
| FarePackages | Bilet paketleri bilgileri (package_id, package_name, baggage_allowance_kg, seat_selection_policy). |
| FareRefundRules | Paketlere ait iade kurallarını tutar (rule_id, package_id, hours_before_departure, refund_percent). |
| Seats | Uçak koltuk düzenleri (seat_id, airplane_id, seat_number, seat_class, is_window). |
| Tickets | Satın alınan bilet bilgileri (ticket_id, pnr, booking_time, flight_id, passenger_id, seat_id, package_id, member_id, price_paid, ticket_status). |
| Reservations | Ön rezervasyon bilgileri (reservation_id, passenger_id, flight_id, reservation_date, status). |
| Payments | Bilet ödemelerine ait bilgiler (payment_id, ticket_id, payment_date, amount, payment_method, status). |
| Baggage | Yolcu bagaj bilgileri (baggage_id, ticket_id, weight, baggage_type). |
| ExtraBaggagePurchases | Paket limitini aşan ek bagaj satın alma kayıtları (extra_id, ticket_id, extra_kg, price, purchased_at). |
| Flight_Status | Uçuşun zaman içindeki durum bilgileri (status_id, flight_id, status, delay_minutes, reason, updated_at). |
| Crew | Mürettebat bilgileri (crew_id, name, surname, role, experience_years, airline_id). |
| Flight_Crew | Uçuş–Mürettebat çoktan çoğa ilişki tablosu (flight_id, crew_id). |
| Maintenance | Uçak bakım kayıtları (maintenance_id, airplane_id, maintenance_date, description, technician_name). |
| Cancelled_Tickets | İptal edilen biletler ve iade tutarları (cancel_id, ticket_id, refund_amount, cancelled_at). |
| CheckIns | Online check-in bilgileri (checkin_id, ticket_id, checkin_time, status). |
| BoardingPasses | Check-in sonrası üretilen biniş kartları (boarding_pass_id, ticket_id, issued_at, token). |
| PromoCodes | İndirim kodları bilgileri (promo_id, code, discount_percent, valid_from, valid_to, min_amount). |
| TicketPromoUsage | Bir bilette kullanılan promosyon kodu kayıtları (usage_id, ticket_id, promo_id, used_at). |


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








