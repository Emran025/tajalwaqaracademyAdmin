```sql

-- 1) Create the database
CREATE DATABASE `tajalwaqar`
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
USE `tajalwaqar`;

-- 2) Lookup tables
CREATE TABLE `roles` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,            -- 'supervisor','teacher','power_admin'
  `name_ar` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_roles_code` (`code`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


INSERT INTO roles (code, name_ar) VALUES
  ('power_admin', 'مشرف نظام'),   -- دور صاحب الصلاحيات العليا
  ('supervisor',  'مشرف'),         -- دور المشرف العادي
  ('teacher',     'معلم'),         -- دور المعلم
  ('student',     'طالب');         -- دور الطالب (بعد الموافقة)


-- ==================================================================================================================================
-- 3) Main users table (supervisors, teachers, power_admins, students after approval) تم تحديث هذا الجدول ليحتوي على جميع بيانات المعلم
-- ==================================================================================================================================
CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,        -- هذا الحقل سيقابل `teacherID` في Flutter
  `role_id` TINYINT UNSIGNED NOT NULL,               -- FK > roles table
  `status` ENUM('active','disabled','stopped') NOT NULL DEFAULT 'active', -- يطابق ActiveStatus. 'pending' يمكن أن يكون حالة أولية قبل التفعيل الكامل

  -- Basic Info (من TeacherModel)
  `name` VARCHAR(150) NOT NULL,                     -- يطابق `name`
  `gender` ENUM('Male', 'Female') NOT NULL,          -- يطابق `gender`
  `birth_date` DATE NULL,                            -- يطابق `birthDate`, استخدام نوع DATE أفضل
  `email` VARCHAR(100) NOT NULL,                     -- يطابق `email`
  `password_hash` VARCHAR(255) NULL,                 -- موجود بالفعل
  `profile_picture_url` VARCHAR(255) NULL,           -- يطابق `pic`، اسم أوضح

  -- Contact Info (من TeacherModel)
  `phone_zone` VARCHAR(10) NULL,                     -- يطابق `phoneZone` (رمز الدولة)
  `phone` VARCHAR(20) NOT NULL,                      -- يطابق `phone`
  `whatsapp_zone` VARCHAR(10) NULL,                  -- يطابق `whatsAppZone`
  `whatsapp_phone` VARCHAR(20) NULL,                 -- يطابق `whatsAppPhone`

  -- Professional Info (من TeacherModel)
  `qualification` VARCHAR(255) NULL,                 -- يطابق `qualification`
  `experience_years` SMALLINT UNSIGNED NULL,         -- يطابق `experienceYears`

  -- Location Info (من TeacherModel)
  `country` VARCHAR(100) NULL,                       -- يطابق `country`
  `residence` VARCHAR(100) NULL,                     -- يطابق `residence`
  `city` VARCHAR(100) NULL,                          -- يطابق `city` (حقل جديد)

  -- Academy-specific Info (من TeacherModel)
  `available_time` TIME NULL,                        -- يطابق `availableTime`, نوع TIME أفضل من VARCHAR إذا كان الوقت محدداً
  `stop_reasons` TEXT NULL,                          -- يطابق `stopReasons`
  `memorization_level` VARCHAR(100) NULL,            -- للطلاب، لكن يمكن تركه NULL للمعلمين
  `is_verificated` tinyint(1) DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_phone` (`phone_zone`, `phone`),
  KEY `fk_users_role` (`role_id`),
  KEY `idx_users_status`           (`status`),
  KEY `idx_users_created_at`       (`created_at`),

  KEY `idx_halqas_is_verificated`   (`is_verificated`)
  --==========================
  CONSTRAINT `fk_users_role`
    FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO users
  (role_id, name, gender,
   email, phone, password_hash, verification_code, status, created_at, updated_at)
VALUES
  (
    1,
    -- @roleId,             -- = 1 إذا كُنت أضفت records بالترتيب السابق
    'Super Admin',
    'Male',
    'admin@example.com',
    '+967712345000',
    '$2y$10$feh.PT6WNEBKAkFj9b9.Pun9pgXeAge4Veq8vHEqbyhVo2D5XZ.nu', -- 'admin$$$000',
    1,
    'active',
    NOW(),
    NOW()
  );

-- ==================================================================================================================================
-- 4) Registration requests (both students & teachers) تم تحديث جدول طلبات التسجيل ليشمل الحقول الجديدة
-- ==================================================================================================================================
CREATE TABLE `registration_requests` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NULL,                      -- بعد القبول، يشير إلى users.id
  `type` ENUM('student','teacher') NOT NULL,
  `name` VARCHAR(150) NOT NULL,                     -- تم التغيير من first_name, last_name
  `gender` ENUM('Male', 'Female') NOT NULL,
  `birth_date` DATE NULL,
  `email` VARCHAR(100) NOT NULL,
  `phone_zone` VARCHAR(10) NULL,
  `phone` VARCHAR(20) NOT NULL,
  `whatsapp_zone` VARCHAR(10) NULL,
  `whatsapp_phone` VARCHAR(20) NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `country` VARCHAR(100) NULL,
  `residence` VARCHAR(100) NULL,
  `city` VARCHAR(100) NULL,
  `qualification` VARCHAR(255) NULL,
  `experience_years` SMALLINT UNSIGNED NULL,
  `memorization_level` VARCHAR(100) NULL,
  `available_time` TIME NULL,
  `status` ENUM('new','accepted','rejected') NOT NULL DEFAULT 'new',
  `note` TEXT NULL,                                 -- تعليق من الإدارة
  `is_verificated` tinyint(1) DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_req_email` (`email`),
  UNIQUE KEY `uq_req_phone` (`phone_zone`, `phone`)
  --==================================
  KEY `idx_req_status`       (`status`),
  KEY `idx_req_created_at`   (`created_at`)
  KEY `idx_halqas_is_verificated`   (`is_verificated`)

) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ==================================================================================================================================
-- 5) Halqas (circles/classes) جدول جديد لتخزين معلومات الحلقات
-- ==================================================================================================================================
CREATE TABLE `halqas` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `archived_at` DATETIME NULL,
  `gender` ENUM('Male', 'Female') NOT NULL, -- what student in (famals , males)
    `residence` VARCHAR(100) NULL, -- country
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_halqas_is_active`   (`is_active`)

) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ==================================================================================================================================
-- جدول وسيط لربط المعلمين بالحلقات (علاقة متعدد إلى متعدد) هذا هو الحل الصحيح لتخزين `List<int> halqas`
-- ==================================================================================================================================
CREATE TABLE `teacher_halqas` (
  `teacher_id` INT UNSIGNED NOT NULL,
  `halqa_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`teacher_id`, `halqa_id`), -- يضمن عدم تكرار نفس الربط
  KEY `idx_th_halqa` (`halqa_id`),
  CONSTRAINT `fk_teacher_halqas_teacher`
    FOREIGN KEY (`teacher_id`) REFERENCES `users`(`id`)
      ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_teacher_halqas_halqa`
    FOREIGN KEY (`halqa_id`) REFERENCES `halqas`(`id`)
      ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- 6) Student assignments (which student is in which halqa)
CREATE TABLE `halqa_students` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `halqa_id` INT UNSIGNED NOT NULL,
  `student_id` INT UNSIGNED NOT NULL,     -- FK > users(id) where role=student
  `assigned_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hs_halqa_student` (`halqa_id`,`student_id`),
  KEY `fk_hs_halqa` (`halqa_id`),
  KEY `fk_hs_student` (`student_id`),

  KEY `idx_hs_student_assigned` (`student_id`,`assigned_at`),
  KEY `idx_hs_halqa_left`      (`halqa_id`,`left_at`),

  CONSTRAINT `fk_hs_halqa`
    FOREIGN KEY (`halqa_id`) REFERENCES `halqas`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_hs_student`
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--=====================================================================================================

