## Exercise 3: Migrate your on-premises SSIS packages using Azure Data Factory
Duration: 90 minutes

Now that the databases for the Tailspin Application have been migrated, there is a set of additional SSIS packages on the LEGACYSQL2008 server that also require migration to the SQL Managed Instance for the central Data Warehouse. In this exercise you will migrating the SSIS packages to SQLMi using SSDT tools and Azure data factory SSIS integration runtime. 

### Task 1: Review the already enabled CLR on the SQL Managed Instance

1. On the legacysql2008 VM, Open Microsoft SQL Server Management Studio, click on **New Query** from the SSMS toolbar.

   ![The New Query button is highlighted in the SSMS toolbar.](media/1.78.png "SSMS Toolbar")

1. Next, copy and paste the SQL script below into the new query window. This script verifies that CLR is enabled for the managed instance.

    ```sql
    EXEC sp_configure 'clr enabled';
    GO 
    ```

1. To run the script, select **Execute** from the SSMS toolbar.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.79.png "SSMS Toolbar")

1. The output should display the CLR is enabled for the manged instance.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.13.png "SSMS Toolbar")
   

### Task 2: Prepare SSIS Demo

In this task, you will be running a powershell script that will restore a SSIS packages DB into the SQLMI and install the required SSIS tool for the package migration. 

1. Navigate back to JumpBox, type **PowerShell** in the search bar, right-click on **Windows PowerShell ISE** and click on **Run as administrator** in the context menu.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.80.png "SSMS Toolbar")

1. If prompted, click **Yes** to allow the app to make changes to your device.

1. Click on **File** menu and then click on **Open** to open a PowerShell script.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.82.png "SSMS Toolbar")

1. Navigate to the `C:\Labfiles` folder, click on **ssis.ps1** script and then click on **Open**.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.83.png "SSMS Toolbar")

1. Click on **Run script**.  
   
1. While the script is running, you will see a new SSIS packges install window, click on **Modify** button to configure the SSIS installation on the server.

   ![The Execute button is highlighted in the SSMS toolbar.](media/installssis.png "SSMS Toolbar")  
    
1. On the next window, select the checkbox on **SQL Server Integration Services** tool and click on **Modify**. This will install the SSIS tool on the server, once the installation is completed you can close the window.

   ![The Execute button is highlighted in the SSMS toolbar.](media/modifyssis.png "SSMS Toolbar")

 

### Task 3: Review the already created Azure-SSIS integration runtime.  

1. Navigate to the Azure portal, search and select **data factories** from the Azure search bar.

   ![Resource groups is highlighted in the Azure services list.](media/1.14.png "Azure services")

1. Select your **Data Factory** names as **Data-Factory-Shared**.

   ![Resource groups is highlighted in the Azure services list.](media/1.202.png "Azure services")

1. In the **Overview** section, Click on **Launch Studio**.

   ![Resource groups are highlighted in the Azure services list.](media/1.203.png "Azure services")

1. In the Azure Data Factory portal, switch to the **Monitor** tab, and then select the **Integration runtimes** tab to view existing integration runtimes in your data factory.

   ![Resource groups are highlighted in the Azure services list.](media/1.205.png "Azure services")

1. You will see that the **SSISIR** integration runtime is in running status.
 
   ![Resource groups is highlighted in the Azure services list.](media/1.25.png "Azure services")
  
1. If the SSISIR integration runtime is in stopped state, click on **ellipsis** button and then click on **Start**.

### Task 4: Upgrade the package using the Upgrade Wizard

In this section, we will be upgrading the Legacy SSIS package so that it can be migrated to Azure.

1. On the JumpBox VM, navigate to `C:\Labfiles\SSISDW` and open **SSISDW.sln** in VS 2017

   ![Resource groups is highlighted in the Azure services list.](media/sad11.jpg "Azure services")

   >**Note**: Incase if sign-in prompt appears, Select **Sign in** and enter the following Azure account credentials when prompted:

   * Email/Username: <inject key="AzureAdUserEmail"></inject>
   * Password: <inject key="AzureAdUserPassword"></inject>   

1. Once Visual Studio is open, you will see that the project is unsupported and visual studio will migrate the project automatically, click Ok to proceed.

   ![Resource groups is highlighted in the Azure services list.](media/1.177.png "Azure services")

1. Once the project is migrated, a new browser window will open and you should be able to see the migration report. You can review the report and close the tab.

   ![Resource groups is highlighted in the Azure services list.](media/1.178.png "Azure services")

1. Navigate back to Visual Studio and you should be able to see SSIS Package Upgrade Wizard.

   ![Resource groups is highlighted in the Azure services list.](media/1.179.png "Azure services")

1. Click on Next on the upgrade wizard, and on **Package management option** page select the below options and click on next.

   - Update connection strings to use new provider names.
   - Continue upgrade process when a package upgrade fails.
   - Ignore configurations.

   ![Resource groups is highlighted in the Azure services list.](media/1.180.png "Azure services")

1. Now review the information and click on the **Finish** button to complete the package upgrade wizard.

   ![Resource groups is highlighted in the Azure services list.](media/1.181.png "Azure services")

1. Once the upgrade is complete, you can click on the close button. You should be able to see the below output upon completion of the package upgrade process.

   ![Resource groups is highlighted in the Azure services list.](media/1.182.png "Azure services")

1. As soon as the solution is upgraded, you should be able to load the project without any issues.

   ![Resource groups is highlighted in the Azure services list.](media/1.183.png "Azure services")

### Task 5: Convert to Project Deployment mode and update the connection string

In this task, we will be converting the DTSX package into a Project Deployment model and correcting the DTSX package connection strings to use the new SQL Server Managed Instance using Visual Studio 2017.

