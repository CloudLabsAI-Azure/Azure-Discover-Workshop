
# Azure Discover Workshop

Wide World Importers (WWI) is the developer of the popular Tailspin Toys brand of online video games. Founded in 2010, the company has experienced exponential growth since releasing the first installment of their most popular game franchise to include online multiplayer gameplay. They have since built upon this success by adding online capabilities to the majority of their game portfolio.

To facilitate online gameplay, they host gaming services on-premises using rented hardware. Adding online gameplay has dramatically increased their games' popularity, but the rapid increase in demand for their services has made supporting the current setup problematic.

WWI is excited to learn more about how migrating to the cloud can improve its overall processes and address the concerns and issues with its on-premises setup. They are looking for a proof-of-concept (PoC) for migrating their gaming VMs and databases into the cloud. With an end goal of migrating their entire service to Azure, the WWI engineering team is also interested in understanding better what their overall architecture will look like in the cloud.




## Hands-on labs ##
In these hands-on labs, you will implement a proof-of-concept (PoC) for migrating an on-premises SQL Server 2008 R2 database into Azure SQL Database Managed Instance (SQL MI). You will then migrate the customer's on-premises databases into Azure, using migration services. Additionally, you will migrate SSIS packages from on premise into Azure PaaS Services. Finally, you will enable some of the advanced SQL features available in SQL MI to improve security and performance in the customer's application.
At the end of this hands-on lab, you will be better able to implement a cloud migration solution for business-critical applications and databases.

## Lab Architecture ##

The following diagram provides an overview of the Lab environment that will be built.


![SQL Hack Architecture](https://github.com/sk-bln/SQL-Hackathon/raw/master/Hands-On%20Lab/SQLHack%20Architecture.png "SQL Hack Architecture")


## Azure services and related products ##
* Azure SQL Database Managed Instance (SQL MI)
* Azure SQL Database (SQL DB)
* Azure Database Migration Service (DMS)
* Microsoft Data Migration Assistant (DMA)
* SQL Server 2008
* SQL Server on VM
* SQL Server Management Studio (SSMS)
* Azure virtual machines
* Visual Studio SSDT
* Azure virtual network
* Azure virtual network gateway
* Azure Blob Storage account
* Azure Key Vault
* Azure Data Factory
* Integration Runtime SSIS
