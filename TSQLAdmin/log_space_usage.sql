select
    DB_NAME(34) 'dbname',
    (total_log_size_in_bytes /1024/1024/1024.) 'total_size_in_GB',
    (used_log_space_in_bytes /1024/1024.) 'used_size_in_MB',
    (used_log_space_in_percent) 'used_size_in_percent',
    (log_space_in_bytes_since_last_backup /1024/1024.) 'used_space_since_last_backup_in_MB'
from frbiefb_slm.sys. dm_db_log_space_usage



