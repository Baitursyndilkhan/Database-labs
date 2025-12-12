CREATE TABLE  customers(
                           customer_id serial primary key ,
                           iin varchar(12) unique not NUll,
                           full_name varchar,
                           phone varchar ,
                           email varchar ,
                           status varchar default 'active',
                           created_at timestamptz default  now(),
                           daily_limit_kzt numeric(20 ,2)

);

CREATE  TABLE accounts(
                          account_id  serial primary key,
                          customer_id integer not NULL  references  customers(customer_id),
                          accounts_number text unique  not null ,
                          currency  varchar check (currency in ('KZT' , 'USD' , 'EUR' , 'RUB') ),
                          balance INTEGER,
                          is_active BOOLEAN default  TRUE,
                          opened_at  timestamptz default NOW(),
                          closed_at timestamptz

);

CREATE  TABLE  transactions(
                               transactions_id serial PRIMARY KEY ,
                               from_account_id  bigint REFERENCES  accounts(account_id),
                               to_account_id  BIGINT REFERENCES  accounts(account_id),
                               amount NUMERIC(20 ,2) not null ,
                               currency varchar not null ,
                               exchange_rate numeric(30, 10),
                               amount_kzt numeric(20 ,2),
                               type varchar not null,
                               status varchar default 'pending',
                               created_at timestamptz default  now(),
                               completed_at timestamptz,
                               description text

);

CREATE  table exchange_rates(
                                rate_id serial primary key,
                                from_currency varchar not null,
                                to_currency varchar  not null,
                                rate numeric(30, 10) not null,
                                valid_from timestamptz default  now(),
                                vaild_to timestamptz
);

create  table  audit_log(
                            log_id serial primary key ,
                            table_name  text not null,
                            record_id text ,
                            action varchar not null,
                            old_values jsonb,
                            new_values jsonb,
                            changed_by text,
                            changed_at timestamptz DEFAULT now(),
                            ip_address inet
);
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt)
VALUES
    ('900101300111', 'Alikhan Serikov', '+77015550101', 'alikhan@bank.kz', 'active', 3000000),
    ('900202400222', 'Dana Mukasheva', '+77025550202', 'dana@bank.kz', 'active', 5000000),
    ('900303500333', 'Erlan Aitbay', '+77035550303', 'erlan@bank.kz', 'active', 2000000),
    ('900404600444', 'Aruzhan Kadyrova', '+77045550404', 'aruzhan@bank.kz', 'active', 1000000),
    ('900505700555', 'Nursultan Jan', '+77055550505', 'nurs@bank.kz', 'active', 8000000),
    ('900606800666', 'Marat Kozhabek', '+77065550606', 'marat@bank.kz', 'active', 7000000),
    ('900707900777', 'Asem Tulegen', '+77075550707', 'asem@bank.kz', 'active', 1500000),
    ('900808100888', 'Ruslan Tleubek', '+77085550808', 'ruslan@bank.kz', 'active', 9000000),
    ('900909200999', 'Kamal Omarov', '+77095550909', 'kamal@bank.kz', 'active', 6000000),
    ('911111111111', 'Company KazTech', '+77770000000', 'finance@kaztech.kz', 'active', 50000000);

INSERT INTO accounts (customer_id, accounts_number, currency, balance, is_active)
VALUES
    (1, 'KZ000000000000000001', 'KZT', 1500000, TRUE),
    (1, 'KZ000000000000000002', 'USD', 3000, TRUE),
    (2, 'KZ000000000000000003', 'KZT', 500000, TRUE),
    (3, 'KZ000000000000000004', 'KZT', 1200000, TRUE),
    (4, 'KZ000000000000000005', 'EUR', 800, TRUE),
    (5, 'KZ000000000000000006', 'KZT', 4500000, TRUE),
    (6, 'KZ000000000000000007', 'USD', 9000, TRUE),
    (7, 'KZ000000000000000008', 'KZT', 350000, TRUE),
    (8, 'KZ000000000000000009', 'RUB', 70000, TRUE),
    (10,'KZ000000000000000010', 'KZT', 90000000, TRUE);

