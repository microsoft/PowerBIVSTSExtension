#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
# Power BI API Extension for Visual Studio Team Services (VSTS)

## Overview
Governance whether we like it or not is embedded into our organisations with release control cycles in place for everything from code through to documents.
  
Today an increasing number of companies use business intelligence products with Microsoft being recognised as the Analytics and BI leader for the eleventh consecutive year.
Microsoft Power BI is the latest offering allowing self-service business intelligence and reporting
Although Power BI is aimed at the mass market and end users it is lacking in its capabilities around governance and version control.

Traditionally developers or users creating reports would store the original report in a folder and overwrite it when changes were made.  Today even small enterprises are adopting the DevOps Lifecyle for development of applications and reports.

This VSTS has been created to allow the control of Power BI Reports from within the VSTS portal.
***

## Features
With this extension you can:
* Control Power BI Reports with VSTS Release Pipelines
* Create Power BI Workspaces (Groups)
* Delete Power BI Workspaces (Groups)
* Upload Power Bi Files to Workspaces
***

## Requirements

***

## Installation Instructions
1. Create a power BI Application
2. Create a GIT repository to hold the reports
4. Install the VSTS Extension
5. Configure the VSTS Extension
***

### Step:1 Create a Power BI Application
1. Navigate to https://dev.powerbi.com/apps and click the **"Sign in with your existing account"** Button and login to Power BI

![Register Application Step 1](../VSTS%20Extension/images/RegisterApplication/RegisterApplication1.png)

2. When logged in the following should be shown

![Register application step 1 response](../VSTS%20Extension/images/RegisterApplication/RegisterApplication2.png)

3. Enter the following details for your application

![Register application step 2](../VSTS%20Extension/images/RegisterApplication/RegisterApplication3.png)
* **App Name:** Name for the application (Recommended name: VSTS Power BI Integration)
* **App Type:** Choose "Native"
* **Redirect URL:** Enter "https://login.live.com/oauth20_desktop.srf"

4. Choose **"Create Content"** for the API Access Level

![Register application step 3](../VSTS%20Extension/images/RegisterApplication/RegisterApplication4.png)

5. Click the **"Register App"** Button to complete the registration

![Register application step 4](../VSTS%20Extension/images/RegisterApplication/RegisterApplication5.png)

6. Once the App is registered the **"Client ID"** should be populated __Keep this safe as we will need it later__

![Register application step 4 Response](../VSTS%20Extension/images/RegisterApplication/RegisterApplication6.png)
***

### Step:2 Create a GIT repository to hold the reports
1.	Login to VSTS
2.	Create a New project to hold the Power BI Reports

***

### Step:4 Install the VSTS Extension

***
### Step:5 Configure the VSTS Extension


# Using the Extensions
*please leave a review*
***

### Check the permissions assigned to the "Client ID"
1. Login to the Azure portal https://portal.azure.com

![Azure Portal](../VSTS%20Extension/images/AzureAD/AzureAD0.PNG)

2. Navigate to "Azure Active Directory" and click on it

![Azure Active Directory](../VSTS%20Extension/images/AzureAD/AzureAD1.PNG)

3. Navigate to "App registrations" and click on it

![App registrations](../VSTS%20Extension/images/AzureAD/AzureAD2.PNG)

4. Find the App registration for "VSTS PowerBI Integration" (or another name if used) and click on it

![VSTS Power BI Integration](../VSTS%20Extension/images/AzureAD/AzureAD3.PNG)

6. From here you can see the "Client ID" (shown as **Application ID**) if you did not save it for use previously. click on settings


![VSTS Power BI Integration](../VSTS%20Extension/images/AzureAD/AzureAD4.PNG)

7.the settings blade will now be shown

![VSTS Power BI Integration](../VSTS%20Extension/images/AzureAD/AzureAD5.PNG)

8. Click **Required Permissions** then click on **Power BI Services (Power BI)**

![VSTS Power BI Integration](../VSTS%20Extension/images/AzureAD/AzureAD8.PNG)

9. The assigned permissions for the VSTS application are shown

![VSTS Power BI Integration](../VSTS%20Extension/images/AzureAD/AzureAD9.PNG)


