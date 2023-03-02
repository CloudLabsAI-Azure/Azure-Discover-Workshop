## Exercise 3: Test the Sample App

In this exercise, you use the **Azure Database Migration Service** here `https://azure.microsoft.com/services/database-migration/` (DMS) to migrate the `WideWorldImporters` database from an on-premises SQL Server 2008 R2 database into Azure SQL Managed Instance (SQL MI). WWI mentioned the importance of their gamer information web application in driving revenue, so for this migration, the online migration option is used to minimize downtime. Targeting the **Business Critical service tier** here `https://docs.microsoft.com/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview#managed-instance-service-tiers` allows WWI to meet its customer's high-availability requirements.

> The Business Critical service tier is designed for business applications with the highest performance and high-availability (HA) requirements. To learn more, read the Managed Instance service tiers documentation.

### Task 1: Create an SMB network share on the LEGACYSQL2008 VM

In this task, you create a new SMB network share on the legacysql2008 VM. DMS uses this shared folder for retrieving backups of the `WideWorldImporters` database during the database migration process.

1. On the LEGACYSQL2008 VM, open **Windows Explorer** by selecting its icon on the Windows Taskbar.

   ![The Windows Explorer icon is highlighted in the Windows Taskbar.](media/1.121.png "Windows Taskbar")

2. In the Windows Explorer window, expand **Computer** in the tree view, select **Windows (C:)**, and then select **New folder** in the top menu.

   ![In Windows Explorer, Windows (C:) is selected under Computer in the left-hand tree view, and New folder is highlighted in the top menu.](media/1.122.png "Windows Explorer")

3. Name the new folder **dms-backups**, then right-click the folder and select **Share with** and **Specific people** in the context menu.

   ![In Windows Explorer, the context menu for the dms-backups folder is displayed, with Share with and Specific people highlighted.](media/1.123.png "Windows Explorer")

4. In the File Sharing dialog, ensure the **DemoUser** is listed with a **Read/Write** permission level, and then select **Share**.

   ![In Windows Explorer, the context menu for the dms-backups folder is displayed, with Share with and Specific people highlighted.](media/1.124.png "Windows Explorer")

5. In the **Network discovery and file sharing** dialog, select the default value of **No, make the network that I am connected to a private network**.

   ![In the Network discovery and file sharing dialog, No, make the network that I am connected to a private network is highlighted.](media/1.125.png "Network discovery and file sharing")

6. Back on the File Sharing dialog, note the shared folder's path, ```\\LEGACYSQL2008\dms-backups```, and select **Done** to complete the sharing process.

   ![The Done button is highlighted on the File Sharing dialog.](media/1.126.png "File Sharing")

### Task 2: Change MSSQLSERVER service to run under sqlmiuser account

In this task, you use the SQL Server Configuration Manager to update the service account used by the SQL Server (MSSQLSERVER) service to the `DemoUser` account. Changing the account used for this service ensures it has the appropriate permissions to write backups to the shared folder.

1. On your LEGACYSQL2008 VM, select the **Start menu**, enter "sql configuration" into the search bar, and then select **SQL Server Configuration Manager** from the search results.

   ![In the Windows Start menu, "sql configuration" is entered into the search box, and SQL Server Configuration Manager is highlighted in the search results.](media/1.127.png "Windows search")

   > **Note**
   >
   > Be sure to choose **SQL Server Configuration Manager**, and not **SQL Server 2017 Configuration Manager**, which does not work for the installed SQL Server 2008 R2 database.

2. In the SQL Server Configuration Managed dialog, select **SQL Server Services** from the tree view on the left, then right-click **SQL Server (MSSQLSERVER)** in the list of services and select **Properties** from the context menu.

   ![SQL Server Services is selected and highlighted in the tree view of the SQL Server Configuration Manager. In the Services pane, SQL Server (MSSQLSERVER) is selected and highlighted. Properties is highlighted in the context menu.](media/1.128.png "SQL Server Configuration Manager")

3. In the SQL Server (MSSQLSERVER) Properties dialog, select **This account** under Log on as, and enter the following:

   - **Account name**: `DemoUser`
   - **Password**: `Password.1234567890`

   ![In the SQL Server (MSSQLSERVER) Properties dialog, This account is selected under Log on as, and the sqlmiuser account name and password are entered.](media/1.129.png "SQL Server (MSSQLSERVER) Properties")