CREATE TABLE `units` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,       -- e.g. 'juz','hizb','half_hizb','quarter_hizb','page'
  `name_ar` VARCHAR(30) NOT NULL,    -- 'جزء','حزب',…
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
)  ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO `units` (code, name_ar) VALUES
  ('juz',            'جزء'),
  ('hizb',           'حزب'),
  ('half_hizb',      'نصف حزب'),
  ('quarter_hizb',   'ربع حزب'),
  ('page',           'صفحة');

CREATE TABLE `frequencies` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,           -- e.g. 'daily','weekly','twice_weekly'
  `name_ar` VARCHAR(50) NOT NULL,        -- 'يومي','أسبوعي','مرتين في الأسبوع'
  `days_count` TINYINT UNSIGNED NOT NULL, -- عدد مرات المتابعة في الأسبوع
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO `frequencies` (code, name_ar, days_count) VALUES
  ('daily',         'يومي',       7),
  ('weekly',        'أسبوعي',     1),
  ('twice_weekly',  'مرتين في الأسبوع', 2),
  ('thrice_weekly', 'ثلاث مرات في الأسبوع', 3);


CREATE TABLE `tracking_types` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,           -- e.g. 'memorize','review','recitation'
  `name_ar` VARCHAR(50) NOT NULL,        -- 'الحفظ','المراجعة','السرد'
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
INSERT INTO `tracking_types` (code, name_ar) VALUES
  ('memorize',  'الحفظ'),
  ('review',    'المراجعة'),
  ('recitation','السرد');


