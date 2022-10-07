*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Library    .Automation.payload.py

*** Variables ***
${base_url}=                https://10.127.5.199
${create_device_url}=       /api/restconf/operations/adtran-cloud-platform-orchestration:create
${create_profile_url}=      /api/restconf/data/adtran-cloud-platform-profiles:profiles/profile
${delete_profile_url}=      /api/restconf/data/adtran-cloud-platform-profiles:profiles/profile=
${create_profile_vector_url}=       /api/restconf/data/adtran-cloud-platform-profiles:profiles/vectors/vector
${delete_profile_vector_url}=       /api/restconf/data/adtran-cloud-platform-profiles:profiles/vectors/vector=
${orc_create_url}=              /api/restconf/operations/adtran-cloud-platform-orchestration:create
${orc_delete_url}=              /api/restconf/operations/adtran-cloud-platform-orchestration:delete
${get_inventory_tree_url}=      /api/restconf/operations/adtran-cloud-platform-mcp-inventory-status:get-inventory-tree
${get_transaction_url}=         /api/restconf/data/adtran-cloud-platform-uiworkflow:transitions/transition=

*** Test Cases ***
Short name of interface should be resolved
    CREATE_PROFILE
    CREATE_PROFILE_VECTOR
    CREATE_INTERFACE
    CREATE_DEVICE
    CREATE_PARENT_INTERFACE
    GET_INVENTORY_TREE
    DELETE_PARENT_INTERFACE
    DELETE_DEVICE
    DELETE_INTERFACE
    DELETE_PROFILE_VECTOR
    DELETE_PROFILE


*** keywords ***

