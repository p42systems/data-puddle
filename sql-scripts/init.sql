:on error exit

PRINT 'Creating login and user...';
GO

IF NOT EXISTS(SELECT * FROM sys.sql_logins WHERE name = 'analyst')
BEGIN
    CREATE LOGIN analyst WITH PASSWORD = 'Analyst!Passw0rd';
    PRINT 'Login created: analyst';
END
ELSE
BEGIN
    PRINT 'Login already exists: analyst';
END
GO

ALTER SERVER ROLE processadmin ADD MEMBER analyst;
GO