CREATE TABLE `tracking_plans` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `halqa_student_id` INT UNSIGNED NOT NULL,
  `type_id` TINYINT UNSIGNED NOT NULL,    -- FK > tracking_types(id)
  `frequency_id` TINYINT UNSIGNED NOT NULL, -- FK > frequencies(id)
  `unit_id` TINYINT UNSIGNED NOT NULL,
  `amount` SMALLINT UNSIGNED NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),

  KEY `idx_tp_hs_type`       (`halqa_student_id`,`type_id`),
  KEY `idx_tp_hs_frequency`  (`halqa_student_id`,`frequency_id`),
  KEY `idx_tp_date_range`    (`start_date`,`end_date`),

  KEY `fk_tp_hs` (`halqa_student_id`),
  KEY `fk_tp_type` (`type_id`),
  KEY `fk_tp_freq` (`frequency_id`),
  KEY `fk_tp_unit` (`unit_id`),

  CONSTRAINT `fk_tp_type`
    FOREIGN KEY (`type_id`) REFERENCES `tracking_types`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_tp_freq`
    FOREIGN KEY (`frequency_id`) REFERENCES `frequencies`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_tp_unit`
    FOREIGN KEY (`unit_id`) REFERENCES `units`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_tp_hs`
    FOREIGN KEY (`halqa_student_id`) REFERENCES `halqa_students`(`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE `attendance_types` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,           -- e.g. 'memorize','review','recitation'
  `name_ar` VARCHAR(50) NOT NULL,        -- 'الحفظ','المراجعة','السرد'
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
)  ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
INSERT INTO `attendance_types` (code, name_ar) VALUES
  ('absent',  'غياب'),
  ('present',    'حاضر');

CREATE TABLE `tracking_sources` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,           -- e.g. 'memorize','review','recitation'
  `name_ar` VARCHAR(50) NOT NULL,        -- 'الحفظ','المراجعة','السرد'
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
)  ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
INSERT INTO `tracking_sources` (code, name_ar) VALUES
  ('auto_generated',  'تلقائي'),
  ('manual',    'يدوي');


-- 7) Daily tracking entries
CREATE TABLE `daily_tracking` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `halqa_student_id` INT UNSIGNED NOT NULL,
  `track_date` DATE NOT NULL,
  `attendance` TINYINT UNSIGNED NOT NULL,  -- FK > attendance_types(id)
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dt_hs_date` (`halqa_student_id`, `track_date`),
  KEY `fk_dt_student` (`halqa_student_id`),
  KEY `fk_dt_attendance` (`attendance`),

  KEY `idx_dt_date`           (`track_date`),
  KEY `idx_dt_student_date`   (`halqa_student_id`,`track_date`),

  CONSTRAINT `fk_dt_student`
    FOREIGN KEY (`halqa_student_id`) REFERENCES `halqa_students`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_dt_attendance`
    FOREIGN KEY (`attendance`) REFERENCES `attendance_types`(`id`)
      ON UPDATE CASCADE ON DELETE RESTRICT
)  ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