INSERT INTO exchange_rates (from_currency, to_currency, rate)
VALUES
    ('USD', 'KZT', 500),
    ('EUR', 'KZT', 550),
    ('RUB', 'KZT', 5.5),
    ('KZT', 'USD', 0.002),
    ('KZT', 'EUR', 0.0018),
    ('KZT', 'RUB', 0.182),
    ('USD', 'EUR', 0.92),
    ('EUR', 'USD', 1.09),
    ('USD', 'RUB', 90),
    ('RUB', 'USD', 0.011);

INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description, completed_at)
VALUES
    (1, 3, 50000, 'KZT', 1, 50000, 'transfer', 'completed', 'Payment', NOW()),
    (3, 1, 20000, 'KZT', 1, 20000, 'transfer', 'completed', 'Refund', NOW()),
    (NULL, 4, 300000, 'KZT', 1, 300000, 'deposit', 'completed', 'Top-up', NOW()),
    (4, NULL, 150000, 'KZT', 1, 150000, 'withdrawal', 'completed', 'Cash-out', NOW()),
    (2, 6, 100, 'USD', 500, 50000, 'transfer', 'completed', 'USD transfer', NOW()),
    (6, 2, 50, 'USD', 500, 25000, 'transfer', 'completed', 'Return funds', NOW()),
    (5, 8, 100, 'EUR', 550, 55000, 'transfer', 'completed', 'EUR transfer', NOW()),
    (8, 5, 50, 'EUR', 550, 27500, 'transfer', 'completed', 'Return EUR', NOW()),
    (9, 1, 10000, 'RUB', 5.5, 55000, 'transfer', 'completed', 'RUB transfer', NOW()),
    (1, 9, 5000, 'KZT', 1, 5000, 'transfer', 'completed', 'Small transfer', NOW());

INSERT INTO audit_log (table_name, record_id, action, new_values, changed_by, ip_address)
VALUES
    ('customers', '1', 'INSERT', '{"name":"Alikhan"}', 'admin', '127.0.0.1'),
    ('customers', '2', 'INSERT', '{"name":"Dana"}', 'admin', '127.0.0.1'),
    ('accounts', '1', 'INSERT', '{"account":"KZ1"}', 'admin', '127.0.0.1'),
    ('accounts', '2', 'INSERT', '{"account":"KZ2"}', 'admin', '127.0.0.1'),
    ('transactions', '1', 'INSERT', '{"amount":50000}', 'system', '127.0.0.1'),
    ('transactions', '2', 'INSERT', '{"amount":20000}', 'system', '127.0.0.1'),
    ('exchange_rates', '1', 'INSERT', '{"usd":"500"}', 'admin', '127.0.0.1'),
    ('exchange_rates', '2', 'INSERT', '{"eur":"550"}', 'admin', '127.0.0.1'),
    ('transactions', '3', 'INSERT', '{"amount":300000}', 'system', '127.0.0.1'),
    ('salary_batch', '0', 'INSERT', '{"batch":"init"}', 'system', '127.0.0.1');


CREATE OR REPLACE FUNCTION process_transfer(
    from_account_number TEXT,
    to_account_number TEXT,
    amount NUMERIC,
    currency VARCHAR,
    description TEXT
)
    RETURNS JSONB
    LANGUAGE plpgsql
AS $$
DECLARE
    from_id INT;
    to_id INT;
    cust_id INT;
    bal NUMERIC;
    limit_kzt NUMERIC;
    spent_today NUMERIC;
    amount_kzt NUMERIC;
    tr_id INT;
    ex_rate NUMERIC;
    from_acc_currency VARCHAR;
    to_acc_currency VARCHAR;
    conversion_rate NUMERIC := 1.0;
    final_amount_to NUMERIC;
