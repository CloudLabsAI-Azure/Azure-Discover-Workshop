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
