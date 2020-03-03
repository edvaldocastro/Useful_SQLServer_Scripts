SELECT  '
CREATE LOGIN ' + name + ' WITH PASSWORD = '
        + CONVERT(VARCHAR(MAX), password_hash, 1) + ' HASHED,SID = '
        + CONVERT(VARCHAR(MAX), sid, 1) + ' ,CHECK_POLICY = '
        + CASE is_policy_checked
            WHEN 1 THEN 'ON'
            ELSE 'OFF'
          END + ', ' + ' CHECK_EXPIRATION = ' + CASE is_expiration_checked
                                                  WHEN 1 THEN 'ON'
                                                  ELSE 'OFF'
                                                END + ', '
        + ' DEFAULT_DATABASE = ' + default_database_name
        + ' ,DEFAULT_LANGUAGE = ' + default_language_name
FROM    sys.sql_logins
WHERE name in ( 'login1','login2','login3')