4. Select **OK**.

5. Select **Yes** in the Confirm Account Change dialog.

   ![The Yes button is highlighted in the Confirm Account Change dialog.](media/1.130.png "Confirm Account Change")

6. Observe that the **Log On As** value for the SQL Server (MSSQLSERVER) service changed to `.\demouser`.

   ![In the list of SQL Server Services, the SQL Server (MSSQLSERVER) service is highlighted.](media/1.131.png "SQL Server Services")

7. Close the SQL Server Configuration Manager.

### Task 3: Create a backup of the WideWorldImporters database

To perform online data migrations, DMS looks for database and transaction log backups in the shared SMB backup folder on the source database server. In this task, you create a backup of the `WideWorldImporters` database using SSMS and write it to the ```\\SQL2008-SUFFIX\dms-backups``` SMB network share you made in a previous task. The backup file needs to include a checksum, so you add that during the backup steps.

>**Note**: If you already connected with SSMS through legacysql2008 VM skip the steps and continue from step 3.

1. On the LEGACYSQL2008 VM, open **Microsoft SQL Server Management Studio 17** by entering "sql server" into the search bar in the Windows Start menu.

   ![SQL Server is entered into the Windows Start menu search box, and Microsoft SQL Server Management Studio 17 is highlighted in the search results.](media/1.132.png "Windows start menu search")

2. In the SSMS **Connect to Server** dialog, enter **legacysql2008** into the Server name box, ensure **Windows Authentication** is selected, and then select **Connect**.
   
    ![SQL Server is entered into the Windows Start menu search box, and Microsoft SQL Server Management Studio 17 is highlighted in the search results.](media/1.133.png "Windows start menu search")
   

3. Once connected, expand **Databases** under **LEGACYSQL2008** in the Object Explorer, and then right-click the **WideWorldImporters** database. In the context menu, select **Tasks** and then **Back Up**.

   ![SQL Server is entered into the Windows Start menu search box, and Microsoft SQL Server Management Studio 17 is highlighted in the search results.](media/1.134.png "Windows start menu search")

4. In the Back Up Database dialog, you should see `C:\WideWorldImporters.bak` listed in the Destinations box. This device is no longer needed, so select it and then select **Remove**.

   ![In the General tab of the Back Up Database dialog, C:\WideWorldImporters.bak is selected, and the Remove button is highlighted under destinations.](media/1.135.png)

5. Next, select **Add** to add the SMB network share as a backup destination.

   ![In the General tab of the Back Up Database dialog, the Add button is highlighted under destinations.](media/1.136.png "Back Up Database")

6. In the Select Backup Destination dialog, select the Browse (`...`) button.

   ![The Browse button is highlighted in the Select Backup Destination dialog.](media/1.137.png "Select Backup Destination")

7. In the Location Database Files dialog, select the `C:\dms-backups` folder, enter `WideWorldImporters.bak` into the File name field, and then select **OK**.

   ![In the Select the file pane, the C:\dms-backups folder is selected and highlighted, and WideWorldImporters.bak is entered into the File name field.](media/1.138.png "Location Database Files")

8. Select **OK** to close the Select Backup Destination dialog.

   ![The OK button is highlighted on the Select Backup Destination dialog and C:\dms-backups\WideWorldImporters.bak is entered in the File name textbox.](media/1.139.png "Backup Destination")

9. In the Back Up Database dialog, select **Media Options** in the Select a page pane, and then set the following:

   - Select **Back up to the existing media set** and then select **Overwrite all existing backup sets**.
   - Under Reliability, check the box for **Perform checksum before writing to media**. A checksum is required by DMS when using the backup to restore the database to SQL MI.

   ![In the Back Up Database dialog, the Media Options page is selected, and Overwrite all existing backup sets and Perform checksum before writing to media are selected and highlighted.](media/1.140.png "Back Up Database")

10. Select **OK** to perform the backup.

11. You will receive a message when the backup is complete. Select **OK**.

    ![Screenshot of the dialog confirming the database backup was completed successfully.](media/1.141.png "Backup complete")

### Task 4: Retrieve SQL MI and SQL Server 2008 VM connection information

