## Exercise 2: Migrate your on-premise SSIS using Azure Data Factory

### Task 1: Review the already Enabled CLR on the SQL Managed Instance

1. First, use the Azure Cloud Shell to retrieve the fully qualified domain name of your SQL MI database. In the Azure portal `https://portal.azure.com`, select the Azure Cloud Shell icon from the top menu.

   ![The Azure Cloud Shell icon is highlighted in the Azure portal's top menu.](media/1.62.png "Azure Cloud Shell")

1. In the Cloud Shell window that opens at the bottom of your browser window, select **PowerShell**.

   ![In the Welcome to Azure Cloud Shell window, PowerShell is highlighted.](media/1.63.png "Azure Cloud Shell")

1. In the You have no storage mounted, Click on  **Show advanced settings**. 

   ![](media/sad2.jpg "Azure Cloud Shell")

1. Provide the following details and click on **Create storage (4)**.

   - Resource group: **Azure-Discover-RG-<inject key="DeploymentID" enableCopy="false" /> (1)**
   - Storage account: **cloudshell<inject key="DeploymentID" enableCopy="false" /> (2)**
   - File share: **blob (3)**

   ![](media/sad3.jpg "Azure Cloud Shell")

1. After a moment, a message is displayed that you have successfully requested a Cloud Shell, and be presented with a PS Azure prompt.

   ![In the Azure Cloud Shell dialog, a message is displayed that requesting a Cloud Shell succeeded, and the PS Azure prompt is displayed.](media/1.64.png "Azure Cloud Shell")

1. At the prompt, retrieve information about SQL MI in the SQLMI-Shared-RG resource group by entering the following PowerShell command.

   ```powershell
   $resourceGroup = "SQLMI-Shared-RG"
   az sql mi list --resource-group $resourceGroup
   ```

   > **Note**: If you have multiple Azure subscriptions, and the account you are using for this hands-on lab is not your default account, you may need to run `az account list --output table` at the Azure Cloud Shell prompt to output a list of your subscriptions. Copy the Subscription Id of the account you are using for this lab and then run `az account set --subscription <your-subscription-id>` to set the appropriate account for the Azure CLI commands.

1. Within the above command's output, locate and copy the value of the `fullyQualifiedDomainName` property. Paste the value into a text editor, such as Notepad.exe, for reference below.

   ![The output from the az sql mi list command is displayed in the Cloud Shell, and the fullyQualifiedDomainName property and value are highlighted.](media/1.65.png "Azure Cloud Shell")

1. Return to SSMS on your **legacysql2008** VM, and then select **Connect** and **Database Engine** from the Object Explorer menu.

   ![In the SSMS Object Explorer, Connect is highlighted in the menu, and Database Engine is highlighted in the Connect context menu.](media/1.76.png "SSMS Connect")

1. In the Connect to Server dialog, enter the following:

   - **Server name**: Enter the fully qualified domain name of your SQL managed instance, which you copied from the Azure Cloud Shell in the previous steps.
   - **Authentication**: Select **SQL Server Authentication**.
   - **Login**: Enter `contosoadmin`
   -  **Password**: Enter `IAE5fAijit0w^rDM`
   - Check the **Remember password** box.

   ![The Migration Wizard Select source tab is displayed, with the values specified above entered into the appropriate fields.](media/1.167.png "Migration Wizard Select source")

1. Select **Connect**. 

1. In Microsoft SQL Server Management Studio, select **New Query** from the SSMS toolbar.

    ![The New Query button is highlighted in the SSMS toolbar.](media/1.78.png "SSMS Toolbar")
    
1. Next, copy and paste the SQL script below into the new query window. This script verify that CLR is enabled for the manged instance.

    ```sql
    EXEC sp_configure 'clr enabled';
    GO
    ```
1. To run the script, select **Execute** from the SSMS toolbar.

    ![The Execute button is highlighted in the SSMS toolbar.](media/1.79.png "SSMS Toolbar")
    
1. The output should display the CLR is enabled for the manged instance.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.13.png "SSMS Toolbar")
    
### Task 2: Prepare SSIS Demo

1. Navigate back to Jumpbox, type **PowerShell** in the search bar, right-click on **Windows PowerShell ISE** and click on **Run as administrator** in the context menu.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.80.png "SSMS Toolbar")

1. If prompted, click **Yes** to allow the app to make changes to your device.

1. Click on **File** menu and then click on **Open** to open a powershell script.

   ![The Execute button is highlighted in the SSMS toolbar.](media/1.82.png "SSMS Toolbar")
   
