-- ============================================================
--  OurMoment: Digital Ceremony & Celebration Management System
--  SQL Database Schema (MySQL / PostgreSQL compatible)
-- ============================================================

-- ─────────────────────────────────────────────
-- TABLE: users
-- เก็บข้อมูลผู้ใช้งานทุกคนในระบบ (Host & Guest)
-- ─────────────────────────────────────────────
CREATE TABLE users (
    user_id       VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number  VARCHAR(20),
    gender        ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    profile_image VARCHAR(500),
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- TABLE: events
-- เก็บข้อมูลกิจกรรม/งานเฉลิมฉลอง ที่ Host สร้าง
-- ─────────────────────────────────────────────
CREATE TABLE events (
    event_id            VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    host_user_id        VARCHAR(36)  NOT NULL,
    event_name          VARCHAR(200) NOT NULL,
    description         TEXT,
    banner_image_url    VARCHAR(500),
    date_start          DATETIME     NOT NULL,
    date_end            DATETIME     NOT NULL,
    location_name       VARCHAR(300),
    location_lat        DECIMAL(10, 8),
    location_lng        DECIMAL(11, 8),
    theme_color         VARCHAR(50),
    join_code           VARCHAR(20)  NOT NULL UNIQUE,
    allow_guest_photos  BOOLEAN      NOT NULL DEFAULT TRUE,
    status              ENUM('upcoming', 'ongoing', 'past') NOT NULL DEFAULT 'upcoming',
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_events_host FOREIGN KEY (host_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE: event_guests  (RSVP / Join Event)
-- ความสัมพันธ์ระหว่าง User กับ Event ในฐานะ Guest
-- ─────────────────────────────────────────────
CREATE TABLE event_guests (
    guest_id        VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    event_id        VARCHAR(36) NOT NULL,
    user_id         VARCHAR(36) NOT NULL,
    food_allergy    TEXT,
    followers_count INT         NOT NULL DEFAULT 1,   -- จำนวนผู้ติดตามที่มาด้วย
    rsvp_status     ENUM('confirmed', 'pending', 'declined') NOT NULL DEFAULT 'pending',
    checked_in      BOOLEAN     NOT NULL DEFAULT FALSE,
    checked_in_at   DATETIME,
    joined_at       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_eg_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_eg_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
    CONSTRAINT uq_event_guest UNIQUE (event_id, user_id)
);

-- ─────────────────────────────────────────────
-- TABLE: agenda_items
-- กำหนดการ (Timeline) ภายในกิจกรรม
-- ─────────────────────────────────────────────
CREATE TABLE agenda_items (
    agenda_id    VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    event_id     VARCHAR(36)  NOT NULL,
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    location     VARCHAR(300),
    start_time   DATETIME     NOT NULL,
    end_time     DATETIME,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_agenda_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE: agenda_notifications
-- การตั้ง Notification ของ Guest ต่อ Agenda แต่ละรายการ
-- ─────────────────────────────────────────────
CREATE TABLE agenda_notifications (
    id          VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    agenda_id   VARCHAR(36) NOT NULL,
    user_id     VARCHAR(36) NOT NULL,
    is_enabled  BOOLEAN     NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_anoti_agenda FOREIGN KEY (agenda_id) REFERENCES agenda_items(agenda_id) ON DELETE CASCADE,
    CONSTRAINT fk_anoti_user   FOREIGN KEY (user_id)   REFERENCES users(user_id)          ON DELETE CASCADE,
    CONSTRAINT uq_anoti UNIQUE (agenda_id, user_id)
);

-- ─────────────────────────────────────────────
-- TABLE: gallery_photos
-- รูปภาพใน Live Gallery แบบ Real-time
-- ─────────────────────────────────────────────
CREATE TABLE gallery_photos (
    photo_id      VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    event_id      VARCHAR(36)  NOT NULL,
    uploaded_by   VARCHAR(36)  NOT NULL,  -- user_id
    photo_url     VARCHAR(500) NOT NULL,
    category      ENUM('all', 'couple', 'guests') NOT NULL DEFAULT 'guests',
    caption       TEXT,
    uploaded_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_photo_event FOREIGN KEY (event_id)    REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_photo_user  FOREIGN KEY (uploaded_by) REFERENCES users(user_id)   ON DELETE SET NULL
);

-- ─────────────────────────────────────────────
-- TABLE: wish_wall
-- คำอวยพรจากแขกในงาน (Guest Wishes Wall)
-- ─────────────────────────────────────────────
CREATE TABLE wish_wall (
    wish_id     VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    event_id    VARCHAR(36) NOT NULL,
    user_id     VARCHAR(36) NOT NULL,
    message     TEXT        NOT NULL,
    created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_wish_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_wish_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE: announcements
-- ประกาศจาก Host ไปยังผู้เข้าร่วมงานทุกคน
-- ─────────────────────────────────────────────
CREATE TABLE announcements (
    announcement_id VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    event_id        VARCHAR(36)  NOT NULL,
    host_user_id    VARCHAR(36)  NOT NULL,
    title           VARCHAR(200),
    message         TEXT         NOT NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_announce_event FOREIGN KEY (event_id)     REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_announce_host  FOREIGN KEY (host_user_id) REFERENCES users(user_id)   ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE: notifications
-- การแจ้งเตือน Push Notification ของแต่ละ User
-- ─────────────────────────────────────────────
CREATE TABLE notifications (
    notification_id VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
    user_id         VARCHAR(36)  NOT NULL,
    event_id        VARCHAR(36),
    type            ENUM('agenda_reminder', 'announcement', 'guest_joined', 'photo_uploaded', 'wish_received') NOT NULL,
    title           VARCHAR(200),
    body            TEXT,
    is_read         BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_noti_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
    CONSTRAINT fk_noti_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE SET NULL
);

-- ============================================================
--  INDEXES (ปรับประสิทธิภาพการ Query)
-- ============================================================
CREATE INDEX idx_events_host       ON events(host_user_id);
CREATE INDEX idx_events_join_code  ON events(join_code);
CREATE INDEX idx_events_status     ON events(status);
CREATE INDEX idx_eg_event          ON event_guests(event_id);
CREATE INDEX idx_eg_user           ON event_guests(user_id);
CREATE INDEX idx_agenda_event      ON agenda_items(event_id, sort_order);
CREATE INDEX idx_gallery_event     ON gallery_photos(event_id, category);
CREATE INDEX idx_wish_event        ON wish_wall(event_id, created_at DESC);
CREATE INDEX idx_noti_user         ON notifications(user_id, is_read, created_at DESC);

-- ============================================================
--  SAMPLE DATA
-- ============================================================

-- Users
INSERT INTO users (user_id, full_name, email, password_hash, phone_number, gender) VALUES
('u-001', 'Krittanai Ngampanja',         'krittanai@example.com', '$2b$10$hashedpassword1', '0812345678', 'male'),
('u-002', 'Cheewanon Srisawadwattana',   'cheewa@example.com',    '$2b$10$hashedpassword2', '0851726536', 'male'),
('u-003', 'Nine Nitthiphat',             'nine@example.com',      '$2b$10$hashedpassword3', '0898765432', 'female');

-- Event
INSERT INTO events (event_id, host_user_id, event_name, description, date_start, date_end,
    location_name, location_lat, location_lng, theme_color, join_code, allow_guest_photos, status) VALUES
('e-001', 'u-001',
 'Aom & Ton\'s Wedding',
 'A casual yet insightful gathering for designers, creators, and digital thinkers to connect.',
 '2025-10-25 18:00:00', '2025-10-25 22:00:00',
 'Thailand, Bangkok, Baiyok Tower', 13.7563, 100.5018,
 'Blue Navy', 'WED24', TRUE, 'upcoming');

-- Event Guests
INSERT INTO event_guests (guest_id, event_id, user_id, food_allergy, followers_count, rsvp_status, checked_in, checked_in_at, joined_at) VALUES
('eg-001', 'e-001', 'u-002', NULL, 1, 'confirmed', TRUE, '2026-02-28 17:19:00', '2026-02-27 00:00:00'),
('eg-002', 'e-001', 'u-003', 'Shellfish', 2, 'confirmed', FALSE, NULL, '2026-02-27 00:00:00');

-- Agenda Items
INSERT INTO agenda_items (agenda_id, event_id, title, description, location, start_time, sort_order) VALUES
('ag-001', 'e-001', 'Buddhist Ceremony', 'Offering food to nine monks.', 'Aew Grand 2', '2025-10-25 18:00:00', 1),
('ag-002', 'e-001', 'Wedding Reception',  'Dinner and celebration.',      'Aew Grand 2', '2025-10-25 19:30:00', 2),
('ag-003', 'e-001', 'Cake Cutting',       'Wedding cake ceremony.',       'Aew Grand 2', '2025-10-25 21:00:00', 3);

-- Wish Wall
INSERT INTO wish_wall (wish_id, event_id, user_id, message) VALUES
('w-001', 'e-001', 'u-002', 'May your love grow stronger each passing year. You two truly bring out the best in each other.'),
('w-002', 'e-001', 'u-003', 'Wishing you a lifetime of love, laughter, and happiness. Congratulations on your beautiful day!');

-- Announcement
INSERT INTO announcements (announcement_id, event_id, host_user_id, title, message) VALUES
('an-001', 'e-001', 'u-001', 'Dress Code Reminder', 'Please wear Blue Navy themed outfits for the evening.');
