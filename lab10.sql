/* ------------------------------------------------------------
   1) INSERT with calculated salary and current date
   Q: What happens if we omit the column list?
   A: INSERT will expect values for ALL columns in table order.
------------------------------------------------------------- */

INSERT INTO employees (first_name, last_name, salary, hire_date)
VALUES ('Emily', 'Stone', 55000 * 1.2, NOW());


/* ------------------------------------------------------------
   2) DELETE rows where department OR salary is NULL
   Q: Why can't we use = NULL ?
   A: Because NULL is checked using IS NULL, not =.
------------------------------------------------------------- */

DELETE FROM employees
WHERE department IS NULL
   OR salary IS NULL;


/* ------------------------------------------------------------
   3) UPDATE using CASE expression
   Q: Why is “40000 < salary < 70000” invalid?
   A: SQL does not support chained comparisons.
      Must use BETWEEN instead.
------------------------------------------------------------- */

UPDATE employees
SET department = CASE
                     WHEN salary > 70000 THEN 'Management'
                     WHEN salary BETWEEN 40000 AND 70000 THEN 'Experienced'
                     ELSE 'Junior'
    END;


/* ------------------------------------------------------------
   4) UPDATE all salary values to 120% of AVG salary
   Q: Why must AVG be inside a subquery?
   A: Because aggregate functions cannot be directly used
      in SET without a subquery.
------------------------------------------------------------- */

UPDATE employees
SET salary = (SELECT AVG(salary) * 1.2 FROM employees);


/* ------------------------------------------------------------
   5) UPDATE salary and status ONLY for Sales department
   Q: Why can't we use (SELECT salary*1.15 FROM employees)?
   A: That subquery returns multiple rows → invalid.
      Instead, multiply the existing row value directly.
------------------------------------------------------------- */

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';
