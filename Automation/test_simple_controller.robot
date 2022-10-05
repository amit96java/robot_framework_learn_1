*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Library    payload.py

*** Variables ***
${base_url}=                http://localhost:9090
${create_emloyee}=           /simple/
&{headers_json}             Content-Type=application/json
${create_employee_body}=    {"firstName": "amit",    "lastName": "pal"}

*** Test Cases ***
Test_1
    log to console    hello amit

#simple_controller i have written in java spring boot
Test_3_CREATE_EMPLOYEE
    ${header}=  create dictionary    Content-Type=application/json
    Create Session  mysession     ${base_url}
    ${response}=    Post Request    mysession   ${create_emloyee}    data=${create_employee_body}  headers=${header}
    log to console    status code is ${response.status_code}
    ${resp}=    convert to string    ${response.content}
    log to console    response content is ${resp}

    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   201
    should be equal    ${resp}      pal amit