In this task, you use the Azure Cloud shell to retrieve the information necessary to connect to your legacysql2008 VM from DMS.

1. In the Azure portal `https://portal.azure.com`, select the Azure Cloud Shell icon from the top menu.

   ![The Azure Cloud Shell icon is highlighted in the Azure portal's top menu.](media/1.142.png "Azure Cloud Shell")

2. In the Cloud Shell window that opens at the bottom of your browser window, select **PowerShell**.

   ![In the Welcome to Azure Cloud Shell window, PowerShell is highlighted.](media/1.143.png "Azure Cloud Shell")


5. At the prompt, retrieve the private IP address of the LEGACYSQL2008 VM. This IP address will be used to connect to the database on that server. Enter the following PowerShell command, **replacing `<your-resource-group-name>`** in the resource group name variable with the name of your resource group: Azure-Discover-RG-<inject key="DeploymentID" enableCopy="false" /> and vm name with: LEGACYSQL2008. 


      ```powershell
      $resourceGroup = "<your-resource-group-name>"
      az vm list-ip-addresses -g $resourceGroup -n VMNAME --output table
      ```

   > **Note**
   > Copy the powershell command in a notepad file and make the required changes and paste it in the cloud shell pane for convenience.
   
   > If you have multiple Azure subscriptions, and the account you are using for this hands-on lab is not your default account, you may need to run `az account list --output table` at the Azure Cloud Shell prompt to output a list of your subscriptions, then copy the Subscription Id of the account you are using for this lab and then run `az account set --subscription <your-subscription-id>` to set the appropriate account for the Azure CLI commands.

6. Within the output, locate and copy the value of the `ipAddress` property below the `PrivateIPAddresses` field. Paste the value into a text editor, such as Notepad.exe, for later reference.

    ![In the Azure Cloud Shell dialog, a message is displayed that requesting a Cloud Shell succeeded, and the PS Azure prompt is displayed.](media/1.146.png "Azure Cloud Shell")

7. Leave the Azure Cloud Shell open for the next task.

### Task 5: Create and run an online data migration project

In this task, you create a new online data migration project in DMS for the `WideWorldImporters` database.

1. In the Azure portal `https://portal.azure.com`, navigate to the Azure Database Migration Service by selecting **Resource groups** from the left-hand navigation menu, selecting the **Azure-Discover-RG-<inject key="DeploymentID" enableCopy="false" />**  resource group, and then selecting the **wwi-dms** Azure Database Migration Service in the list of resources.

   ![The wwi-dms Azure Database Migration Service is highlighted in the list of resources in the hands-on-lab resource group.](media/1.147.png "Resources")

2. On the Azure Database Migration Service blade, select **+New Migration Project**.

   ![On the Azure Database Migration Service blade, +New Migration Project is highlighted in the toolbar.](media/1.148.png "Azure Database Migration Service New Project")

3. On the New migration project blade, enter the following:

   - **Project name**: Enter `OnPremToSqlMi`**(1)**
   - **Source server type**: Select **SQL Server**.
   - **Target server type**: Select **Azure SQL Database Managed Instance (2)**.
   - **Choose type of activity**: Select **Online data migration (3)**.

      ![The New migration project blade is displayed, with the values specified above entered into the appropriate fields.](media/1.149.png "New migration project")

4. Select **Create and run activity (4)**.

5. On the Migration Wizard **Select source** tab, enter the following:

   - **Source SQL Server instance name**: Enter the IP address of your LEGACYSQL2008 VM that you copied into a text editor in the previous task. For example, `10.0.236.0`.
   - **Authentication type**: Select SQL Authentication.
   - **Username**: Enter `DemoUser`
   - **Password**: Enter `Password.1234567890`
   - **Connection properties**: Check both Encrypt connection and Trust server certificate.

   ![The Migration Wizard Select source tab is displayed, with the values specified above entered into the appropriate fields.](media/1.150.png "Migration Wizard Select source")

6. Select **Next : Select target**.

7. On the Migration Wizard **Select target** tab, enter the following:

   - **Application ID**: <inject key="Application/Client ID" />
   - **Key**:  <inject key="Application Secret Key" />
   - **Skip the Application ID Contributor level access check on the subscription**: Leave this unchecked.
   - **Subscription**: Select the subscription you are using for this hand-on lab.
   - **Target Azure SQL Managed Instance**: Select the sqlmi--cus instance.
   - **SQL Username**: Enter `contosoadmin`
   - **Password**: Enter `IAE5fAijit0w^rDM`

   ![The Migration Wizard Select source tab is displayed, with the values specified above entered into the appropriate fields.](media/1.151.png "Migration Wizard Select source")
   
8. Select **Next : Select databases**.

9. On the Migration Wizard **Select databases** tab, select `WideWorldImporters`.

   ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.152.png "Migration Wizard Select databases")

