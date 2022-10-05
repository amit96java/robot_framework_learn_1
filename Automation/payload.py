
body = {
    "input": {
        "device-context": {
            "device-name": "SampleDevice-001",
            "model-name": "Generic Device",
            "base-configuration": "",
            "management-domain-context": {
                "management-vlan-outer-tag": 234,
                "management-domain-static-ipv4": {
                    "ip-address": "10.10.10.2",
                    "mask": "255.255.255.252",
                    "gateway": "10.10.10.1"
                }
            },
            "interface-name": "SampleInterface-002"
        }
    }
}


header = {"Content-Type": "application/json",
          "Authorization": "Bearer 849e00b52acd73f9d864f523c511bdd06ea2d66654460edd63f723ce1cfa37e4"}