CREATE_PROFILE
    log_stage   creating profile
    ${object_name_modifier_parameters}=     create dictionary    tree-view-display-name=$interface_type$#$interface_id$
    ${profile_input_payload}=   create dictionary    name=some-profile  state=activated     type=object-name-modifier-profile-type    object-name-modifier-parameters=${object_name_modifier_parameters}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    Post Request    mysession   ${create_profile_url}    json=${profile_input_payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   201

CREATE_PROFILE_VECTOR
    log_stage   creating profile vector
    ${profile_details}=     create dictionary    type=object-name-modifier-profile-type     name=some-profile
    ${profile_details_list}=    create list    ${profile_details}
    ${payload}=     create dictionary    name=some-pv   profile=${profile_details_list}     state=activated     type=device
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    Post Request    mysession   ${create_profile_vector_url}    json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   201

CREATE_INTERFACE
    log_stage   creating interface
    ${interface_details}=   create dictionary    interface-name=inf-2   interface-type=generic  device-name=rooted-device
    ${interface_context}=   create dictionary    interface-context=${interface_details}
    ${payload}=     create dictionary    input=${interface_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_create_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok

CREATE_DEVICE
    log_stage   creating device
    ${managment_attr}=      create dictionary    ip-address=10.127.3.115    mask=255.255.255.0  gateway=10.127.3.115
    ${static_attr}=     create dictionary    management-domain-static-ipv4=${managment_attr}
    ${attr}=  create dictionary    device-name=dev-1  model-name=Generic Device   management-domain-context=${static_attr}  interface-name=inf-2    base-configuration=""
    ${device_context}=  create dictionary    device-context=${attr}
    ${payload}=  create dictionary    input=${device_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_create_url}   json=${payload}
    log to console    device response is ${response.content}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok

CREATE_PARENT_INTERFACE
    log_stage   creating parent interface
    ${interface_details}=   create dictionary    interface-name=inf-1   interface-type=generic  device-name=dev-1   profile-vector-name=some-pv     interface-id=12
    ${interface_context}=   create dictionary    interface-context=${interface_details}
    ${payload}=     create dictionary    input=${interface_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_create_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok

GET_INVENTORY_TREE
    log_stage   getting inventory tree
     ${inventory_object_details}=   create dictionary    name=dev-1     type=device
     ${inventory_object}=   create dictionary    inventory-object=${inventory_object_details}
     ${payload}=    create dictionary    input=${inventory_object}
     ${auth}=  Create List  ADMIN  P@ssw0rd
     Create Session  mysession     ${base_url}     auth=${auth}
     ${response}=    POST REQUEST    mysession   ${get_inventory_tree_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    log to console    short name is ${response.content}
    ${resp_string}=     convert to string    ${response.content}
    ${json}=    evaluate    json.loads('''${resp_string}''')    json
    ${resolved_short_name}=     convert to string    ${json["output"]["object-list"][0]["short-name"]}
    should be equal    ${resolved_short_name}   generic#12

DELETE_PARENT_INTERFACE
    log_stage   deleting parent interface
    ${interface_details}=   create dictionary    interface-name=inf-1
    ${interface_context}=   create dictionary    interface-context=${interface_details}
    ${payload}=     create dictionary    input=${interface_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_delete_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok


DELETE_DEVICE
    log_stage   deleting device
    ${attr}=  create dictionary    device-name=dev-1
    ${device_context}=  create dictionary    device-context=${attr}
    ${payload}=  create dictionary    input=${device_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_delete_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok

DELETE_INTERFACE
    log_stage   deleting interface
    ${interface_details}=   create dictionary    interface-name=inf-2
    ${interface_context}=   create dictionary    interface-context=${interface_details}
    ${payload}=     create dictionary    input=${interface_context}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    POST REQUEST    mysession   ${orc_delete_url}   json=${payload}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}       200
    ${trans_id}=    get_transaction_id      json_string=${response.content}
    verify_transaction_status   transaction_id=${trans_id}    status=completed-ok

DELETE_PROFILE_VECTOR
    log_stage   deleting profile vector
    ${auth}=  Create List  ADMIN  P@ssw0rd
    ${complete_delete_url}=      catenate    SEPARATOR=     ${delete_profile_vector_url}   some-pv
    log to console    complete ur is ${complete_delete_url}
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    delete request    mysession     ${complete_delete_url}
    log to console    delete response is ${response.content}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   204

DELETE_PROFILE
    log_stage   deleting profile
    ${auth}=  Create List  ADMIN  P@ssw0rd
    ${complete_delete_profile_url}=     catenate    SEPARATOR=       ${delete_profile_url}   object-name-modifier-profile-type,some-profile
    log to console    complete pofile url is ${complete_delete_profile_url}
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    delete request    mysession     ${complete_delete_profile_url}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   204

verify_transaction_status
    [Arguments]    ${transaction_id}    ${status}
    wait until keyword succeeds    10x      1sec    process_transaction     ${transaction_id}   ${status}

process_transaction
    [Arguments]    ${transaction_id}    ${status}
    ${auth}=  Create List  ADMIN  P@ssw0rd
    ${complete_trans_url}=      catenate    SEPARATOR=     ${get_transaction_url}   ${transaction_id}
    log to console    complete trans url ${complete_trans_url}
    Create Session  mysession     ${base_url}     auth=${auth}
    ${response}=    get request    mysession     ${complete_trans_url}
    #validations
    ${status_code}=     convert to string    ${response.status_code}
    should be equal    ${status_code}   200
    ${resp_string}=    convert to string    ${response.content}
    ${json}=    evaluate    json.loads('''${resp_string}''')    json
    ${completion_status}=   convert to string    ${json["completion-status"]}
    log to console    completion status is ${completion_status}
    should be equal    ${completion_status}     ${status}

get_transaction_id
    [Arguments]    ${json_string}
    ${json}=    evaluate    json.loads('''${json_string}''')    json
    ${trans_id}=    convert to string    ${json["output"]["trans-id"]}
    [return]    ${trans_id}


log_stage
    [Arguments]    ${msg}
    log to console    msg is ......................${msg}