10. Select **Next : Configure migration settings**.

11. On the Migration Wizard **Configure migration settings** tab, enter the following configuration:

    - **Network share location**: Populate this field with the path to the SMB network share you created previously by entering ```\\private ip adress\dms-backups```.
    - **Windows User Azure Database Migration Service impersonates to upload files to Azure Storage**: Enter ```LEGACYSQL2008\demouser```.
    - **Password**: Enter `Password.1234567890`
    - **Subscription containing storage account**: Select the subscription you are using for this hands-on lab.
    - **Storage account**: Select the **sqlmistore** storage account.

      ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.153.png "Migration Wizard Select databases")
 
    - Click on **Advance Settings**. 
    - **WideWorldImporters**: Enter **WideWorldImporters-DID** 

 
         ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.154.png "Migration Wizard Select databases")

12. Select **Next : Summary**.

13. On the Migration Wizard **Summary** tab, enter `WwiMigration` as the **Activity name**.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.155.png "Migration Wizard Select databases")
    
14. Select **Start migration**.

15. Monitor the migration on the status screen that appears. You can select the refresh icon in the toolbar to retrieve the latest status. Continue selecting **Refresh** every 5-10 seconds until you see the status change to **Log shipping in progress**. When that status appears, move on to the next task.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.156.png "Migration Wizard Select databases")

### Task 6: Perform migration cutover

Since you performed an "online data migration," the migration wizard continuously monitors the SMB network share for newly added log backup files. Online migrations enable any updates on the source database to be captured until you initiate the cut over to the SQL MI database. In this task, you add a record to one of the database tables, backup the logs, and complete the migration of the `WideWorldImporters` database by cutting over to the SQL MI database.

1. In the Azure portal's migration status window and select **WideWorldImporters** under database name to view further details about the database migration.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.157.png "Migration Wizard Select databases")


2. On the WideWorldImporters screen, note the status of **Restored** for the `WideWorldImporters.bak` file.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.158.png "Migration Wizard Select databases")


3. To demonstrate log shipping and how transactions made on the source database during the migration process are added to the target SQL MI database, you will add a record to one of the database tables.

4. Return to SSMS on your LEGACYSQL2008 VM and select **New Query** from the toolbar.

   ![The New Query button is highlighted in the SSMS toolbar.](media/1.159.png "SSMS Toolbar")

5. Paste the following SQL script, which inserts a record into the `Game` table, into the new query window:

   ```sql
   USE WideWorldImporters;
   GO

   INSERT [dbo].[Game] (Title, Description, Rating, IsOnlineMultiplayer)
   VALUES ('Space Adventure', 'Explore the universe with our newest online multiplayer gaming experience. Build custom rocket ships and take off for the stars in an infinite open-world adventure.', 'T', 1)
   ```

6. Execute the query by selecting **Execute** in the SSMS toolbar.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.160.png "SSMS Toolbar")

7. After adding the new record to the `Games` table, back up the transaction logs. DMS detects any new backups and ships them to the migration service. Select **New Query** again in the toolbar, and paste the following script into the new query window:

   ```sql
   USE master;
   GO

   BACKUP LOG WideWorldImporters
   TO DISK = 'c:\dms-backups\WideWorldImportersLog.trn'
   WITH CHECKSUM
   GO
   ```

8. Execute the query by selecting **Execute** in the SSMS toolbar.

9. Return to the migration status page in the Azure portal. On the WideWorldImporters screen, select **Refresh**, and you should see the **WideWorldImportersLog.trn** file appear with a status of **Queued**.

   ![On the WideWorldImporters blade, the Refresh button is highlighted. A status of Uploaded is highlighted next to the WideWorldImportersLog.trn file in the list of active backup files.](media/1.161.png "Migration wizard")

   > **Note**: If you don't see it the transaction logs entry, continue selecting refresh every 10-15 seconds until it appears.

