USE laundryloop_db;

-- =====================================================
-- 1. USERS
-- Existing users table will not be deleted or recreated.
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);


-- =====================================================
-- 2. SERVICES
-- =====================================================

CREATE TABLE IF NOT EXISTS services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    price_per_kg DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO services
    (service_name, description, price_per_kg)
VALUES
    ('Wash & Fold', 'Washing and folding clothes', 0.00),
    ('Dry Cleaning', 'Professional dry cleaning service', 0.00),
    ('Ironing', 'Ironing clothes', 0.00),
    ('Wash & Iron', 'Washing and ironing clothes', 0.00);


-- =====================================================
-- 3. ORDERS
-- COD payment information is stored here.
-- No separate payments table is required.
-- =====================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(20) UNIQUE,

    user_id INT NOT NULL,
    service_id INT NOT NULL,

    quantity_kg DECIMAL(8,2) NOT NULL,
    pickup_address VARCHAR(255) NOT NULL,
    pickup_latitude DECIMAL(10,7),
    pickup_longitude DECIMAL(10,7),
    pickup_date DATE NOT NULL,
    note TEXT,

    order_status ENUM(
        'Pending',
        'Pickup Scheduled',
        'Laundry Received',
        'Washing',
        'Drying',
        'Ironing',
        'Ready for Delivery',
        'Delivered',
        'Cancelled'
    ) NOT NULL DEFAULT 'Pending',

    payment_method ENUM('Cash on Delivery')
        NOT NULL DEFAULT 'Cash on Delivery',

    payment_status ENUM('Pending', 'Paid')
        NOT NULL DEFAULT 'Pending',

    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),

    CONSTRAINT fk_orders_service
        FOREIGN KEY (service_id) REFERENCES services(service_id),

    CONSTRAINT chk_order_quantity CHECK (quantity_kg > 0),
    CONSTRAINT chk_order_amount CHECK (total_amount >= 0),

    INDEX idx_orders_user_date (user_id, created_at),
    INDEX idx_orders_status (order_status)
);


-- =====================================================
-- 4. ORDER STATUS HISTORY
-- Keeps a record of order status changes.
-- =====================================================

CREATE TABLE IF NOT EXISTS order_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status ENUM(
        'Pending',
        'Pickup Scheduled',
        'Laundry Received',
        'Washing',
        'Drying',
        'Ironing',
        'Ready for Delivery',
        'Delivered',
        'Cancelled'
    ) NOT NULL,
    changed_by INT,
    note VARCHAR(255),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,

    FOREIGN KEY (changed_by) REFERENCES users(user_id)
        ON DELETE SET NULL,

    INDEX idx_history_order_time (order_id, changed_at)
);


-- =====================================================
-- 5. COMMUNITY POSTS
-- Supports text posts and external media links.
-- =====================================================

CREATE TABLE IF NOT EXISTS community_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200),
    content TEXT NOT NULL,

    media_type ENUM('none', 'image', 'audio', 'video')
        NOT NULL DEFAULT 'none',
    media_url VARCHAR(2048),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    INDEX idx_posts_created (created_at)
);


-- =====================================================
-- 6. COMMENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES community_posts(post_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    INDEX idx_comments_post_time (post_id, created_at)
);


-- =====================================================
-- 7. POST REACTIONS
-- A user can like OR dislike a post.
-- =====================================================

CREATE TABLE IF NOT EXISTS post_reactions (
    reaction_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    reaction ENUM('like', 'dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES community_posts(post_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_post_user (post_id, user_id)
);


-- =====================================================
-- 8. COMMENT REACTIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS comment_reactions (
    reaction_id INT AUTO_INCREMENT PRIMARY KEY,
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    reaction ENUM('like', 'dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (comment_id) REFERENCES comments(comment_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_comment_user (comment_id, user_id)
);


-- =====================================================
-- 9. RATINGS AND REVIEWS
-- One rating per user per order.
-- =====================================================

CREATE TABLE IF NOT EXISTS ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_rating_user_order (order_id, user_id),

    CONSTRAINT chk_rating_range CHECK (rating BETWEEN 1 AND 5)
);


-- =====================================================
-- 10. EMAIL / PHONE VERIFICATION
-- Store a hash of the verification code, not the code itself.
-- =====================================================

CREATE TABLE IF NOT EXISTS verification_codes (
    verification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,

    channel ENUM('email', 'phone') NOT NULL,
    purpose ENUM('registration', 'password_reset') NOT NULL,

    code_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    verified_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    INDEX idx_verification_user (user_id, channel, purpose)
);


-- =====================================================
-- 11. VERIFY CREATED TABLES
-- =====================================================

SHOW TABLES;

DESCRIBE orders;

