/* =========================================================
   MINI THY (AIRLINE) DATABASE - FINAL DDL (SQL Server)
   Includes: core airline DB + membership + packages/refunds
             + check-in/boarding pass + extra baggage + crew
   ========================================================= */

-- =========================
-- 1) MASTER TABLES
-- =========================

/*
Airlines:
Hava yolu şirketlerini tutar.
Uçaklar ve mürettebat bir hava yoluna bağlıdır.
*/
CREATE TABLE Airlines(
    airline_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

/*
Airports:
Uçuşların kalkış/varış noktalarını tutar.
*/
CREATE TABLE Airports(
    airport_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

/*
Airplanes:
Hava yoluna ait uçakları tutar.
capacity: uçaktaki maksimum koltuk sayısı (mantıksal kontrol).
*/
CREATE TABLE Airplanes(
    airplane_id INT IDENTITY(1,1) PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    airline_id INT NOT NULL FOREIGN KEY REFERENCES Airlines(airline_id)
);

/*
Flights:
Planlanan/gerçekleşen uçuşları tutar.
departure/arrival airport ve airplane ile ilişkilidir.
arrival_time > departure_time kuralı ile zaman tutarlılığı sağlanır.
*/
CREATE TABLE Flights(
    flight_id INT IDENTITY(1,1) PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    airplane_id INT NOT NULL FOREIGN KEY REFERENCES Airplanes(airplane_id),
    departure_airport_id INT NOT NULL FOREIGN KEY REFERENCES Airports(airport_id),
    arrival_airport_id INT NOT NULL FOREIGN KEY REFERENCES Airports(airport_id),
    CHECK (arrival_time > departure_time)
);

/*
Passengers:
Gerçek yolcuyu temsil eder.
Üyelikten bağımsızdır (üye olmadan da bilet alınabilir).
passport_number benzersiz olabilir.
*/
CREATE TABLE Passengers(
    passenger_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20) UNIQUE
);

-- =========================
-- 2) MEMBERSHIP (ÜYELİK)
-- =========================

/*
Members:
Üye olan kullanıcıları tutar.
Üyeler puan kazanır ve avantaj/indirim sistemine dahil olur.
email ve phone benzersiz tutulur.
*/
CREATE TABLE Members(
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    phone_no VARCHAR(11) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    points INT NOT NULL DEFAULT(0) CHECK(points >= 0 AND points <= 100000)
);

/*
MemberPointsTransactions:
Puan hareketleri (kazan/harca/düzeltme) kayıt altına alınır.
Bu tablo puanların “neden değiştiğini” audit eder.
*/
CREATE TABLE MemberPointsTransactions(
    txn_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL FOREIGN KEY REFERENCES Members(member_id),
    txn_time DATETIME NOT NULL DEFAULT GETDATE(),
    txn_type VARCHAR(20) NOT NULL CHECK (txn_type IN ('EARN', 'SPEND', 'ADJUST')),
    points INT NOT NULL CHECK(points > 0),
    description VARCHAR(200) NULL
);

-- =========================
-- 3) PACKAGE / REFUND RULES (15/20/25 KG)
-- =========================

/*
FarePackages:
Bilet paketlerini temsil eder (15kg/20kg/25kg gibi).
bagaj hakkı ve koltuk seçimi politikası pakete göre değişir.
seat_selection_policy:
- NONE: koltuk seçimi yok
- PAID_STANDARD: standart koltuk ücretli seçilebilir
- FREE_EXCEPT_BUSINESS: business dışı ücretsiz seçilebilir
*/
CREATE TABLE FarePackages(
    package_id INT IDENTITY(1,1) PRIMARY KEY,
    package_name VARCHAR(30) NOT NULL UNIQUE,
    baggage_allowance_kg INT NOT NULL CHECK (baggage_allowance_kg > 0),
    seat_selection_policy VARCHAR(30) NOT NULL CHECK(
        seat_selection_policy IN ('NONE', 'PAID_STANDARD', 'FREE_EXCEPT_BUSINESS')
    )
);

/*
FareRefundRules:
Paket bazlı iade kurallarını tutar.
Örn: Uçuştan 24 saat önce %50 iade.
Procedure ile iptal edildiğinde buradan oran seçilerek iade hesaplanır.
*/
CREATE TABLE FareRefundRules(
    rule_id INT IDENTITY(1,1) PRIMARY KEY,
    package_id INT NOT NULL FOREIGN KEY REFERENCES FarePackages(package_id),
    hours_before_departure INT NOT NULL CHECK(hours_before_departure >= 0),
    refund_percent INT NOT NULL CHECK(refund_percent >= 0 AND refund_percent <= 100)
);

