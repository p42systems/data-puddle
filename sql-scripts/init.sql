CREATE DATABASE AdventureWorks;
GO

USE AdventureWorks;
GO

CREATE LOGIN analyst WITH PASSWORD = 'P@ssw0rd123';
CREATE USER analyst FOR LOGIN analyst;
GO

EXEC sp_addrolemember 'db_datareader', 'analyst';
EXEC sp_addrolemember 'db_datawriter', 'analyst';
GO