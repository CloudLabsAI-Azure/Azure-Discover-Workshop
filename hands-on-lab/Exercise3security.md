### Task 1: Review the already enabled Security of Microsoft Defender for Cloud.

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
    
1. Click on **Save**.
    
1. Navigate back to Microsoft defender for cloud and Click on **View all recommendations in Defender for Cloud**.

    ![Resource groups is highlighted in the Azure services list.](media/1.86.png "Azure services")

1. On the Recommendation page, pay attention to the first part of the page; the summary view. It includes the current progress on the **Recommendations status** (both completed security controls and recommendations), and **Resource health** (by severity).

    ![Resource groups is highlighted in the Azure services list.](media/1.87.png "Azure services")


1. From the top menu, click on the **Download CSV report** button – this allows you to get a snapshot of your resources, their health status, and the associated            recommendations. You can use this file for pivoting and reporting.

    ![Resource groups is highlighted in the Azure services list.](media/1.88.png "Azure services")
   
1. To view the recommendation, search and select **Machines should have a vulnerability assessment solution**.

    ![Resource groups is highlighted in the Azure services list.](media/1.89.png "Azure services")
    
    
1. Click to expand **Remediation steps (1)** – then click on the **Quick fix logic (2)** option to expose an automatic remediation script content (ARM template). Once    done, **Close (3)** this window. 

    ![Resource groups is highlighted in the Azure services list.](media/1.90.png "Azure services")
    
1. From the Affected resources tab, you will see **no Unhealthy resources** and **no Healthy resources** are there to fix because they all are already fix

    ![Resource groups is highlighted in the Azure services list.](media/1.91.png "Azure services")
    
