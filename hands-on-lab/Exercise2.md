## Exercise 2: General post-setup tasks

### Task 1: Enable CLR on the SQL Managed Instance 

1. In Microsoft SQL Server Management Studio, select **New Query** from the SSMS toolbar.

    ![The New Query button is highlighted in the SSMS toolbar.](media/1.11.png "SSMS Toolbar")
    
1. Next, copy and paste the SQL script below into the new query window. This script enable the Common Language Runtime on Managed Instance.

    ```sql
    EXEC sp_configure 'clr enabled', 1;
    GO
    RECONFIGURE;
    GO
    ```
1. To run the script, select **Execute** from the SSMS toolbar.

    ![The Execute button is highlighted in the SSMS toolbar.](media/1.12.png "SSMS Toolbar")
    
### Task 2: Prepare SSIS Demo

1. In the File Explorer dialog, navigate to the `C:\Labfiles` folder. In the `lab-files` folder, Right click on `ssis.ps1` powershell script and click on **Run with powershell**.
    
    ![The Execute button is highlighted in the SSMS toolbar.](media/1.69.png "SSMS Toolbar")
   
    
### Task 3: Create an Azure-SSIS integration runtime

1. Navigate to the [Azure portal](https://portal.azure.com), search and select **Data Factories** from the Azure search bar.

    ![Resource groups is highlighted in the Azure services list.](media/1.14.png "Azure services")

1. Select your **Data Factory**.

    ![Resource groups is highlighted in the Azure services list.](media/1.15.png "Azure services")
    
1. In the **Overview** section, Click on **Launch Studio**.

    ![Resource groups is highlighted in the Azure services list.](media/1.16.png "Azure services")

1. In the Azure Data Factory UI, switch to the **Manage** tab, and then switch to the **Integration runtimes** tab to view existing integration runtimes in your data factory.

    ![Resource groups is highlighted in the Azure services list.](media/1.18.png "Azure services")
    
1. Click on the Manage icon->Integration Runtimes. Select SSISIR and click Start. If it cannot be started, delete the SSISIR integration runtime and follow the below steps to create a new SSIS integration runtime.

1. Select **New** to create an Azure-SSIS IR and open the Integration runtime setup pane.

    ![Resource groups is highlighted in the Azure services list.](media/1.19.png "Azure services")

1. In the Integration runtime setup pane, select the **Lift-and-shift existing SSIS packages to execute in Azure tile**, and then select **Continue**.

    ![Resource groups is highlighted in the Azure services list.](media/1.20.png "Azure services")
    
1. On the **General settings** page of Integration runtime setup pane, complete the following steps.

    - Enter Name : **SSISIR**
    - Location: **Central US**
    - Node Size: **D4_v3 (4 Core(s), 16384 MB)**
    - Node Number: **1**
    - Click on **Continue**.

    ![Resource groups is highlighted in the Azure services list.](media/1.70.png "Azure services")
    
1. On the Deployment settings page of Integration runtime setup pane, you have the options to create **SSISDB**.

    - Enter Admin Username: **contosoadmin**
    - Enter Admin Password: **IAE5fAijit0w^rDM**
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
    
### Task 3: Review the Security of Microsoft Defender for Cloud.

1. Search and select **SQL Managed instance** from the Azure search bar.
    
    ![Resource groups is highlighted in the Azure services list.](media/1.26.png "Azure services")

1. Select your **Managed instance**.

    ![Resource groups is highlighted in the Azure services list.](media/1.27.png "Azure services")
    
1. Under the Security, select **Microsoft Defender for Cloud**.
    
    ![Resource groups is highlighted in the Azure services list.](media/1.28.png "Azure services")
    
1. At the top of the page click on the **Configure** link next to the Azure Defender for SQL: Enabled at the server-level header.

    ![Resource groups is highlighted in the Azure services list.](media/1.30.png "Azure services")
        
1. Under the VULNERABILITY ASSESSMENT SETTINGS, check your **Subscription** and check defender is linked to a **Storage account**.

    ![Resource groups is highlighted in the Azure services list.](media/1.29.png "Azure services")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