BEGIN
    IF amount <= 0 THEN
        RETURN jsonb_build_object(
                'success', false,
                'error_code', 'INVALID_AMOUNT',
                'message', 'Сома теріс болмауы керек'
               );
    END IF;

    IF from_account_number = to_account_number THEN
        RETURN jsonb_build_object(
                'success', false,
                'error_code', 'SAME_ACCOUNT',
                'message', 'Бір шотқа аудару мүмкін емес'
               );
    END IF;


    BEGIN

        SELECT a.account_id, a.balance, a.customer_id, a.currency
        INTO from_id, bal, cust_id, from_acc_currency
        FROM accounts a
        WHERE a.accounts_number = from_account_number
            FOR UPDATE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'FROM_ACCOUNT_NOT_FOUND',
                    'message', 'Жіберуші шоты табылмады: ' || from_account_number
                   );
        END IF;

        SELECT a.account_id, a.currency
        INTO to_id, to_acc_currency
        FROM accounts a
        WHERE a.accounts_number = to_account_number
            FOR UPDATE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'TO_ACCOUNT_NOT_FOUND',
                    'message', 'Алушы шоты табылмады: ' || to_account_number
                   );
        END IF;


        IF NOT EXISTS (
            SELECT 1 FROM accounts
            WHERE account_id = from_id AND is_active = TRUE
        ) THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'FROM_ACCOUNT_INACTIVE',
                    'message', 'Жіберуші шоты белсенді емес'
                   );
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM accounts
            WHERE account_id = to_id AND is_active = TRUE
        ) THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'TO_ACCOUNT_INACTIVE',
                    'message', 'Алушы шоты белсенді емес'
                   );
        END IF;


        IF NOT EXISTS (
            SELECT 1 FROM customers
            WHERE customer_id = cust_id AND status = 'active'
        ) THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'CUSTOMER_INACTIVE',
                    'message', 'Клиент белсенді емес (блокталған/тоқтатылған)'
                   );
        END IF;


        IF bal < amount THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'INSUFFICIENT_BALANCE',
                    'message', 'Ақша жеткіліксіз. Баланс: ' || bal::TEXT,
                    'balance', bal
                   );
        END IF;


        IF currency = 'KZT' THEN
            amount_kzt := amount;
            ex_rate := 1.0;
        ELSE

            SELECT rate INTO ex_rate
            FROM exchange_rates
            WHERE from_currency = currency
              AND to_currency = 'KZT'
              AND vaild_to IS NULL;

            IF NOT FOUND THEN
                RETURN jsonb_build_object(
                        'success', false,
                        'error_code', 'EXCHANGE_RATE_NOT_FOUND',
                        'message', 'Бағам табылмады: ' || currency || ' → KZT'
                       );
            END IF;

            amount_kzt := amount * ex_rate;
        END IF;


        SELECT daily_limit_kzt INTO limit_kzt
        FROM customers WHERE customer_id = cust_id;


        SELECT COALESCE(SUM(amount_kzt), 0) INTO spent_today
        FROM transactions
        WHERE from_account_id = from_id
          AND status = 'completed'
          AND DATE(created_at) = CURRENT_DATE;


        IF spent_today + amount_kzt > limit_kzt THEN
            RETURN jsonb_build_object(
                    'success', false,
                    'error_code', 'DAILY_LIMIT_EXCEEDED',
                    'message', 'Күнделікті лимит асып кетті',
                    'spent_today', spent_today,
                    'this_transfer', amount_kzt,
                    'limit', limit_kzt,
                    'remaining', limit_kzt - spent_today
                   );
        END IF;


        IF from_acc_currency != to_acc_currency THEN

            SELECT rate INTO conversion_rate
            FROM exchange_rates
            WHERE from_currency = from_acc_currency
              AND to_currency = to_acc_currency
              AND vaild_to IS NULL;

            IF NOT FOUND THEN

                DECLARE
                    rate_to_kzt NUMERIC;
                    rate_from_kzt NUMERIC;
                BEGIN
                    SELECT rate INTO rate_to_kzt
                    FROM exchange_rates
                    WHERE from_currency = from_acc_currency
                      AND to_currency = 'KZT'
                      AND vaild_to IS NULL;

                    SELECT rate INTO rate_from_kzt
                    FROM exchange_rates
                    WHERE from_currency = 'KZT'
                      AND to_currency = to_acc_currency
                      AND vaild_to IS NULL;

                    IF rate_to_kzt IS NULL OR rate_from_kzt IS NULL THEN
                        RETURN jsonb_build_object(
                                'success', false,
                                'error_code', 'CONVERSION_RATE_NOT_FOUND',
                                'message', 'Валюта аудару мүмкін емес: ' ||
                                           from_acc_currency || ' → ' || to_acc_currency
                               );
                    END IF;

                    conversion_rate := rate_to_kzt * rate_from_kzt;
                END;
            END IF;

            final_amount_to := amount * conversion_rate;
        ELSE
            final_amount_to := amount;
        END IF;


        SAVEPOINT before_updates;


        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_id;


        UPDATE accounts
        SET balance = balance + final_amount_to
        WHERE account_id = to_id;


        INSERT INTO transactions (
            from_account_id, to_account_id, amount, currency,
            exchange_rate, amount_kzt, type, status, description,
            completed_at
        ) VALUES (
                     from_id, to_id, amount, currency,
                     conversion_rate, amount_kzt, 'transfer', 'completed', description,
                     NOW()
                 ) RETURNING transactions_id INTO tr_id;


        INSERT INTO audit_log (
            table_name, record_id, action,
            new_values, changed_by, ip_address
        ) VALUES (
                     'transactions', tr_id::TEXT, 'INSERT',
                     jsonb_build_object(
                             'transaction_id', tr_id,
                             'from_account', from_account_number,
                             'to_account', to_account_number,
                             'amount', amount,
                             'currency', currency,
                             'converted_amount', final_amount_to,
                             'status', 'completed',
                             'description', description
                     ),
                     CURRENT_USER,
                     '127.0.0.1'::inet
                 );


        COMMIT;


        RETURN jsonb_build_object(
                'success', true,
                'transaction_id', tr_id,
                'message', 'Аударым сәтті орындалды',
                'from_account', from_account_number,
                'to_account', to_account_number,
                'amount', amount,
                'currency', currency,
                'converted_to_amount', final_amount_to,
                'new_balance', bal - amount,
                'timestamp', NOW()::TEXT
               );

    EXCEPTION WHEN OTHERS THEN

        ROLLBACK;


        INSERT INTO audit_log (
            table_name, action, new_values,
            changed_by, ip_address
        ) VALUES (
                     'transfer_errors', 'INSERT',
                     jsonb_build_object(
                             'error', SQLERRM,
                             'error_state', SQLSTATE,
                             'from_account', from_account_number,
                             'to_account', to_account_number,
                             'amount', amount,
                             'currency', currency,
                             'timestamp', NOW()::TEXT
                     ),
                     CURRENT_USER,
                     '127.0.0.1'::inet
                 );


        RETURN jsonb_build_object(
                'success', false,
                'error_code', 'TRANSACTION_FAILED',
                'message', 'Аударым орындалмады: ' || SQLERRM,
                'sql_state', SQLSTATE
               );
    END;