10. Continue selecting **Refresh**, and you should see the **WideWorldImportersLog.trn** status change to **Uploaded**.

11. After the transaction logs are uploaded, they are restored to the database. Once again, continue selecting **Refresh** every 10-15 seconds until you see the status change to **Restored**, which can take a minute or two.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.162.png "Migration Wizard Select databases")


12. After verifying the transaction log status of **Restored**, select **Start Cutover**.

    ![The Start Cutover button is displayed.](media/1.163.png "DMS Migration Wizard")

13. On the Complete cutover dialog, verify pending log backups is `0`, check **Confirm**, and then select **Apply**.

    ![In the Complete cutover dialog, 0 is highlighted next to Pending log backups, and the Confirm checkbox is checked.](media/1.164.png "Migration Wizard")

14. A progress bar below the Apply button in the Complete cutover dialog provides updates on the cutover status. When the migration finishes, the status changes to **Completed**.

    ![A status of Completed is displayed in the Complete cutover dialog.](media/1.165.png "Migration Wizard")

    > **Note**
    >
    > If the progress bar has not moved after a few minutes, you can proceed to the next step and monitor the cutover progress on the WwiMigration blade by selecting refresh.

15. To return to the WwiMigration blade, close the Complete cutover dialog by selecting the "X" in the upper right corner of the dialog, and do the same thing for the WideWorldImporters blade. Select **Refresh**, and you should see a status of **Completed** from the WideWorldImporters database.

    ![The Migration Wizard Select databases tab is displayed, with the WideWorldImporters database selected.](media/1.166.png "Migration Wizard Select databases")

16. You have successfully migrated the `WideWorldImporters` database to Azure SQL Managed Instance.

### Task 7: Verify database and transaction log migration

In this task, you connect to the SQL MI database using SSMS and quickly verify the migration.

>**Note**: If you already connected with SSMS through SQL MI skip the steps and continue from step 9.

