## Exercise 3: Check and update team VMs

### Task 1: Check databases 

1. Navigate to the [Azure portal](https://portal.azure.com) and select **Resource groups** from the Azure services list.

   ![Resource groups is highlighted in the Azure services list.](media/1.1.png "Azure services")

1. Select the resource group from the list.

   ![Resource groups is selected in the Azure navigation pane, and the "hands-on-lab resource group is highlighted.](./media/1.2.png "Resource groups list")

1. In the list of resources for your resource group, select the **legacysql2008** VM.

   ![The SqlServer2008 VM is highlighted in the list of resources.](media/1.3.png "Resource list")

1. On the VM blade in the Azure portal, select **Overview** from the left-hand menu, and then select **Connect** and **RDP** on the top menu, as you've done previously.

   ![The SqlServer2008 VM blade is displayed, with the Connect button highlighted in the top menu.](./media/1.4.png "Connect to SqlServer2008 VM")

1. On the Connect with RDP blade, select **Download RDP File**, then open the downloaded RDP file.

1. Select **Connect** on the Remote Desktop Connection dialog.

   ![In the Remote Desktop Connection Dialog Box, the Connect button is highlighted.](./media/1.5.png "Remote Desktop Connection dialog")

1. Enter the following credentials when prompted, and then select **OK**:

   - **Username**: `DemoUser`
   - **Password**: `Password.1234567890`

   ![The credentials specified above are entered into the Enter your credentials dialog.](media/1.6.png "Enter your credentials")

1. Select **Yes** to connect if prompted that the remote computer's identity cannot be verified.

   ![In the Remote Desktop Connection dialog box, a warning states that the remote computer's identity cannot be verified and asks if you want to continue anyway. At the bottom, the Yes button is circled.](./media/1.7.png "Remote Desktop Connection dialog")
   
1. Once logged in, open **Microsoft SQL Server Management Studio 17** (SSMS) by entering "sql server" into the search bar in the Windows Start menu and selecting **Microsoft SQL Server Management Studio 17** from the search results.

   ![SQL Server is entered into the Windows Start menu search box, and Microsoft SQL Server Management Studio 17 is highlighted in the search results.](media/1.8.png "Windows start menu search")

1. In the SSMS **Connect to Server** dialog, enter LEGACYSQL2008 into the Server name box, ensure **Windows Authentication** is selected, and then select **Connect**.
  
    ![The SQL Server Connect to Search dialog is displayed, with SQL2008-entered into the Server name and Windows Authentication selected.](media/1.9.png "Connect to Server")
    
1. Right click on the SQL sever and then click on **New Query**.

    ![The SQL Server Connect to Search dialog is displayed, with SQL2008-entered into the Server name and Windows Authentication selected.](media/1.31.png "Connect to Server")

1. Next, copy and paste the SQL script below into the new query window and run this TSQL to check tables exists that they have data and click on **Execute**.

    ```sql
   DECLARE @cmd varchar(500) 
   SET @cmd='
	 IF "?" LIKE "%TenantDataDb"
	 BEGIN
	 USE ?
	 select DB_Name(), ''SalesLT.Customer'', count(*) from SalesLT.Customer;
	 select DB_Name(), ''SalesLT.Product'', count(*) from SalesLT.Product;
	 END' 
   EXEC sp_MSforeachdb @cmd;
    ```
   ![The SQL Server Connect to Search dialog is displayed, with SQL2008-entered into the Server name and Windows Authentication selected.](media/1.33.png "Connect to Server")
   
   
### Task 2: Deploy the web app to Azure

In this task, you will use JumpBox VM and then, using Visual Studio on the JumpBox, deploy the `WideWorldImporters` web application into the App Service in Azure.

1. You have already logged-in to JumpBox VM, use this VM to continue with the lab. 

1. In the File Explorer dialog, navigate to the `C:\hands-on-lab` folder and then drill down to `Migrating-SQL-databases-to-Azure-master\Hands-on lab\lab-files`. In the `lab-files` folder, double-click `WideWorldImporters.sln` to open the solution in Visual Studio.

   ![The folder at the path specified above is displayed, and WideWorldImporters.sln is highlighted.](media/1.34.png "Windows Explorer")

1. If prompted about how you want to open the file, select **Visual Studio 2022**, and then select **OK**.

    ![In the Visual Studio version selector, Visual Studio 2019 is selected and highlighted.](media/1.35.png "Visual Studio")

1. Select **Sign in** and enter the following Azure account credentials when prompted:
   * Email/Username: <inject key="AzureAdUserEmail"></inject>
   * Password: <inject key="AzureAdUserPassword"></inject>

    ![On the Visual Studio welcome screen, the Sign in button is highlighted.](media/1.36.png "Visual Studio")

1. At the security warning prompt, uncheck **Ask me for every project in this solution**, and then select **OK**.

    ![A Visual Studio security warning is displayed, and the Ask me for every project in this solution checkbox is unchecked and highlighted.](media/1.37.png "Visual Studio")

1. Once logged into Visual Studio, right-click the `WideWorldImporters.Web` project in the Solution Explorer, and then select **Publish**.

    ![In the Solution Explorer, the context menu for the WideWorldImporters.Web project is displayed, and Publish is highlighted.](media/1.38.png "Visual Studio")

1. On the **Publish** dialog, select **Azure** in the Target box, and select **Next**.

    ![In the Publish dialog, Azure is selected and highlighted in the Target box. The Next button is highlighted.](media/1.39.png "Publish API App to Azure")

1. Next, in the **Specific target** box, select **Azure App Service (Windows)**.

    ![In the Publish dialog, Azure App Service (Windows) is selected and highlighted in the Specific Target box. The Next button is highlighted.](media/1.40.png "Publish API App to Azure")

1. Finally, in the **App Service** box, select your subscription, expand the **hands-on-lab-<inject key="Suffix" enableCopy="false"/>** resource group, and select the **wwi-web-<inject key="Suffix" enableCopy="false"/>** Web App, Click on **Finish**.

    ![In the Publish dialog, The wwi-web-UNIQUEID Web App is selected and highlighted under the hands-on-lab- resource group.](media/1.41.png "Publish API App to Azure")

1. Back on the Visual Studio Publish page for the `WideWorldImporters.Web` project, select **Publish** to start the process of publishing your Web API to your Azure API App.

    ![The Publish button is highlighted on the Publish page in Visual Studio.](media/1.42.png "Publish")

1. When the publish completes, you will see a message on the Visual Studio Output page that the publish succeeded.

    ![The Publish Succeeded message is displayed in the Visual Studio Output pane.](media/1.43.png "Visual Studio")

2. If you select the link of the published web app from the Visual Studio output window, an error page is returned because the database connection strings have not been updated to point to the SQL MI database. You address this in the next task.

    ![An error screen is displayed because the database connection string has not been updated to point to SQL MI in the web app's configuration.](media/1.44.png "Web App error")

### Task 3: Update App Service configuration

In this task, you update the WWI gamer info web application to connect to and utilize the SQL MI database.

1. In the Azure portal `https://portal.azure.com`, select **Resource groups** from the Azure services list.

   ![Resource groups is highlighted in the Azure services list.](media/1.1.png "Azure services")

2. Select the <inject key="Resource Group Name" enableCopy="false"/> resource group from the list.

   ![Resource groups is selected in the Azure navigation pane, and the "hands-on-lab-< resource group is highlighted.](./media/1.2.png "Resource groups list")

3. In the list of resources for your resource group, select the **<inject key="Resource Group Name" enableCopy="false"/>** resource group and then select the **wwi-web-<inject key="Suffix" enableCopy="false"/>** App Service from the list of resources.

   ![The wwi-web-UNIQUEID App Service is highlighted in the list of resource group resources.](media/1.45.png "Resource group")

4. On the App Service blade, select **Configuration** under Settings on the left-hand side.

   ![The Configuration item is selected under Settings.](media/1.46.png "Configuration")

5. On the Configuration blade, locate the **Connection strings** section and then select the Pencil (Edit) icon to the right of the `WwiContext` connection string.

   ![In the Connection string section, the pencil icon is highlighted to the right of the WwiContext connection string.](media/1.47.png "Connection Strings")

6. The value of the connection string should look like this:

    
  ``
  Server=tcp:your-sqlmi-host-fqdn-value,1433;Database=WideWorldImportersSuffix;User ID=contosoadmin;Password=IAE5fAijit0w^rDM;Trusted_Connection=False;Encrypt=True;TrustServerCertificate=True;
   ``
   

7. In the Add/Edit connection string dialog, replace `your-sqlmi-host-fqdn-value` with the fully qualified domain name for your SQL MI that you copied to a text editor earlier from the Azure Cloud Shell and replace suffix with value: <inject key="suffix" /> .

   ![The your-sqlmi-host-fqdn-value string is highlighted in the connection string.](https://raw.githubusercontent.com/CloudLabs-MCW/MCW-Migrating-SQL-databases-to-Azure/fix/Hands-on%20lab/media/images/9.png "Edit Connection String")

8. The updated value should look similar to the following screenshot.

   ![The updated connection string is displayed, with the fully qualified domain name of SQL MI highlighted within the string.](media/1.49.png "Connection string value")

9. Select **OK**.

10. Repeat steps 3 - 7, this time for the `WwiReadOnlyContext` connection string.

11. Select **Save** at the top of the Configuration blade.

    ![The save button on the Configuration blade is highlighted.](media/1.50.png "Save")

12. When prompted that changes to application settings and connection strings will restart your application, select **Continue**.

    ![The prompt warning that the application will be restarted is displayed, and the Continue button is highlighted.](media/1.51.png "Restart prompt")

13. Select **Overview** to the left of the Configuration blade to return to the overview blade of your App Service.

    ![Overview is highlighted on the left-hand menu for App Service](media/1.52.png "Overview menu item")

14. At this point, selecting the **URL** for the App Service on the Overview blade still results in an error being returned. The error occurs because SQL Managed Instance has a private IP address in its VNet. To connect an application, you need to configure access to the VNet where Managed Instance is deployed, which you handle in the next exercise.

    ![An error screen is displayed because the application cannot connect to SQL MI within its private virtual network.](media/1.53.png "Web App error")