END;
$$;



CREATE OR REPLACE VIEW customer_balance_summary AS
SELECT
    c.customer_id,
    c.full_name,
    c.iin,
    a.account_id,
    a.accounts_number,
    a.currency,
    a.balance,
    a.balance * COALESCE(
            (SELECT rate FROM exchange_rates
             WHERE from_currency = a.currency
               AND to_currency = 'KZT'
               AND vaild_to IS NULL
             LIMIT 1),
            1) AS balance_kzt,
    SUM(
    a.balance * COALESCE(
            (SELECT rate FROM exchange_rates
             WHERE from_currency = a.currency
               AND to_currency = 'KZT'
               AND vaild_to IS NULL
             LIMIT 1),
            1)
       ) OVER (PARTITION BY c.customer_id) AS total_balance_kzt,
    RANK() OVER (
        ORDER BY
                    SUM(
                    a.balance * COALESCE(
                            (SELECT rate FROM exchange_rates
                             WHERE from_currency = a.currency
                               AND to_currency = 'KZT'
                               AND vaild_to IS NULL
                             LIMIT 1),
                            1)
                       ) OVER (PARTITION BY c.customer_id) DESC
        ) AS balance_rank
FROM customers c
         join accounts a ON c.customer_id = a.customer_id;


CREATE OR REPLACE VIEW daily_transaction_report AS
SELECT
    t_date,
    type,
    SUM(amount_kzt) AS total_volume_kzt,
    COUNT(*) AS tx_count,
    AVG(amount_kzt) AS avg_amount_kzt,
    SUM(SUM(amount_kzt)) OVER (ORDER BY t_date) AS running_total_kzt,
    (
        SUM(amount_kzt)
            - LAG(SUM(amount_kzt)) OVER (ORDER BY t_date)
        ) / NULLIF(LAG(SUM(amount_kzt)) OVER (ORDER BY t_date), 0) * 100
        AS day_over_day_growth_pct