1. First, use the Azure Cloud Shell to retrieve the fully qualified domain name of your SQL MI database. In the Azure portal `https://portal.azure.com`, select the Azure Cloud Shell icon from the top menu.

   ![The Azure Cloud Shell icon is highlighted in the Azure portal's top menu.](media/1.62.png "Azure Cloud Shell")

1. In the Cloud Shell window that opens at the bottom of your browser window, select **PowerShell**.

   ![In the Welcome to Azure Cloud Shell window, PowerShell is highlighted.](media/1.63.png "Azure Cloud Shell")

1. After a moment, a message is displayed that you have successfully requested a Cloud Shell, and be presented with a PS Azure prompt.

   ![In the Azure Cloud Shell dialog, a message is displayed that requesting a Cloud Shell succeeded, and the PS Azure prompt is displayed.](media/1.64.png "Azure Cloud Shell")

1. At the prompt, retrieve information about SQL MI in the SQLMI-Shared-RG resource group by entering the following PowerShell command.

   ```powershell
   $resourceGroup = "SQLMI-Shared-RG"
   az sql mi list --resource-group $resourceGroup
   ```

   > **Note**
   >
   > If you have multiple Azure subscriptions, and the account you are using for this hands-on lab is not your default account, you may need to run `az account list --output table` at the Azure Cloud Shell prompt to output a list of your subscriptions. Copy the Subscription Id of the account you are using for this lab and then run `az account set --subscription <your-subscription-id>` to set the appropriate account for the Azure CLI commands.

1. Within the above command's output, locate and copy the value of the `fullyQualifiedDomainName` property. Paste the value into a text editor, such as Notepad.exe, for reference below.

   ![The output from the az sql mi list command is displayed in the Cloud Shell, and the fullyQualifiedDomainName property and value are highlighted.](media/1.65.png "Azure Cloud Shell")

1. Return to SSMS on your **legacysql2008** VM, and then select **Connect** and **Database Engine** from the Object Explorer menu.

   ![In the SSMS Object Explorer, Connect is highlighted in the menu, and Database Engine is highlighted in the Connect context menu.](media/1.76.png "SSMS Connect")

7. In the Connect to Server dialog, enter the following:

   - **Server name**: Enter the fully qualified domain name of your SQL managed instance, which you copied from the Azure Cloud Shell in the previous steps.
   - **Authentication**: Select **SQL Server Authentication**.
   - **Login**: Enter `contosoadmin`
   -  **Password**: Enter `IAE5fAijit0w^rDM`
   - Check the **Remember password** box.

   ![The Migration Wizard Select source tab is displayed, with the values specified above entered into the appropriate fields.](media/1.167.png "Migration Wizard Select source")

8. Select **Connect**. 

9.  Expand Databases in the SQL MI connection and select the WideWorldImporters<inject key="DeploymentID" enableCopy="false" /> database.

      ![The Migration Wizard Select source tab is displayed, with the values specified above entered into the appropriate fields.](media/1.168.png "Migration Wizard Select source")

10. With the **<inject key="Database Name" enableCopy="false"/>** database selected, select **New Query** on the SSMS toolbar to open a new query window.

11. In the new query window, enter the following SQL script:

      >**Note:** Make sure to replace the SUFFIX value with <inject key="Suffix" />

      ```sql
      USE WideWorldImportersSUFFIX;
      GO
      SELECT * FROM Game
      ```  

12. Select **Execute** on the SSMS toolbar to run the query. Observe the records contained within the `Game` table, including the new `Space Adventure` game you added after initiating the migration process.

    ![In the new query window, the query above has been entered, and in the results pane, the new Space Adventure game is highlighted.](media/1.169.png "SSMS Query")

13. You are done using the **legacysql2008** VM. Close any open windows and log off the VM. The JumpBox VM is used for the remaining tasks of this hands-on lab.

### Task 8: Deploy the web app to Azure

In this task, you will use JumpBox VM and then, using Visual Studio on the JumpBox, deploy the `WideWorldImporters` web application into the App Service in Azure.

1. You have already logged-in to JumpBox VM, use this VM to continue with the lab. 

1. In the File Explorer dialog, navigate to the `C:\hands-on-lab` folder and then drill down to `Migrating-SQL-databases-to-Azure-master\Hands-on lab\lab-files`. In the `lab-files` folder, double-click `WideWorldImporters.sln` to open the solution in Visual Studio.

   ![The folder at the path specified above is displayed, and WideWorldImporters.sln is highlighted.](media/1.34.png "Windows Explorer")

1. If prompted about how you want to open the file, select **Visual Studio 2022**, and then select **OK**.

    ![In the Visual Studio version selector, Visual Studio 2019 is selected and highlighted.](media/1.35.png "Visual Studio")

1. Select **Sign in** and enter the following Azure account credentials when prompted:
   * Email/Username: <inject key="AzureAdUserEmail"></inject>
   * Password: <inject key="AzureAdUserPassword"></inject>

    ![On the Visual Studio welcome screen, the Sign in button is highlighted.](media/1.66.png "Visual Studio")
    
1. Once you Signed in, Click on **Start Visual Studio**.

     ![A Visual Studio security warning is displayed, and the Ask me for every project in this solution checkbox is unchecked and highlighted.](media/1.68.png "Visual Studio")

1. At the security warning prompt, uncheck **Ask me for every project in this solution**, and then select **OK**.

    ![A Visual Studio security warning is displayed, and the Ask me for every project in this solution checkbox is unchecked and highlighted.](media/1.37.png "Visual Studio")

1. Once logged into Visual Studio, right-click the `WideWorldImporters.Web` project in the Solution Explorer, and then select **Publish**.

    ![In the Solution Explorer, the context menu for the WideWorldImporters.Web project is displayed, and Publish is highlighted.](media/1.38.png "Visual Studio")

1. On the **Publish** dialog, select **Azure** in the Target box, and select **Next**.

    ![In the Publish dialog, Azure is selected and highlighted in the Target box. The Next button is highlighted.](media/1.39.png "Publish API App to Azure")

1. Next, in the **Specific target** box, select **Azure App Service (Windows)**.

    ![In the Publish dialog, Azure App Service (Windows) is selected and highlighted in the Specific Target box. The Next button is highlighted.](media/1.171.png "Publish API App to Azure")

1. Finally, in the **App Service** box, select your subscription, expand the **Azure-Discover-RG-<inject key="Suffix" enableCopy="false"/>** resource group, and select the **wwi-web-<inject key="Suffix" enableCopy="false"/>** Web App, Click on **Finish**.

    ![In the Publish dialog, The wwi-web-UNIQUEID Web App is selected and highlighted under the hands-on-lab- resource group.](media/1.170.png "Publish API App to Azure")
    
1. You will see that Publish profile creation progress, click on **Close**.

   ![In the Publish dialog, The wwi-web-UNIQUEID Web App is selected and highlighted under the hands-on-lab- resource group.](media/1.172.png "Publish API App to Azure")

1. Back on the Visual Studio Publish page for the `WideWorldImporters.Web` project, select **Publish** to start the process of publishing your Web API to your Azure API App.

    ![The Publish button is highlighted on the Publish page in Visual Studio.](media/1.42.png "Publish")

1. When the publish completes, you will see a message on the Visual Studio Output page that the publish succeeded.

    ![The Publish Succeeded message is displayed in the Visual Studio Output pane.](media/1.43.png "Visual Studio")

2. If you select the link of the published web app from the Visual Studio output window, an error page is returned because the database connection strings have not been updated to point to the SQL MI database. You address this in the next task.

    ![An error screen is displayed because the database connection string has not been updated to point to SQL MI in the web app's configuration.](media/1.44.png "Web App error")

### Task 9: Update App Service configuration

1. In the Azure portal `https://portal.azure.com`, select **Resource groups** from the Azure services list.

   ![Resource groups is highlighted in the Azure services list.](media/1.1.png "Azure services")

1. Select the <inject key="Resource Group Name" enableCopy="false"/> resource group from the list.

   ![Resource groups is selected in the Azure navigation pane, and the "hands-on-lab-< resource group is highlighted.](./media/1.2.png "Resource groups list")

1. In the list of resources for your resource group, select the **Azure-Discover-RG-<inject key="DeploymentID" enableCopy="false" />** resource group and then select the **wwi-web-<inject key="Suffix" enableCopy="false"/>** App Service from the list of resources.

   ![The wwi-web-UNIQUEID App Service is highlighted in the list of resource group resources.](media/1.45.png "Resource group")

1. On the App Service blade, select **Configuration** under Settings on the left-hand side.

   ![The Configuration item is selected under Settings.](media/1.46.png "Configuration")

1. On the Configuration blade, locate the **Connection strings** section and then select the Pencil (Edit) icon to the right of the `WwiContext` connection string.

   ![In the Connection string section, the pencil icon is highlighted to the right of the WwiContext connection string.](media/1.47.png "Connection Strings")

1. The value of the connection string should look like this:

    ``
   Server=tcp:your-sqlmi-host-fqdn-value,1433;Database=WideWorldImportersSuffix;User ID=sqlmiuser;Password=Password.1234567890;Trusted_Connection=False;Encrypt=True;TrustServerCertificate=True;
   ``

1. In the Add/Edit connection string dialog, replace `your-sqlmi-host-fqdn-value` with the fully qualified domain name for your SQL MI that you copied to a text editor earlier from the Azure Cloud Shell and replace suffix with value: <inject key="suffix" /> and also change the UserID with `sqlmiuser` and Password with `Password.1234567890`.

   ![The your-sqlmi-host-fqdn-value string is highlighted in the connection string.](https://raw.githubusercontent.com/CloudLabs-MCW/MCW-Migrating-SQL-databases-to-Azure/fix/Hands-on%20lab/media/images/9.png "Edit Connection String")

1. The updated value should look similar to the following screenshot.

   ![The updated connection string is displayed, with the fully qualified domain name of SQL MI highlighted within the string.](media/1.49.png "Connection string value")
   
   ![The updated connection string is displayed, with the fully qualified domain name of SQL MI highlighted within the string.](media/1.173.png "Connection string value")

1. Select **OK**.

1. Repeat steps 3 - 7, this time for the `WwiReadOnlyContext` connection string.

1. Select **Save** at the top of the Configuration blade.

    ![The save button on the Configuration blade is highlighted.](media/1.50.png "Save")

1. When prompted that changes to application settings and connection strings will restart your application, select **Continue**.

    ![The prompt warning that the application will be restarted is displayed, and the Continue button is highlighted.](media/1.51.png "Restart prompt")

1. Select **Overview** to the left of the Configuration blade to return to the overview blade of your App Service.

    ![Overview is highlighted on the left-hand menu for App Service](media/1.52.png "Overview menu item")

1. At this point, selecting the **URL** for the App Service on the Overview blade still results in an error being returned. The error occurs because SQL Managed Instance has a private IP address in its VNet. To connect an application, you need to configure access to the VNet where Managed Instance is deployed, which you handle in the next exercise.

    ![An error screen is displayed because the application cannot connect to SQL MI within its private virtual network.](media/1.53.png "Web App error")

### Task 10: Configure VNet integration with App Services

In this task, you add the networking configuration to your App Service to enable communication with resources in the VNet.

1. In the Azure portal `https://portal.azure.com`, select **Resource groups** from the left-hand menu, select the **Azure-Discover-RG-<inject key="DeploymentID" enableCopy="false" />** resource group and then select the **wwi-web-UNIQUEID** App Service from the list of resources.

   ![The wwi-web-UNIQUEID App Service is highlighted in the list of resource group resources.](media/1.45.png "Resource group")

2. On the App Service blade, select **Networking** from the left-hand menu.

   ![On the App Service blade, Networking is selected in the left-hand menu, and Click here to configure is highlighted under VNet Integration.](media/1.54.png "App Service")

3. On the **Networking** page, click on the **VNet integration** within **Outbound Traffic**.

   ![Add VNet is highlighted on the VNet Configuration blade.](media/1.55.png "App Service")

3. Now select **Click here to configure** under **VNet Integration** and then click on **Add VNet** on the VNet Configuration blade.

   ![Add VNet is highlighted on the VNet Configuration blade.](media/1.56.png "App Service")

4. On the Network Feature Status dialog, enter the following and click **OK**.

   - **Virtual Network**: Select the vnet-sqlmi--cus.
   - **Subnet**: Select the existing subnet. and select any subnet from the drop down menu. 

      ![image](media/1.57.png "App Service")

      > **Note**: If you see **Failed to add delegation to existing subnet** please select any other subnet.

  		> **Note**: If you are not able to select any existing subnet, then follow the below steps.
   - Select the create new subnet option and enter name as Webappsubnet<inject key="Suffix" />. Select the Virtual Network address block i.e, 10.0.0.0/16 from the drop down list. In the subnet address block enter new address block 10.0.xx.0/23 for the subnet, make sure it is not overlapping other subnet's address.
 	 	> **Note**: If the address space is overlapping with other subnets, change the virtual network address block by selecting a different virtual network address block i.e, 10.1.0.0/16 or 10.2.0.0/16 from the drop-down. In the subnet address block, enter 10.1.xx.0/23 or 10.2.xx.0/23 according to the virtual network address block you have selected and make sure it is not overlapping the other subnet's address.

   	   ![The values specified above are entered into the Network Feature Status dialog.](media/1.58.png "App Service")

5. Within a few minutes, the VNet is added, and your App Service is restarted to apply the changes. Select Refresh to confirm whether the Vnet is connected or not.

   ![The details of the VNet Configuration are displayed. The Certificate Status, Certificates in sync, is highlighted.](media/1.59.png "App Service")

   > **Note**
   >
   > If you receive a message adding the Virtual Network to Web App failed, select **Disconnect** on the VNet Configuration blade, and repeat steps 3 - 5 above.

### Task 11: Open the web application

In this task, you verify your web application now loads, and you can see the home page of the web app.

1. Select **Overview** in the left-hand menu of your App Service and select the **URL** of your App service to launch the website. This link opens the URL in a browser window.

   ![The App service URL is highlighted.](media/1.60.png "App service URL")

2. Verify that the website and data are loaded correctly. The page should look similar to the following:

   ![Screenshot of the WideWorldImporters Operations Web App.](media/1.61.png "WideWorldImporters Web")

   > **Note**
   >
   > It can often take several minutes for the network configuration to be reflected in the web app. If you get an error screen, try selecting Refresh a few times in the browser window. If that does not work, try selecting **Restart** on the Azure Web App's toolbar.

3. Congratulations, you successfully connected your application to the new SQL MI database.