CREATE TABLE `daily_tracking_detail` (
  `tracking_id` INT UNSIGNED NOT NULL,     -- FK > daily_tracking(id)
  `type_id`     TINYINT UNSIGNED NOT NULL, -- FK > tracking_types(id)
  `plan_id`     INT UNSIGNED NULL,         -- FK > tracking_plans(id)
  `completed`   SMALLINT UNSIGNED NULL,
  `source`      TINYINT UNSIGNED NULL,     -- FK > tracking_sources(id)
  `note`        TEXT NULL,
  PRIMARY KEY (`tracking_id`, `type_id`),
  KEY `fk_dtd_tracking` (`tracking_id`),
  KEY `fk_dtd_type` (`type_id`),
  KEY `fk_dtd_plan` (`plan_id`),
  KEY `fk_dtd_source` (`source`),

  KEY `idx_dtd_plan_type` (`plan_id`,`type_id`),
  KEY `idx_dtd_type_plan` (`type_id`,`plan_id`),

  CONSTRAINT `fk_dtd_tracking`
    FOREIGN KEY (`tracking_id`) REFERENCES `daily_tracking`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_dtd_type`
    FOREIGN KEY (`type_id`) REFERENCES `tracking_types`(`id`)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_dtd_plan`
    FOREIGN KEY (`plan_id`) REFERENCES `tracking_plans`(`id`)
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_dtd_source`
    FOREIGN KEY (`source`) REFERENCES `tracking_sources`(`id`)
      ON UPDATE CASCADE ON DELETE RESTRICT
)  ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


DELIMITER $$
CREATE TRIGGER `trg_after_insert_daily_tracking`
AFTER INSERT ON `daily_tracking`
FOR EACH ROW
BEGIN
  INSERT INTO `daily_tracking_detail` (`tracking_id`, `type_id`)
    SELECT NEW.id, id FROM `tracking_types`;
END$$
DELIMITER ;

-- 8) Monthly reports
CREATE TABLE `monthly_reports` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `halqa_student_id` INT UNSIGNED NOT NULL,
  `year_month` CHAR(7) NOT NULL,           -- 'YYYY-MM'
  `total_memorize` VARCHAR(100) NULL,
  `total_review` VARCHAR(100) NULL,
  `absence_count` SMALLINT UNSIGNED NULL,
  `score_quran` TINYINT UNSIGNED NULL,
  `score_tajweed` TINYINT UNSIGNED NULL,
  `score_tafsir` TINYINT UNSIGNED NULL,
  `behavior_eval` VARCHAR(255) NULL,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mr_hs_month` (`halqa_student_id`,`year_month`),
  KEY `fk_mr_hs` (`halqa_student_id`),
  CONSTRAINT `fk_mr_hs`
    FOREIGN KEY (`halqa_student_id`) REFERENCES `halqa_students`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 9) Import logs for bulk Excel uploads
CREATE TABLE `import_logs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `file_name` VARCHAR(255) NOT NULL,
  `uploaded_by` INT UNSIGNED NOT NULL,      -- FK > users(id)
  `upload_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_rows` INT UNSIGNED NOT NULL,
  `success_count` INT UNSIGNED NOT NULL,
  `error_count` INT UNSIGNED NOT NULL,
  `errors_summary` TEXT NULL,               -- JSON or text
  PRIMARY KEY (`id`),
  KEY `fk_il_uploaded_by` (`uploaded_by`),
  CONSTRAINT `fk_il_uploaded_by`
    FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 10) Notifications
CREATE TABLE `notifications` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `senedr` INT UNSIGNED NOT NULL,
  `recever` INT UNSIGNED NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `content` TEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_nt_user_senedr` (`senedr`),
  CONSTRAINT `fk_nt_user_senedr`
    FOREIGN KEY (`senedr`) REFERENCES `users`(`id`)
  KEY `fk_nt_user_recever` (`recever`),
  CONSTRAINT `fk_nt_user_recever`
    FOREIGN KEY (`recever`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 11) Teacher notes to supervisor
CREATE TABLE `teacher_notes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `teacher_id` INT UNSIGNED NOT NULL,
  `student_id` INT UNSIGNED NOT NULL,
  `note` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_tn_teacher` (`teacher_id`),
  KEY `fk_tn_student` (`student_id`),
  CONSTRAINT `fk_tn_teacher`
    FOREIGN KEY (`teacher_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_tn_student`
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 12) OTP verifications (2FA)
CREATE TABLE `otp_codes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `registration_request_id` INT UNSIGNED NOT NULL,
  `otp_code` VARCHAR(10) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `used` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_otp_user` (`user_id`),
  CONSTRAINT `fk_otp_user`
    FOREIGN KEY (`registration_request_id`) REFERENCES `registration_requests`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 13) Password reset tokens
CREATE TABLE `password_resets` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `used` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_pr_user` (`user_id`),
  CONSTRAINT `fk_pr_user`
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 15) Audit log (optional)

CREATE TABLE `verification_tokens` (
  `id` int(11) NOT NULL,
  `registration_request_id` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_al_user` (`registration_request_id`),
  KEY `idx_halqas_is_used`   (`is_used`)
  CONSTRAINT `fk_al_user`
    FOREIGN KEY (`registration_request_id`) REFERENCES `registration_requests`(`id`)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 15) Audit log (optional)
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_blocked` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_al_user` (`user_id`),
  KEY `idx_halqas_is_blocked`   (`is_blocked`)
  CONSTRAINT `fk_al_user`
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 14) Audit log (optional)
CREATE TABLE `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NULL,
  `action` VARCHAR(100) NOT NULL,       -- e.g. 'create_user','update_daily'
  `target_table` VARCHAR(100) NOT NULL,
  `target_id` INT UNSIGNED NULL,
  `old_data` TEXT NULL,
  `new_data` TEXT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_al_user` (`user_id`),
  CONSTRAINT `fk_al_user`
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


```