FROM (
         SELECT
             DATE(created_at) AS t_date,
             type,
             amount_kzt
         FROM transactions
         WHERE status = 'completed'
     ) s
GROUP BY t_date, type
ORDER BY t_date;
CREATE OR REPLACE VIEW suspicious_activity_view
            WITH (security_barrier = TRUE) AS
SELECT
    t.transactions_id,
    t.from_account_id,
    t.to_account_id,
    t.amount_kzt,
    t.created_at,
    a_from.customer_id AS sender_customer,
    a_to.customer_id   AS receiver_customer
FROM (
         SELECT
             t.*,
             (
                 SELECT COUNT(*)
                 FROM transactions t2
                 WHERE t2.from_account_id = t.from_account_id
                   AND t2.created_at BETWEEN t.created_at - INTERVAL '1 hour'
                     AND t.created_at
             ) AS tx_hour_count,
             EXISTS (
                 SELECT 1
                 FROM transactions t3
                 WHERE t3.from_account_id = t.from_account_id
                   AND t3.transactions_id <> t.transactions_id
                   AND ABS(EXTRACT(EPOCH FROM (t3.created_at - t.created_at))) < 60
             ) AS rapid_transfer
         FROM transactions t
     ) t
         JOIN accounts a_from ON a_from.account_id = t.from_account_id
         JOIN accounts a_to   ON a_to.account_id   = t.to_account_id
WHERE
    t.amount_kzt    >= 5000000
   OR t.tx_hour_count > 10
   OR t.rapid_transfer;




CREATE INDEX idx_customers_iin ON customers(iin);
CREATE INDEX idx_accounts_number ON accounts(accounts_number);
CREATE INDEX idx_transactions_from_account ON transactions(from_account_id);
CREATE INDEX idx_transactions_to_account ON transactions(to_account_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at);


CREATE INDEX idx_customers_email_hash ON customers USING hash(email);


CREATE INDEX idx_audit_log_old_values_gin ON audit_log USING gin(old_values);
CREATE INDEX idx_audit_log_new_values_gin ON audit_log USING gin(new_values);


CREATE INDEX idx_accounts_active ON accounts(account_id, customer_id, balance) WHERE is_active = TRUE;
CREATE INDEX idx_transactions_completed ON transactions(transactions_id, from_account_id, to_account_id, amount, created_at) WHERE status = 'completed';
CREATE INDEX idx_customers_active ON customers(customer_id, full_name, iin) WHERE status = 'active';


