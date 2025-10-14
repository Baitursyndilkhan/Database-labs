

-- Part 1.1 Task

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
  employee_id INTEGER,
  first_name TEXT,
  last_name TEXT,
  age INTEGER CHECK (age BETWEEN 18 AND 65),
  salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES (1, 'Alice', 'Ivanova', 30, 45000);
INSERT INTO employees VALUES (2, 'Boris', 'Petrov', 65, 100000);

-- Part 1.2 Task

DROP TABLE IF EXISTS products_catalog;
CREATE TABLE products_catalog (
  product_id INTEGER,
  product_name TEXT,
  regular_price NUMERIC,
  discount_price NUMERIC,
  CONSTRAINT valid_discount CHECK (
    regular_price > 0 AND discount_price > 0 AND discount_price < regular_price
  )
);

INSERT INTO products_catalog VALUES (1, 'Widget A', 100, 80);
INSERT INTO products_catalog VALUES (2, 'Widget B', 50, 45);


-- Part 1.3 Task

DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
  booking_id INTEGER,
  check_in_date DATE,
  check_out_date DATE,
  num_guests INTEGER,
  CHECK (num_guests BETWEEN 1 AND 10),
  CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1, '2025-10-01', '2025-10-05', 2);

-- Part 2.1 Task

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  customer_id INTEGER NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  registration_date DATE NOT NULL
);

INSERT INTO customers VALUES (1, 'a@ex.com', '77001234567', '2025-01-01');

-- Part 2.2 Task

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
  item_id INTEGER NOT NULL,
  item_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity >= 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
  last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory VALUES (1, 'Hammer', 10, 15, NOW());

-- Part 3.1 Task

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  user_id INTEGER,
  username TEXT,
  email TEXT,
  created_at TIMESTAMP,
  CONSTRAINT unique_username UNIQUE (username),
  CONSTRAINT unique_email UNIQUE (email)
);

INSERT INTO users VALUES (1, 'adil', 'adil@ex.com', NOW());

-- Part 3.2 Task

DROP TABLE IF EXISTS course_enrollments;
CREATE TABLE course_enrollments (
  enrollment_id INTEGER,
  student_id INTEGER,
  course_code TEXT,
  semester TEXT,
  UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 100, 'CS101', '2025F');

-- Part 4.1 Task

DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments (
  dept_id INTEGER PRIMARY KEY,
  dept_name TEXT NOT NULL,
  location TEXT
);

INSERT INTO departments VALUES (10, 'IT', 'Almaty');
INSERT INTO departments VALUES (20, 'HR', 'Astana');

-- Part 4.2 Task

DROP TABLE IF EXISTS student_courses;
CREATE TABLE student_courses (
  student_id INTEGER,
  course_id INTEGER,
  enrollment_date DATE,
  grade TEXT,
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (1, 101, '2025-09-01', 'A');

-- Part 5.1 Task

DROP TABLE IF EXISTS employees_dept;
CREATE TABLE employees_dept (
  emp_id INTEGER PRIMARY KEY,
  emp_name TEXT NOT NULL,
  dept_id INTEGER REFERENCES departments(dept_id),
  hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Zhanar', 10, '2025-02-01');

-- Part 5.2 Task

DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

CREATE TABLE authors (
  author_id INTEGER PRIMARY KEY,
  author_name TEXT NOT NULL,
  country TEXT
);

CREATE TABLE publishers (
  publisher_id INTEGER PRIMARY KEY,
  publisher_name TEXT NOT NULL,
  city TEXT
);

CREATE TABLE books (
  book_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INTEGER REFERENCES authors(author_id),
  publisher_id INTEGER REFERENCES publishers(publisher_id),
  publication_year INTEGER,
  isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Aitmatov', 'Kyrgyzstan');
INSERT INTO publishers VALUES (1, 'KazakhPress', 'Almaty');
INSERT INTO books VALUES (1, 'Jamila', 1, 1, 1966, 'ISBN001');

-- Part 5.3 Task

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY,
  category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL,
  category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  order_date DATE NOT NULL
);

CREATE TABLE order_items (
  item_id INTEGER PRIMARY KEY,
  order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products_fk(product_id),
  quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (1, 'Phone', 1);
INSERT INTO orders VALUES (1, '2025-10-10');
INSERT INTO order_items VALUES (1, 1, 1, 2);

-- Part 6.1 Task

DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders_ecom CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers_ecom CASCADE;

CREATE TABLE customers_ecom (
  customer_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  registration_date DATE NOT NULL
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL CHECK (price >= 0),
  stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ecom (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER REFERENCES customers_ecom(customer_id) ON DELETE SET NULL,
  order_date DATE NOT NULL,
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
  order_detail_id INTEGER PRIMARY KEY,
  order_id INTEGER REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers_ecom VALUES (1, 'Alice', 'alice@ex.com', '77001112233', '2025-01-01');
INSERT INTO products VALUES (1, 'Laptop', '15 inch', 1200, 10);
INSERT INTO orders_ecom VALUES (1, 1, '2025-10-01', 1200, 'pending');
INSERT INTO order_details VALUES (1, 1, 1, 1, 1200);

