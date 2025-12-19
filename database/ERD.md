erDiagram
    AIRLINES ||--o{ AIRPLANES : owns
    AIRPLANES ||--o{ FLIGHTS : operates
    AIRPORTS ||--o{ FLIGHTS : departure_airport
    AIRPORTS ||--o{ FLIGHTS : arrival_airport

    PASSENGERS ||--o{ TICKETS : buys
    FLIGHTS ||--o{ TICKETS : has
    SEATS ||--o{ TICKETS : assigned_to
    AIRPLANES ||--o{ SEATS : contains

    MEMBERS ||--o{ TICKETS : optional_member
    MEMBERS ||--o{ MEMBER_POINTS_TRANSACTIONS : has

    FARE_PACKAGES ||--o{ TICKETS : chosen_for
    FARE_PACKAGES ||--o{ FARE_REFUND_RULES : defines

    TICKETS ||--o{ PAYMENTS : paid_by
    TICKETS ||--o{ BAGGAGE : includes
    TICKETS ||--o{ EXTRA_BAGGAGE_PURCHASES : extra_baggage

    FLIGHTS ||--o{ FLIGHT_STATUS : status_history

    AIRLINES ||--o{ CREW : employs
    FLIGHTS ||--o{ FLIGHT_CREW : crew_assignment
    CREW ||--o{ FLIGHT_CREW : assigned

    AIRPLANES ||--o{ MAINTENANCE : maintenance_logs

    TICKETS ||--o| CHECKINS : checkin
    TICKETS ||--o| BOARDINGPASSES : boarding_pass

    TICKETS ||--o| CANCELLED_TICKETS : cancellation

    PROMOCODES ||--o{ TICKET_PROMO_USAGE : used_in
    TICKETS ||--o| TICKET_PROMO_USAGE : promo_usage