CREATE INDEX idx_transactions_from_status_date ON transactions(from_account_id, status, created_at);
CREATE INDEX idx_transactions_amount_status ON transactions(amount, status, currency);
CREATE INDEX idx_exchange_rates_current ON exchange_rates(from_currency, to_currency, valid_from, vaild_to);


CREATE INDEX idx_covering_transactions ON transactions USING btree (from_account_id, created_at DESC) INCLUDE (to_account_id, amount, currency, amount_kzt, status, description);


CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));
CREATE INDEX idx_accounts_number_last4 ON accounts(RIGHT(accounts_number, 4));


CREATE INDEX idx_brin_transactions_created_at ON transactions USING brin(created_at);
CREATE INDEX idx_brin_audit_log_changed_at ON audit_log USING brin(changed_at);


CREATE INDEX idx_accounts_active_number ON accounts(accounts_number, is_active, customer_id);
CREATE INDEX idx_transactions_daily_limit ON transactions(from_account_id, created_at, status, amount_kzt);
CREATE INDEX idx_transactions_large_amounts ON transactions(amount_kzt, status, created_at) WHERE amount_kzt > 1000000;
CREATE INDEX idx_transactions_rapid_check ON transactions(from_account_id, created_at, status);

ANALYZE customers;
ANALYZE accounts;
ANALYZE transactions;
ANALYZE exchange_rates;
ANALYZE audit_log;


EXPLAIN ANALYZE SELECT * FROM customers WHERE iin = '123456789012';
EXPLAIN ANALYZE SELECT * FROM accounts WHERE accounts_number = 'KZ12345678901234567890';
EXPLAIN ANALYZE SELECT * FROM transactions WHERE from_account_id = 1 AND status = 'completed' AND created_at >= CURRENT_DATE - INTERVAL '30 days';
EXPLAIN ANALYZE SELECT * FROM transactions WHERE amount_kzt > 5000000 AND status = 'completed';
EXPLAIN ANALYZE SELECT * FROM audit_log WHERE new_values @> '{"transaction_id": 1}'::jsonb;
EXPLAIN ANALYZE SELECT * FROM customers WHERE LOWER(email) = LOWER('Ali.Aliev@Email.COM');
EXPLAIN ANALYZE SELECT COUNT(*) FROM transactions WHERE created_at BETWEEN '2024-01-01' AND '2024-01-31';
EXPLAIN ANALYZE SELECT from_account_id, to_account_id, amount, currency, created_at FROM transactions WHERE from_account_id = 1 AND created_at >= CURRENT_DATE - INTERVAL '30 days' ORDER BY created_at DESC;


CREATE OR REPLACE FUNCTION process_salary_batch(
    company_account_number TEXT,
    payments JSONB
)
    RETURNS JSONB
    LANGUAGE plpgsql
AS $$
DECLARE
    comp_acc_id INT;
    comp_balance NUMERIC;
    comp_currency VARCHAR;
    total_batch NUMERIC := 0;
    ex_rate NUMERIC;
    pay JSONB;
    pay_iin TEXT;
    pay_amount NUMERIC;
    pay_desc TEXT;
    emp_acc_id INT;
    emp_currency VARCHAR;
    success_count INT := 0;
    failed_count INT := 0;
    tx_results JSONB := '[]'::jsonb;
    lock_key BIGINT := 90001;