1. Now click on the **PopulateDW.dtsx** and click OK on **Synchronise Connection Strings** to acknowledge the connection.

   ![Resource groups is highlighted in the Azure services list.](media/populate.png "Azure services")

   ![Resource groups is highlighted in the Azure services list.](media/syncon.png "Azure services")

1. Now right click on the solution and click on **Convert to project deployment model** to convert the project.

   ![Resource groups is highlighted in the Azure services list.](media/convert.png "Azure services")

1. Click on **next** button till you get on convert page and click on **convert** button to complete the project covert.

   ![Resource groups is highlighted in the Azure services list.](media/finishconvert.png "Azure services")

1. Review the summary of project covert and click on **close** to close the convert window.

   ![Resource groups is highlighted in the Azure services list.](media/sad12.jpg "Azure services")

1. Now double click on the **SQL Server** under connection manager windows.

   ![Resource groups is highlighted in the Azure services list.](media/cncnmngr.png "Azure services")

1. On the **Connection Manager** window, select **Native ODL DB/SQL Server Native Client 11.0**  from the drop-down.

   ![Resource groups is highlighted in the Azure services list.](media/providerssn.png "Azure services")

1. Now enter the below details for the target SQLMI as shown below:

   - Server Name: Enter the SQLMI FQDN noted from the previous task
   - Authentication: **SQL Server Authentication**
   - **User name**: **<inject key="SQL MI Username" />**
   - **Password**: **<inject key="SQL MI Password" />** 
   - Database Name: Select **2008DW** from the drop-down and click **OK**

   ![Resource groups is highlighted in the Azure services list.](media/2008dw.png "Azure services")

1. Now right click on the **SQL Server** connect and click on **Convert to Project Connection**

   ![Resource groups is highlighted in the Azure services list.](media/credconvert.png "Azure services")

1. Now you should be able to see a newly created connection under **connection manager** on solution explorer.

   ![Resource groups is highlighted in the Azure services list.](media/projctcncn.png "Azure services")

### Task 6: Deploy packages to the SSISDB on the Managed Instance

In this task, we will be deploying the fixed package onto the SSIS integration runtime and SSISDB held within the Managed Instance.

1. Right click on the solution and click on properties to change the target server type to 2017 as 2019 is not yet supported.

   ![Resource groups is highlighted in the Azure services list.](media/1.190.png "Azure services")

1. On the solution properties, select General under **Configuration Properties** and select **TargetServerVersion** as **SQL Server 2017** from drop-down menu and click on Apply and **OK**.

   ![Resource groups is highlighted in the Azure services list.](media/targetpackgeproject.png "Azure services")

1. If you do get the "Do you want to reload" message, click **No to All**.

   ![Resource groups is highlighted in the Azure services list.](media/notoall.png "Azure services")

1. Now right click on the solution and click on **Deploy**.

   ![Resource groups is highlighted in the Azure services list.](media/deployproj.png "Azure services")

1. Click on Next on the **Introduction** page on **Integration Services Deployment Wizard**

1. Click Next on the **Select source** page with default value.

   ![Resource groups is highlighted in the Azure services list.](media/selectsource.png "Azure services")

1. On the **Deployment Target** page select **SSIS in Azure Data Factory** and click on Next.

   ![Resource groups is highlighted in the Azure services list.](media/ssdf.png "Azure services")

1. Now, under **Destination** enter the below details.

   - Server Name: Enter the SQLMI FQDN noted from the previous task
   - Authentication: **SQL Server Authentication** 
   - **User name**: **<inject key="SQL MI Username" />**
   - **Password**: **<inject key="SQL MI Password" />**
   - Click on **Connect**.

      ![Resource groups is highlighted in the Azure services list.](media/destsqlmi.png "Azure services")
   
1. For Path, click on **Browse** and create a folder name as **ODLUSER<inject key="SUFFIX" enableCopy="false" />**, click on **OK**.

   ![Resource groups is highlighted in the Azure services list.](media/1.208.png "Azure services") 

1. Review the values and click on **Deploy** button to start the project deployment.

   ![Resource groups is highlighted in the Azure services list.](media/1.213.png "Azure services")
   
1. Once the Results is passed, click on **Close**.

   ![Resource groups is highlighted in the Azure services list.](media/1.184.png "Azure services")
   
1. On your **JumpBox** VM, Open **Microsoft SQL Server Management Studio 17** from the Start menu and enter the following information in the **Connect to Server** dialog

   - **Server name**: Enter the fully qualified domain name of your SQL managed instance, which you copied from the Azure Cloud Shell in a previous Exercise.
   - **Authentication**: Select **SQL Server Authentication**.
   - **Login**: **<inject key="SQL MI Username" />**
   - **Password**: **<inject key="SQL MI Password" />** 
   - Check the **Remember password** box.
   - Click on **Options**

   ![The SQL managed instance details specified above are entered into the Connect to Server dialog.](media/1.209.png "Connect to Server")
   
1. Under the Connection Properties, change the connect to database as **SSISDB** and click on **Connect**.
   
   ![The SQL managed instance details specified above are entered into the Connect to Server dialog.](media/1.214.png "Connect to Server")
   
1. Navigate to the Integration Services Catalogs, you will see that under projects SSISDW is listed here.

   ![Resource groups is highlighted in the Azure services list.](media/1.212.png "Azure services")

1. Congratulations, you successfully migrated your SSIS packages to the Azure SQLMI database, now click on the Next button present in the bottom-right corner of this lab guide.


## Summary

In this exercise, you have Migrated you SSIS packges to the Azure SQLMI using Azure data factory.

