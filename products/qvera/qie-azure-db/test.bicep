// This script deploys the on-prem solution 

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'student'


// Deploy SQL (Please note that it's NOT secure as we're using a password to connect)
module sql './create-sql-db-for-qie.bicep' = {
  name: 'sqldb'
  params: {
    location: location
    administratorLogin: administratorLogin
    administratorLoginPassword: adminPassword
    sqlDBName: 'qie'
  }
}

var jdbcConnString = 'jdbc:sqlserver://${sql.outputs.sqlServerName}.database.windows.net:1433;database=${sql.outputs.dbName};user=${administratorLogin}@${sql.outputs.sqlServerName};password=${adminPassword};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;'









output sqlserverName string = sql.outputs.sqlServerName
output sqlserverId string = sql.outputs.sqlServerId
output jdbc string = 'jdbc:sqlserver://${sql.outputs.sqlServerName}.database.windows.net:1433;database=${sql.outputs.dbName};user=${administratorLogin}@${sql.outputs.sqlServerName};password=${adminPassword};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;'
output jdbcExample string = 'jdbc:sqlserver://t4yuhfsreo6kk.database.windows.net:1433;database=qie;user=student@t4yuhfsreo6kk;password={your_password_here};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;'
output jdbcout string = jdbcConnString
