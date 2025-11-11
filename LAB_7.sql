-- Part 1: Database Setup
CREATE TABLE IF NOT EXISTS departments (
                                           dept_id   INTEGER PRIMARY KEY,
                                           dept_name TEXT NOT NULL,
                                           location  TEXT
);

CREATE TABLE IF NOT EXISTS employees (
                                         emp_id   INTEGER PRIMARY KEY,
                                         emp_name TEXT NOT NULL,
                                         dept_id  INTEGER REFERENCES departments(dept_id),
                                         salary   NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS projects (
                                        project_id INTEGER PRIMARY KEY,
                                        project_name TEXT NOT NULL,
                                        dept_id INTEGER REFERENCES departments(dept_id),
                                        budget NUMERIC(14,2),
                                        created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS project_assignments (
                                                   project_id INTEGER REFERENCES projects(project_id),
                                                   emp_id INTEGER REFERENCES employees(emp_id),
                                                   PRIMARY KEY (project_id, emp_id)
);

TRUNCATE TABLE project_assignments, projects, employees, departments RESTART IDENTITY;

INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'R&D', 'Building D');

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
                                                              (1, 'John Smith', 101, 50000),
                                                              (2, 'Tom Brown', NULL, 52000),
                                                              (3, 'Mary Lee', 102, 60000),
                                                              (4, 'David King', 101, 70000),
                                                              (5, 'Emma Davis', 103, 48000);

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
                                                                     (201, 'Project Alpha', 101, 100000),
                                                                     (202, 'Project Beta', 102, 50000),
                                                                     (203, 'Project Gamma', 101, 200000),
                                                                     (204, 'Project Delta', 104, 30000);

INSERT INTO project_assignments (project_id, emp_id) VALUES
                                                         (201, 1),
                                                         (201, 4),
                                                         (202, 3),
                                                         (203, 4),
                                                         (204, 5);

-- Part 2: Creating Basic Views
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id;

CREATE OR REPLACE VIEW dept_statistics AS
SELECT d.dept_id, d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       COALESCE(ROUND(AVG(e.salary)::numeric,2),0) AS average_salary,
       COALESCE(MAX(e.salary),0) AS max_salary,
       COALESCE(MIN(e.salary),0) AS min_salary
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

CREATE OR REPLACE VIEW project_overview AS
SELECT p.project_id, p.project_name, p.budget, d.dept_name, d.location,
       (SELECT COUNT(1) FROM employees e WHERE e.dept_id = d.dept_id) AS team_size
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id;

CREATE OR REPLACE VIEW high_earners AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

-- Part 3: Modifying and Managing Views
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name, d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
           END AS salary_grade
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id;

ALTER VIEW high_earners RENAME TO top_performers;

CREATE TEMP VIEW temp_view AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;

-- Part 4: Updatable Views
CREATE OR REPLACE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary FROM employees;

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);

-- Part 5: Materialized Views
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id, d.dept_name,
       COUNT(e.emp_id) AS total_employees,
       COALESCE(SUM(e.salary),0) AS total_salaries,
       COUNT(p.project_id) FILTER (WHERE p.project_id IS NOT NULL) AS total_projects,
       COALESCE(SUM(p.budget),0) AS total_project_budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

REFRESH MATERIALIZED VIEW dept_summary_mv;

CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_id, p.project_name, p.budget, d.dept_name,
       (SELECT COUNT(*) FROM project_assignments pa WHERE pa.project_id = p.project_id) AS assigned_employees
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

REFRESH MATERIALIZED VIEW project_stats_mv;

-- Part 6: Database Roles
DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='analyst') THEN
            CREATE ROLE analyst;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='data_viewer') THEN
            CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='report_user') THEN
            CREATE ROLE report_user LOGIN PASSWORD 'report456';
        END IF;
    END$$;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='db_creator') THEN
            CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='user_manager') THEN
            CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='admin_user') THEN
            CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;
        END IF;
    END$$;

GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='hr_team') THEN
            CREATE ROLE hr_team;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='finance_team') THEN
            CREATE ROLE finance_team;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='it_team') THEN
            CREATE ROLE it_team;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='hr_user1') THEN
            CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='hr_user2') THEN
            CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='finance_user1') THEN
            CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';
        END IF;
        GRANT hr_team TO hr_user1;
        GRANT hr_team TO hr_user2;
        GRANT finance_team TO finance_user1;
    END$$;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

-- Part 7: Advanced Role Management
DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='read_only') THEN
            CREATE ROLE read_only;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='junior_analyst') THEN
            CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='senior_analyst') THEN
            CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
        END IF;
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
        GRANT read_only TO junior_analyst;
        GRANT read_only TO senior_analyst;
        GRANT INSERT, UPDATE ON employees TO senior_analyst;
    END$$;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='project_manager') THEN
            CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
        END IF;
    END$$;

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='temp_owner') THEN
            CREATE ROLE temp_owner LOGIN;
        END IF;
    END$$;

CREATE TABLE IF NOT EXISTS temp_table (id INT PRIMARY KEY);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO CURRENT_USER;
DROP OWNED BY temp_owner;
DROP ROLE IF EXISTS temp_owner;

CREATE OR REPLACE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- Part 8: Practical Scenarios
CREATE OR REPLACE VIEW dept_dashboard AS
SELECT d.dept_id, d.dept_name, d.location,
       COUNT(e.emp_id) AS employee_count,
       COALESCE(ROUND(AVG(e.salary)::numeric,2),0) AS average_salary,
       COUNT(p.project_id) FILTER (WHERE p.project_id IS NOT NULL) AS active_projects,
       COALESCE(SUM(p.budget),0) AS total_project_budget,
       CASE WHEN COUNT(e.emp_id)=0 THEN 0
            ELSE ROUND((COALESCE(SUM(p.budget),0)/NULLIF(COUNT(e.emp_id),0))::numeric,2)
           END AS budget_per_employee
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

ALTER TABLE projects
    ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW high_budget_projects AS
SELECT p.project_id, p.project_name, p.budget, d.dept_name, p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
           END AS approval_status
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='viewer_role') THEN
            CREATE ROLE viewer_role;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='entry_role') THEN
            CREATE ROLE entry_role;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='analyst_role') THEN
            CREATE ROLE analyst_role;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='manager_role') THEN
            CREATE ROLE manager_role;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='alice') THEN
            CREATE ROLE alice LOGIN PASSWORD 'alice123';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='bob') THEN
            CREATE ROLE bob LOGIN PASSWORD 'bob123';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='charlie') THEN
            CREATE ROLE charlie LOGIN PASSWORD 'charlie123';
        END IF;
    END$$;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