BEGIN
    PERFORM pg_advisory_lock(lock_key);

    SELECT account_id, balance, currency
    INTO comp_acc_id, comp_balance, comp_currency
    FROM accounts
    WHERE accounts_number = company_account_number
      AND is_active = TRUE
        FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
                'success', false,
                'error', 'COMPANY_ACCOUNT_NOT_FOUND'
               );
    END IF;

    FOR pay IN SELECT * FROM jsonb_array_elements(payments)
        LOOP
            pay_amount := (pay->>'amount')::NUMERIC;

            SELECT rate INTO ex_rate
            FROM exchange_rates
            WHERE from_currency = comp_currency
              AND to_currency = 'KZT'
              AND vaild_to IS NULL;

            IF ex_rate IS NULL THEN ex_rate := 1; END IF;

            total_batch := total_batch + pay_amount * ex_rate;
        END LOOP;

    IF comp_balance < (SELECT SUM((p->>'amount')::NUMERIC) FROM jsonb_array_elements(payments) p)
    THEN
        RETURN jsonb_build_object(
                'success', false,
                'error', 'INSUFFICIENT_COMPANY_BALANCE',
                'required', total_batch,
                'balance', comp_balance
               );
    END IF;

    FOR pay IN SELECT * FROM jsonb_array_elements(payments)
        LOOP
            pay_iin := pay->>'iin';
            pay_amount := (pay->>'amount')::NUMERIC;
            pay_desc := pay->>'description';

            BEGIN
                SAVEPOINT sp;

                SELECT a.account_id, a.currency
                INTO emp_acc_id, emp_currency
                FROM customers c
                         JOIN accounts a ON a.customer_id = c.customer_id
                WHERE c.iin = pay_iin
                  AND a.is_active = TRUE
                LIMIT 1
                    FOR UPDATE;

                IF emp_acc_id IS NULL THEN
                    failed_count := failed_count + 1;
                    tx_results := tx_results || jsonb_build_object(
                            'iin', pay_iin,
                            'amount', pay_amount,
                            'status', 'failed',
                            'reason', 'EMPLOYEE_ACCOUNT_NOT_FOUND'
                                                );
                    ROLLBACK TO SAVEPOINT sp;
                    CONTINUE;
                END IF;

                IF comp_currency != emp_currency THEN
                    SELECT rate INTO ex_rate
                    FROM exchange_rates
                    WHERE from_currency = comp_currency
                      AND to_currency = emp_currency
                      AND vaild_to IS NULL;

                    IF ex_rate IS NULL THEN
                        failed_count := failed_count + 1;
                        tx_results := tx_results || jsonb_build_object(
                                'iin', pay_iin,
                                'amount', pay_amount,
                                'status', 'failed',
                                'reason', 'NO_EXCHANGE_RATE'
                                                    );
                        ROLLBACK TO SAVEPOINT sp;
                        CONTINUE;
                    END IF;

                    pay_amount := pay_amount * ex_rate;
                END IF;

                UPDATE accounts
                SET balance = balance - pay_amount
                WHERE account_id = comp_acc_id;

                UPDATE accounts
                SET balance = balance + pay_amount
                WHERE account_id = emp_acc_id;

                INSERT INTO audit_log(table_name, action, new_values, changed_by)
                VALUES (
                           'salary_batch',
                           'INSERT',
                           jsonb_build_object(
                                   'company_account', company_account_number,
                                   'employee_iin', pay_iin,
                                   'amount', pay_amount,
                                   'description', pay_desc
                           ),
                           CURRENT_USER
                       );

                success_count := success_count + 1;

                tx_results := tx_results || jsonb_build_object(
                        'iin', pay_iin,
                        'amount', pay_amount,
                        'status', 'success'
                                            );

            EXCEPTION WHEN OTHERS THEN
                failed_count := failed_count + 1;
                tx_results := tx_results || jsonb_build_object(
                        'iin', pay_iin,
                        'amount', pay_amount,
                        'status', 'failed',
                        'error', SQLERRM,
                        'sql_state', SQLSTATE
                                            );
                ROLLBACK TO SAVEPOINT sp;
            END;
        END LOOP;

    PERFORM pg_advisory_unlock(lock_key);

    RETURN jsonb_build_object(
            'success', true,
            'successful_count', success_count,
            'failed_count', failed_count,
            'details', tx_results
           );
END;
$$;

