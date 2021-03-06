SELECT OBJECT_NAME(i.OBJECT_ID) AS TableName, i.name AS IndexName, indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') indexstats
INNER JOIN sys.indexes i ON i.OBJECT_ID = indexstats.OBJECT_ID
WHERE i.index_id = indexstats.index_id;


----------------------------------------------------------
--
-- Citation(s)
--
--   support.microsoft.com  |  "SQL query performance might decrease when the SQL Server Database instance has high index fragmentation"  |  https://support.microsoft.com/en-us/help/2755960/sql-query-performance-might-decrease-when-the-sql-server-database-inst
--
----------------------------------------------------------