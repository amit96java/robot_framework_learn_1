*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Library    .Automation.payload.py
*** Variables ***
${base_url}=                https://10.127.5.222
${create_device_url}=       /api/restconf/operations/adtran-cloud-platform-orchestration:create
&{headers_json}             Content-Type=application/json
*** Test Cases ***

Test_3_CREATE_DEVICE
    ${header}=  create dictionary    Content-Type=application/json  Authorization=Bearer 849e00b52acd73f9d864f523c511bdd06ea2d66654460edd63f723ce1cfa37e4
    ${attr}=  create dictionary    device-name=Sample-device-001  model-name=Generic Device   interface-name=inf-1
    ${device_context}=  create dictionary    device-context=${attr}
    ${create_device_body}=  create dictionary    input=${device_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    Post Request    mysession   ${create_device_url}    json=${create_device_body}    headers=${header}
    log to console    ${response.content}