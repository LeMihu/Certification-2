*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Robocorp.Vault
Library             RPA.Dialogs


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Fill using CSV


*** Keywords ***
Fill using CSV
    Add heading    Enter the site from where to download the csv file
    Add text input    site    label=Enter the site
    ${site}=    Run dialog
    #https://robotsparebinindustries.com/orders.csv
    Download    ${site.site}    overwrite=True
    ${secret}=    Get Secret    credentials
    Log    ${secret}[site]
    Open Available Browser    ${secret}[site]
    Click Link    Order your robot!
    ${orders}=    Read table from CSV    orders.csv    header = True
    FOR    ${order}    IN    @{orders}
        Fill the form    ${order}
    END
    Close Browser
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}Orders
    ...    ${zip_file_name}

Fill the form
    [Arguments]    ${order}
    Click Button    OK
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button    id=preview
    Wait Until Keyword Succeeds    3x    1s    Next button
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}Orders/Robot ${order}[Order number].png
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    HTML to PDF    ${sales_results_html}    ${OUTPUT_DIR}${/}Orders/Robot ${order}[Order number].pdf
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}Orders/Robot ${order}[Order number].png
    Add Files To PDF    ${files}    ${OUTPUT_DIR}${/}Orders/Robot ${order}[Order number].pdf    append=True
    Click Button    id:order-another

Next button
    Click Button    id=order
    Wait Until Page Contains Element    id:receipt
