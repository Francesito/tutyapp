-- MySQL 8 schema for TutorTrack
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('student','tutor') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS groups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(32) NOT NULL UNIQUE,
  term VARCHAR(20) NOT NULL,
  tutor_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tutor_id) REFERENCES users(id)
);

-- group_members keeps term denormalized to enforce unique per student/term
CREATE TABLE IF NOT EXISTS group_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_id INT NOT NULL,
  student_id INT NOT NULL,
  term VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_student_term (student_id, term),
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (student_id) REFERENCES users(id)
);

DROP TRIGGER IF EXISTS trg_group_members_term;
DELIMITER //
CREATE TRIGGER trg_group_members_term BEFORE INSERT ON group_members
FOR EACH ROW BEGIN
  DECLARE gterm VARCHAR(20);
  SELECT term INTO gterm FROM groups WHERE id = NEW.group_id;
  SET NEW.term = gterm;
END;//
DELIMITER ;

CREATE TABLE IF NOT EXISTS mood_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  emoji VARCHAR(8) NOT NULL,
  note TEXT,
  created_at DATE DEFAULT (CURRENT_DATE),
  UNIQUE KEY uniq_student_date (student_id, created_at),
  FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS perception_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  subject VARCHAR(120) NOT NULL,
  perception VARCHAR(50) NOT NULL,
  week_of DATE DEFAULT (CURRENT_DATE - INTERVAL WEEKDAY(CURRENT_DATE) DAY),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  attended BOOLEAN NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS grades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  subject VARCHAR(120) NOT NULL,
  grade DECIMAL(4,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS justifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  reason VARCHAR(255) NOT NULL,
  evidence_url VARCHAR(255) NOT NULL,
  status ENUM('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  term VARCHAR(20) DEFAULT 'default',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id)
);

-- enforce max 2 justifications per student/term
DROP TRIGGER IF EXISTS trg_justifications_limit;
DELIMITER //
CREATE TRIGGER trg_justifications_limit BEFORE INSERT ON justifications
FOR EACH ROW BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM justifications WHERE student_id = NEW.student_id AND term = NEW.term;
  IF total >= 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de justificantes alcanzado';
  END IF;
END;//
DELIMITER ;

CREATE TABLE IF NOT EXISTS alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_id INT NOT NULL,
  student_id INT,
  type VARCHAR(50) NOT NULL,
  message VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (student_id) REFERENCES users(id)
);

-- simple triggers for automatic alerts on low mood
DROP TRIGGER IF EXISTS trg_mood_alert;
DELIMITER //
CREATE TRIGGER trg_mood_alert AFTER INSERT ON mood_entries
FOR EACH ROW BEGIN
  IF NEW.emoji IN ('🙁','😢') THEN
    DECLARE gid INT;
    SELECT group_id INTO gid FROM group_members WHERE student_id = NEW.student_id ORDER BY created_at DESC LIMIT 1;
    IF gid IS NOT NULL THEN
      INSERT INTO alerts (group_id, student_id, type, message)
      VALUES (gid, NEW.student_id, 'mood', CONCAT('Ánimo bajo detectado: ', NEW.emoji));
    END IF;
  END IF;
END;//
DELIMITER ;

-- seed minimal data
INSERT INTO users (name, email, password, role)
VALUES
  ('Tutor Demo','tutor@demo.com','$2a$10$2ZQhULICwhf66A1VpzwuJeLYe0yoyS9MhUlCT3VkOITkkpFmS6r0e','tutor'),
  ('Alumno Demo','alumno@demo.com','$2a$10$2ZQhULICwhf66A1VpzwuJeLYe0yoyS9MhUlCT3VkOITkkpFmS6r0e','student');

INSERT INTO groups (code, term, tutor_id) VALUES ('SP01SV-24','2024Q2',1);
INSERT INTO group_members (group_id, student_id, term) VALUES (1,2,'2024Q2');
