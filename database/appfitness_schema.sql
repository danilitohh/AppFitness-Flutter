-- Esquema MySQL/MariaDB para AppFitness
-- Motor probado con XAMPP MariaDB 10.4.x

CREATE DATABASE IF NOT EXISTS appfitness
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE appfitness;

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(40) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tickets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id VARCHAR(40) NOT NULL,
  email VARCHAR(255) NOT NULL,
  reset_code_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_password_reset_user (user_id),
  KEY idx_password_reset_email_expires (email, expires_at),
  CONSTRAINT fk_password_reset_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fitness_goals (
  user_id VARCHAR(40) NOT NULL,
  calorie_goal INT UNSIGNED NOT NULL DEFAULT 2200,
  water_goal_ml INT UNSIGNED NOT NULL DEFAULT 2500,
  workout_goal_minutes INT UNSIGNED NOT NULL DEFAULT 45,
  target_weight_kg DECIMAL(5,2) NOT NULL DEFAULT 70.00,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_goals_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_goals_calorie_goal CHECK (calorie_goal > 0),
  CONSTRAINT chk_goals_water_goal CHECK (water_goal_ml > 0),
  CONSTRAINT chk_goals_workout_goal CHECK (workout_goal_minutes > 0),
  CONSTRAINT chk_goals_target_weight CHECK (target_weight_kg > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS workouts (
  id VARCHAR(40) NOT NULL,
  user_id VARCHAR(40) NOT NULL,
  name VARCHAR(120) NOT NULL,
  category VARCHAR(80) NOT NULL,
  duration_minutes INT UNSIGNED NOT NULL,
  calories_burned INT UNSIGNED NOT NULL,
  workout_date DATE NOT NULL,
  intensity ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
  completed TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_workouts_user_date (user_id, workout_date),
  CONSTRAINT fk_workouts_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_workouts_duration CHECK (duration_minutes > 0),
  CONSTRAINT chk_workouts_calories CHECK (calories_burned > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS meals (
  id VARCHAR(40) NOT NULL,
  user_id VARCHAR(40) NOT NULL,
  type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
  name VARCHAR(160) NOT NULL,
  calories INT UNSIGNED NOT NULL,
  protein INT UNSIGNED NOT NULL,
  carbs INT UNSIGNED NOT NULL,
  fats INT UNSIGNED NOT NULL,
  meal_date DATE NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_meals_user_date (user_id, meal_date),
  CONSTRAINT fk_meals_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_meals_calories CHECK (calories > 0),
  CONSTRAINT chk_meals_protein CHECK (protein >= 0),
  CONSTRAINT chk_meals_carbs CHECK (carbs >= 0),
  CONSTRAINT chk_meals_fats CHECK (fats >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS weight_entries (
  id VARCHAR(40) NOT NULL,
  user_id VARCHAR(40) NOT NULL,
  weight_kg DECIMAL(5,2) NOT NULL,
  entry_date DATE NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_weight_user_date (user_id, entry_date),
  CONSTRAINT fk_weight_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_weight_positive CHECK (weight_kg > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS water_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id VARCHAR(40) NOT NULL,
  log_date DATE NOT NULL,
  water_ml INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_water_user_date (user_id, log_date),
  KEY idx_water_user_date (user_id, log_date),
  CONSTRAINT fk_water_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_water_nonnegative CHECK (water_ml >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