-- =========================
-- 4) SEATS
-- =========================

/*
Seats:
Koltuklar uçağa aittir (bilete değil).
Aynı uçakta aynı seat_number tekrar olamaz -> UNIQUE(airplane_id, seat_number).
*/
CREATE TABLE Seats(
    seat_id INT IDENTITY(1,1) PRIMARY KEY,
    airplane_id INT NOT NULL FOREIGN KEY REFERENCES Airplanes(airplane_id),
    seat_number VARCHAR(10) NOT NULL,
    seat_class VARCHAR(20) NOT NULL CHECK (seat_class IN ('Economy', 'Business', 'First')),
    is_window BIT NOT NULL DEFAULT(0),
    CONSTRAINT UQ_Seats_AirplaneSeat UNIQUE (airplane_id, seat_number)
);

-- =========================
-- 5) TICKETS (SATIN ALMA)
-- =========================

/*
Tickets:
Satın alınmış biletleri tutar.
Passenger + Flight + Seat + Package + (opsiyonel) Member bağlanır.
price_paid: satın alma anındaki nihai fiyatı sabitler.
ticket_status: Active/Cancelled
*/
CREATE TABLE Tickets(
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    pnr VARCHAR(12) NOT NULL UNIQUE,
    booking_time DATETIME NOT NULL DEFAULT GETDATE(),

    flight_id INT NOT NULL FOREIGN KEY REFERENCES Flights(flight_id),
    passenger_id INT NOT NULL FOREIGN KEY REFERENCES Passengers(passenger_id),
    seat_id INT NOT NULL FOREIGN KEY REFERENCES Seats(seat_id),

    package_id INT NOT NULL FOREIGN KEY REFERENCES FarePackages(package_id),
    member_id INT NULL FOREIGN KEY REFERENCES Members(member_id),

    price_paid DECIMAL(10,2) NOT NULL CHECK(price_paid > 0),
    ticket_status VARCHAR(20) NOT NULL CHECK(ticket_status IN ('Active','Cancelled'))
);

/*
Aynı uçuşta aynı seat_id iki kez satılamaz:
Double booking’i engeller.
*/
ALTER TABLE Tickets
ADD CONSTRAINT UQ_Tickets_FlightSeat UNIQUE (flight_id, seat_id);

-- =========================
-- 6) RESERVATIONS (OPSİYONEL ÖN AŞAMA)
-- =========================

/*
Reservations:
Bilet almadan önce rezervasyon/ön kayıt gibi kullanılabilir.
Aynı yolcu aynı uçuşa birden fazla rezervasyon açamasın -> UNIQUE.
*/
CREATE TABLE Reservations(
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    passenger_id INT NOT NULL FOREIGN KEY REFERENCES Passengers(passenger_id),
    flight_id INT NOT NULL FOREIGN KEY REFERENCES Flights(flight_id),
    reservation_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT UQ_Reservations_PassengerFlight UNIQUE (passenger_id, flight_id)
);

-- =========================
-- 7) PAYMENTS
-- =========================

/*
Payments:
Bilet ödemelerini tutar.
status: ödeme/iadeyi izlemek için gereklidir.
*/
CREATE TABLE Payments(
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES Tickets(ticket_id),
    payment_date DATETIME NOT NULL DEFAULT GETDATE(),
    amount DECIMAL(10,2) NOT NULL CHECK(amount > 0),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Cash', 'Online')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Pending','Paid','Refunded','Failed'))
);

-- =========================
-- 8) BAGGAGE + EXTRA BAGGAGE
-- =========================

/*
Baggage:
Yolcunun gerçek bagaj kayıtları.
Bagaj hakkı (limit) paket üzerinden geldiği için burada tutulmaz.
*/
CREATE TABLE Baggage(
    baggage_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES Tickets(ticket_id),
    weight DECIMAL(10,2) NOT NULL CHECK(weight > 0),
    baggage_type VARCHAR(20) NOT NULL CHECK (baggage_type IN ('Cabin', 'Checked'))
);

/*
ExtraBaggagePurchases:
Paket limitini aşan ek bagaj satın alımlarını tutar.
*/
CREATE TABLE ExtraBaggagePurchases(
    extra_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES Tickets(ticket_id),
    extra_kg INT NOT NULL CHECK(extra_kg > 0),
    price DECIMAL(10,2) NOT NULL CHECK(price > 0),
    purchased_at DATETIME NOT NULL DEFAULT GETDATE()
);

-- =========================
-- 9) FLIGHT STATUS HISTORY
-- =========================