1. Navigate to the `C:\Labfiles` folder, Click on **ssis.ps1** script and then click on **Open**. 
   
   ![The Execute button is highlighted in the SSMS toolbar.](media/1.83.png "SSMS Toolbar")
   
1. Click on **Run script**.

   ![The Execute button is highlighted in the SSMS toolbar.](media/sad4.jpg "SSMS Toolbar")
  
### Task 3: Create an Azure-SSIS integration runtime

1. Navigate to the [Azure portal](https://portal.azure.com), search and select **Data Factories** from the Azure search bar.

    ![Resource groups is highlighted in the Azure services list.](media/1.14.png "Azure services")

1. Select your **Data Factory**.

    ![Resource groups is highlighted in the Azure services list.](media/1.15.png "Azure services")
    
1. In the **Overview** section, Click on **Launch Studio**.

    ![Resource groups is highlighted in the Azure services list.](media/1.16.png "Azure services")

1. In the Azure Data Factory portal, switch to the **Manage** tab, and then switch to the **Integration runtimes** tab to view existing integration runtimes in your data factory.

    ![Resource groups is highlighted in the Azure services list.](media/1.84.png "Azure services")
    
    >**Note**: Select SSISIR and click Start. If it cannot be started, delete the SSISIR integration runtime and follow the below steps to create a new SSIS integration runtime.

1. Select **New** to create an Azure-SSIS IR and open the Integration runtime setup pane.

    ![Resource groups is highlighted in the Azure services list.](media/1.19.png "Azure services")

1. In the Integration runtime setup pane, select the **Lift-and-shift existing SSIS packages to execute in Azure tile**, and then select **Continue**.

    ![Resource groups is highlighted in the Azure services list.](media/1.20.png "Azure services")
    
1. On the **General settings** page of Integration runtime setup pane, complete the following steps.

    - Enter Name : **SSISIR**
    - Location: **Central US**
    - Node Size: **D2_v3 (2 Core(s), 8192 MB)**
    - Node Number: **1**
    - Click on **Continue**.

    ![Resource groups is highlighted in the Azure services list.](media/1.85.png "Azure services")
    
1. On the Deployment settings page of Integration runtime setup pane, you have the options to create **SSISDB**.

    - Enter Admin Username: `contosoadmin`
    - Enter Admin Password: `IAE5fAijit0w^rDM`
    - Click on **Continue**.
               
    ![Resource groups is highlighted in the Azure services list.](media/1.71.png "Azure services")
    
1. In the Advanced settings pane of the Integration runtime setup pane,

    - VNet Name: **vnet-sqlmi--cus**
    - Subnet name: **Management1**
    - Click on **VNet Validation**

    ![Resource groups is highlighted in the Azure services list.](media/1.72.png "Azure services")
    
1. Click on **Continue**.

1. Leave it as default, and Click on **Create**.

    ![Resource groups is highlighted in the Azure services list.](media/1.74.png "Azure services")

1. You will see that **SSISIR** integration runtime is in running status.

    ![Resource groups is highlighted in the Azure services list.](media/1.25.png "Azure services")
    

### Task 3: Upgrade Package using the Upgrade Wizard.

   In this section we will be upgrading the Legacy SSIS package so that it can be migrated to Azure.

1. On the JumpBox VM, Navigate to C:\labfiles and open SSISDW.sln in VS 2017

    ![Resource groups is highlighted in the Azure services list.](media/openproj.png "Azure services")

1. Once Visual studio is open, you will see that the project is unsupported an visual studio will migrate the project automatically, click ok to proceed.

    ![Resource groups is highlighted in the Azure services list.](media/projectupdate.png "Azure services")

1. Once the project is migrated, a new browser window will open and you should be able to see the migration report, you can review the report and close the tab.

    ![Resource groups is highlighted in the Azure services list.](media/projectmigration.png "Azure services")
    
1. Navigate back to Visual studio, and you should be able to see SSIS Package Upgrade Wizard.
    
    ![Resource groups is highlighted in the Azure services list.](media/wizard.png "Azure services")
    
1. Click on Next on the upgrade wizard, on **Package managment option** page select the below options and click on next.
   
      • Update connection strings to use new provider names.
      • Continue upgrade process when a package upgrade fails.
      • Ignore configurations.
    
    ![Resource groups is highlighted in the Azure services list.](media/packageoption.png "Azure services")
    
1. Now review the information and click on finish button to complete the package upgrade wizard.

     ![Resource groups is highlighted in the Azure services list.](media/finishpackage.png "Azure services")
    
1. Once the upgrade is completed you can click on close button, you should be able to see the below output upon completion of the package upgrade process.
    
    ![Resource groups is highlighted in the Azure services list.](media/completepackage.png "Azure services")
    
1. Now as the solution is upgraded you should be able to load the project without any issues.
    
    ![Resource groups is highlighted in the Azure services list.](media/ppopen.png "Azure services")
    
### Task 4: Convert to Project Deployment mode & update connection string
    In this task, we will be converting the DTSX package into a Project Deployment model and correcting the DTSX package connection strings to use the new SQL Server Managed Instance using Visual Studio 2017.
1. Now click on the **PopulateDW.dtsx** and click ok on **Synchronise Connection Strings** to acknowldge the connection.

    ![Resource groups is highlighted in the Azure services list.](media/populate.png "Azure services")
    
    ![Resource groups is highlighted in the Azure services list.](media/syncon.png "Azure services")
    
1. Now right click on the solution and click on **Convert to project deployment model** to convert the project.  
  
    ![Resource groups is highlighted in the Azure services list.](media/convert.png "Azure services")
    
1. Click on next untill the end of the convert page and click on **convert** button to complete the project convertion. 
    
     ![Resource groups is highlighted in the Azure services list.](media/finishconvert.png "Azure services")

1. Review the summary of project convertion and click on **close** to close the convert window.

    ![Resource groups is highlighted in the Azure services list.](media/closeconvert.png "Azure services")
    
1. Now double click on the **SQL Server** under connection manager windows.
     
     ![Resource groups is highlighted in the Azure services list.](media/cncnmngr.png "Azure services")
     
1. On the **Connection Manager** window, select **Native ODL DB/SQL Server Native Client 11.0** from the drop-down.

  ![Resource groups is highlighted in the Azure services list.](media/providerssn.png "Azure services")

1. Now enter the below details for the target SQLMI as below:   
    
    * Server Name: Enter the SQLMI FQDN noted from the previous task
    * Authentication: **SQL Server Authentication**
    * Username: **Contosoadmin**
    * Password: **IAE5fAijit0w^rDM**
    * Database Name: Select **2008DWSUFFIX** from the drop-down and click **ok**
    
    ![Resource groups is highlighted in the Azure services list.](media/2008dw.png "Azure services")
    
1. Now right click on the **SQL Server** connect and click on **Convert to Porject Connection**    

    ![Resource groups is highlighted in the Azure services list.](media/credconvert.png "Azure services")
    
1. Now you should be able to see a newly created connection under **connection manager** on solution explorer.    
    
    ![Resource groups is highlighted in the Azure services list.](media/projctcncn.png "Azure services")  
    
### Task 4: Deploy Package to the SSISDB on the Managed Instance
      In this task, we will be deploying the fixed package onto the SSIS integration runtime and SSISDB held within the Managed Instance.

1. Right click on the solution and click on properties to change the target server type to 2017 as 2019 is not yet supported.

    ![Resource groups is highlighted in the Azure services list.](media/projctcncn.png "Azure services")  
    
1. On the solution properties, select General under **Configuration Properties** and select **TargetServerVersion** as **SQL Server 2017** from drop-down menu and click on Apply and **ok**.

    ![Resource groups is highlighted in the Azure services list.](media/targetpackgeproject.png "Azure services")  
    
1. If you do get the “Do you want to reload” message, click No to All.   
    
    ![Resource groups is highlighted in the Azure services list.](media/notoall.png "Azure services")  
    
1. Now right click on the solution and click on **Deploy**.

   ![Resource groups is highlighted in the Azure services list.](media/deployproj.png "Azure services")     

1. Click on Next on the **Introduction** page on **Integration Services Deployment Wizard**

1. Click Next on the **Select source** page with default value.
 
    ![Resource groups is highlighted in the Azure services list.](media/selectsource.png "Azure services") 
    
1. On the **Deployment Target** page select **SSIS in Azure Data Factory** and click on Next. 

    ![Resource groups is highlighted in the Azure services list.](media/ssdf.png "Azure services") 

1. Now under **Destination** enter the below details and click on **Connect**.

    * Server Name: Enter the SQLMI FQDN noted from the previous task
    * Authentication: **SQL Server Authentication**
    * Username: **Contosoadmin**
    * Password: **IAE5fAijit0w^rDM**
    * Path : **/SSISDB/demo/SSISDW**
   
    ![Resource groups is highlighted in the Azure services list.](media/destsqlmi.png "Azure services") 
    
1. Review the values and click on **Deploy** button to start the project deployment.    
    
    ![Resource groups is highlighted in the Azure services list.](media/deploypackage.png "Azure services") 
    


### Task 5:  Verify Deployment and test run package.
