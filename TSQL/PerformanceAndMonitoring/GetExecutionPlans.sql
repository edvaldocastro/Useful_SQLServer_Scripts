

SELECT st.text, qp.query_plan
FROM sys.dm_exec_cached_plans cp
  CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
  CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.dbid = db_id('DatabaseName')



SELECT qp.query_plan
FROM sys.dm_exec_cached_plans cp
  CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
  CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.dbid = 9 AND
  st.text = 'SELECT sh.SalesOrderID, sh.CustomerID, sh.OrderDate, 
  sd.ProductID, sd.LineTotal
FROM Sales.SalesOrderHeader sh JOIN Sales.SalesOrderDetail sd 
  ON sh.SalesOrderID = sd.SalesOrderID 
WHERE sd.LineTotal BETWEEN 1000 AND 1500;';