/*
Flight_Status:
Uçuşun durum geçmişini tutar (Scheduled/Boarding/Delayed vs.).
Her güncelleme yeni kayıt olarak düşünülür -> geçmiş analizi yapılabilir.
delay_minutes ve reason gerçekçilik katar.
*/
CREATE TABLE Flight_Status(
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    flight_id INT NOT NULL FOREIGN KEY REFERENCES Flights(flight_id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Scheduled', 'Boarding', 'Departed', 'Delayed', 'Arrived', 'Cancelled')),
    delay_minutes INT NULL CHECK(delay_minutes IS NULL OR delay_minutes >= 0),
    reason VARCHAR(200) NULL,
    updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

-- =========================
-- 10) CREW + FLIGHT_CREW
-- =========================

/*
Crew:
Mürettebat kayıtları.
role alanı ile Pilot/Co-Pilot/Cabin Crew ayrımı yapılır.
experience_years negatif olamaz.
*/
CREATE TABLE Crew(
    crew_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Pilot', 'Co-Pilot', 'Cabin Crew')),
    experience_years INT NOT NULL CHECK (experience_years >= 0),
    airline_id INT NOT NULL FOREIGN KEY REFERENCES Airlines(airline_id)
);

/*
Flight_Crew:
Çoktan-çoğa ilişki: Bir uçuşta birden fazla crew olabilir, crew birden fazla uçuşta görev alabilir.
Composite PK ile aynı eşleşme tekrar engellenir.
*/
CREATE TABLE Flight_Crew(
    flight_id INT NOT NULL FOREIGN KEY REFERENCES Flights(flight_id),
    crew_id INT NOT NULL FOREIGN KEY REFERENCES Crew(crew_id),
    PRIMARY KEY (flight_id, crew_id)
);

-- =========================
-- 11) MAINTENANCE
-- =========================

/*
Maintenance:
Uçak bakım kayıtlarını tutar.
Havacılık operasyonlarında kritik bir modüldür (gerçekçilik + rapor puanı).
*/
CREATE TABLE Maintenance(
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    airplane_id INT NOT NULL FOREIGN KEY REFERENCES Airplanes(airplane_id),
    maintenance_date DATE NOT NULL,
    description VARCHAR(255) NULL,
    technician_name VARCHAR(100) NOT NULL
);

-- =========================
-- 12) CANCELLATIONS / REFUNDS
-- =========================

/*
Cancelled_Tickets:
İptal edilen biletler ve hesaplanan iade tutarı burada tutulur.
İade oranı FareRefundRules tablosundan türetilir (procedure ile).
*/
CREATE TABLE Cancelled_Tickets(
    cancel_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES Tickets(ticket_id),
    refund_amount DECIMAL(10,2) NOT NULL CHECK(refund_amount >= 0),
    cancelled_at DATETIME NOT NULL DEFAULT GETDATE()
);

-- =========================
-- 13) ONLINE CHECK-IN + BOARDING PASS
-- =========================

/*
CheckIns:
Online check-in işlemini temsil eder.
Bir bilet yalnızca bir kez check-in olabilir -> UNIQUE(ticket_id).
*/
CREATE TABLE CheckIns(
    checkin_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Tickets(ticket_id),
    checkin_time DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL CHECK(status IN ('CheckedIn','Cancelled'))
);

/*
BoardingPasses:
Check-in sonrası üretilecek biniş kartını tutar.
token: basit bir “QR/Barcode” temsilcisi gibi düşünülebilir (NEWID()).
Bir biletin tek boarding pass’i olur -> UNIQUE(ticket_id).
*/
CREATE TABLE BoardingPasses(
    boarding_pass_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Tickets(ticket_id),
    issued_at DATETIME NOT NULL DEFAULT GETDATE(),
    token UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
);

-- =========================
-- 14) PROMO CODES (OPTIONAL)
-- =========================

/*
PromoCodes:
İndirim kodu sistemi.
Özel günlerde/marketing kampanyalarında kullanılır.
*/
CREATE TABLE PromoCodes(
    promo_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    discount_percent INT NOT NULL CHECK(discount_percent >= 1 AND discount_percent <= 90),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    min_amount DECIMAL(10,2) NULL CHECK(min_amount IS NULL OR min_amount >= 0),
    CHECK (valid_to >= valid_from)
);

/*
TicketPromoUsage:
Bir bilette kullanılan promosyon kodunu bağlar.
UNIQUE(ticket_id) ile aynı bilete ikinci promo engellenir.
*/
CREATE TABLE TicketPromoUsage(
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Tickets(ticket_id),
    promo_id INT NOT NULL FOREIGN KEY REFERENCES PromoCodes(promo_id),
    used_at DATETIME NOT NULL DEFAULT GETDATE()
);
