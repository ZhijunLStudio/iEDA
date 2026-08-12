# Interface Silent-Success Inventory

Schema: `ieda.interface.inventory.v1`

## Summary

- Findings: 491
- API candidates: 273
- By mode: `{"python": 52, "tcl": 439}`
- By severity: `{"high": 101, "low": 146, "medium": 244}`
- By API status: `{"not_exposed_to_interface": 131, "referenced_by_interface": 142}`

## Open Findings

| Severity | Mode | Tool | File:line | Pattern | Status | Test |
|---|---|---|---|---|---|---|
| high | python | flow | `src/interface/python/py_flow/py_flow.cpp:25` | literal_success_return | open | `interface_python_flow_literal_success_return_regression` |
| high | python | instance | `src/interface/python/py_instance/py_inst.cpp:26` | literal_success_return | open | `interface_python_instance_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:49` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:58` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:66` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:73` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:81` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:88` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:158` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:167` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:176` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:183` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:223` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | ista | `src/interface/python/py_ista/py_ista.cpp:247` | literal_success_return | open | `interface_python_ista_literal_success_return_regression` |
| high | python | report | `src/interface/python/py_report/py_register_report.h:32` | empty_implementation | open | `interface_python_report_empty_implementation_regression` |
| high | tcl | definition.h | `src/interface/tcl/tcl_definition.h:53` | default_check_success_macro | open | `interface_tcl_definition.h_default_check_success_macro_regression` |
| high | tcl | definition.h | `src/interface/tcl/tcl_definition.h:59` | default_check_success | open | `interface_tcl_definition.h_default_check_success_regression` |
| high | tcl | definition.h | `src/interface/tcl/tcl_definition.h:65` | literal_failure_return | open | `interface_tcl_definition.h_literal_failure_return_regression` |
| high | tcl | definition.h | `src/interface/tcl/tcl_definition.h:70` | literal_success_return | open | `interface_tcl_definition.h_literal_success_return_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flow.cpp:39` | default_check_success | open | `interface_tcl_flow_default_check_success_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flow.cpp:45` | literal_failure_return | open | `interface_tcl_flow_literal_failure_return_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flow.cpp:50` | literal_success_return | open | `interface_tcl_flow_literal_success_return_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flowconfig.cpp:56` | literal_failure_return | open | `interface_tcl_flow_literal_failure_return_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flowconfig.cpp:61` | literal_success_return | open | `interface_tcl_flow_literal_success_return_regression` |
| high | tcl | flow | `src/interface/tcl/tcl_flow/tcl_flowconfig.h:34` | literal_success_return | open | `interface_tcl_flow_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:38` | default_check_success | open | `interface_tcl_icts_default_check_success_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:44` | literal_failure_return | open | `interface_tcl_icts_literal_failure_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:62` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:83` | default_check_success | open | `interface_tcl_icts_default_check_success_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:89` | literal_failure_return | open | `interface_tcl_icts_literal_failure_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:96` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:104` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:107` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:121` | literal_failure_return | open | `interface_tcl_icts_literal_failure_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_cts.cpp:123` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_ctsconfig.cpp:90` | literal_failure_return | open | `interface_tcl_icts_literal_failure_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_ctsconfig.cpp:95` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | icts | `src/interface/tcl/tcl_icts/tcl_ctsconfig.h:34` | literal_success_return | open | `interface_tcl_icts_literal_success_return_regression` |
| high | tcl | instance | `src/interface/tcl/tcl_instance/tcl_inst.cpp:55` | literal_success_return | open | `interface_tcl_instance_literal_success_return_regression` |
| high | tcl | instance | `src/interface/tcl/tcl_instance/tcl_inst.cpp:61` | literal_failure_return | open | `interface_tcl_instance_literal_failure_return_regression` |
| high | tcl | instance | `src/interface/tcl/tcl_instance/tcl_inst.cpp:88` | literal_success_return | open | `interface_tcl_instance_literal_success_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:33` | default_check_success | open | `interface_tcl_ista_default_check_success_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:39` | literal_failure_return | open | `interface_tcl_ista_literal_failure_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:47` | literal_failure_return | open | `interface_tcl_ista_literal_failure_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:50` | literal_success_return | open | `interface_tcl_ista_literal_success_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:70` | default_check_success | open | `interface_tcl_ista_default_check_success_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:76` | literal_failure_return | open | `interface_tcl_ista_literal_failure_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:87` | literal_success_return | open | `interface_tcl_ista_literal_success_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:103` | default_check_success | open | `interface_tcl_ista_default_check_success_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:109` | literal_failure_return | open | `interface_tcl_ista_literal_failure_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:119` | literal_success_return | open | `interface_tcl_ista_literal_success_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:134` | default_check_success | open | `interface_tcl_ista_default_check_success_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:140` | literal_failure_return | open | `interface_tcl_ista_literal_failure_return_regression` |
| high | tcl | ista | `src/interface/tcl/tcl_ista/tcl_sta.cpp:150` | literal_success_return | open | `interface_tcl_ista_literal_success_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:36` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:42` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:51` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:55` | literal_success_return | open | `interface_tcl_ito_literal_success_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:72` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:78` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:87` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:91` | literal_success_return | open | `interface_tcl_ito_literal_success_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:108` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:114` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:147` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:153` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:183` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:189` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:219` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:225` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:257` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:259` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:263` | default_check_success_macro | open | `interface_tcl_ito_default_check_success_macro_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:266` | default_check_success_macro | open | `interface_tcl_ito_default_check_success_macro_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:269` | default_check_success_macro | open | `interface_tcl_ito_default_check_success_macro_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:272` | default_check_success_macro | open | `interface_tcl_ito_default_check_success_macro_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:284` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:286` | default_check_success | open | `interface_tcl_ito_default_check_success_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_ito.cpp:290` | default_check_success_macro | open | `interface_tcl_ito_default_check_success_macro_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.cpp:79` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.cpp:85` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.cpp:91` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.cpp:95` | literal_success_return | open | `interface_tcl_ito_literal_success_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.cpp:102` | literal_failure_return | open | `interface_tcl_ito_literal_failure_return_regression` |
| high | tcl | ito | `src/interface/tcl/tcl_ito/tcl_toconfig.h:32` | literal_success_return | open | `interface_tcl_ito_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_db/tcl_report_db.cpp:36` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_db/tcl_report_db.cpp:42` | literal_failure_return | open | `interface_tcl_report_literal_failure_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_db/tcl_report_db.cpp:49` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_db/tcl_report_db.cpp:59` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_db/tcl_report_db.cpp:65` | literal_failure_return | open | `interface_tcl_report_literal_failure_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_evl/tcl_report_evl.cpp:28` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_evl/tcl_report_evl.cpp:40` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_evl/tcl_report_evl.cpp:51` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_evl/tcl_report_evl.cpp:62` | default_check_success | open | `interface_tcl_report_default_check_success_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_evl/tcl_report_evl.cpp:67` | literal_failure_return | open | `interface_tcl_report_literal_failure_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_place.cpp:37` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_place.cpp:54` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_place.h:32` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_place.h:41` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_route.cpp:36` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| high | tcl | report | `src/interface/tcl/tcl_report/tcl_report_pr/tcl_report_route.h:35` | literal_success_return | open | `interface_tcl_report_literal_success_return_regression` |
| low | python | config | `src/interface/python/py_config/py_register_config.h:30` | empty_implementation | open | `interface_python_config_empty_implementation_regression` |
| low | python | config | `src/interface/python/py_config/py_register_config.h:35` | empty_implementation | open | `interface_python_config_empty_implementation_regression` |
| low | python | idb | `src/interface/python/py_idb/py_db.cpp:62` | empty_implementation | open | `interface_python_idb_empty_implementation_regression` |
| low | python | idb | `src/interface/python/py_idb/py_db.h:32` | empty_implementation | open | `interface_python_idb_empty_implementation_regression` |
| low | python | idb | `src/interface/python/py_idb/py_register_idb.h:38` | empty_implementation | open | `interface_python_idb_empty_implementation_regression` |
| low | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:36` | empty_implementation | open | `interface_python_ifp_empty_implementation_regression` |
| low | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:37` | empty_implementation | open | `interface_python_ifp_empty_implementation_regression` |
| low | python | ipdn | `src/interface/python/py_ipdn/py_register_ipdn.h:39` | empty_implementation | open | `interface_python_ipdn_empty_implementation_regression` |
| low | python | ipdn | `src/interface/python/py_ipdn/py_register_ipdn.h:40` | empty_implementation | open | `interface_python_ipdn_empty_implementation_regression` |
| low | python | ipdn | `src/interface/python/py_ipdn/py_register_ipdn.h:41` | empty_implementation | open | `interface_python_ipdn_empty_implementation_regression` |
| low | python | irt | `src/interface/python/py_irt/py_register_irt.h:28` | empty_implementation | open | `interface_python_irt_empty_implementation_regression` |
| low | python | irt | `src/interface/python/py_irt/py_register_irt.h:29` | empty_implementation | open | `interface_python_irt_empty_implementation_regression` |
| low | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:51` | literal_failure_return | open | `interface_tcl_config_literal_failure_return_regression` |
| low | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:109` | literal_failure_return | open | `interface_tcl_config_literal_failure_return_regression` |
| low | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:43` | literal_failure_return | open | `interface_tcl_contest_literal_failure_return_regression` |
| low | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:80` | literal_failure_return | open | `interface_tcl_contest_literal_failure_return_regression` |
| low | tcl | eco | `src/interface/tcl/tcl_eco/tcl_eco.cpp:50` | literal_failure_return | open | `interface_tcl_eco_literal_failure_return_regression` |
| low | tcl | eco | `src/interface/tcl/tcl_eco/tcl_eco.cpp:62` | literal_failure_return | open | `interface_tcl_eco_literal_failure_return_regression` |
| low | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:57` | literal_failure_return | open | `interface_tcl_eval_literal_failure_return_regression` |
| low | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:97` | literal_failure_return | open | `interface_tcl_eval_literal_failure_return_regression` |
| low | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:139` | literal_failure_return | open | `interface_tcl_eval_literal_failure_return_regression` |
| low | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:182` | literal_failure_return | open | `interface_tcl_eval_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:59` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:102` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:149` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:186` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:219` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:258` | literal_failure_return | open | `interface_tcl_feature_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:49` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:84` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:112` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:143` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:182` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:209` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:244` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | gui | `src/interface/tcl/tcl_gui/tcl_web.cpp:48` | literal_failure_return | open | `interface_tcl_gui_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:43` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:75` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:113` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:151` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:188` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:221` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:258` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:299` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:351` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:414` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:457` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:504` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:47` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:75` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:109` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:131` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:211` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:220` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:257` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:264` | literal_failure_return | open | `interface_tcl_idb_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:35` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:60` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:98` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_destroy_drc.cpp:30` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_drc_cmp_violation.cpp:33` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_init_drc.cpp:40` | literal_failure_return | open | `interface_tcl_idrc_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:40` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:79` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:130` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:185` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:84` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:88` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:92` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:99` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:114` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:147` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:158` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:224` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:46` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:97` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:149` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:195` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:236` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:242` | empty_implementation | open | `interface_tcl_ifp_empty_implementation_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:243` | empty_implementation | open | `interface_tcl_ifp_empty_implementation_regression` |
| low | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_tapcell.cpp:52` | literal_failure_return | open | `interface_tcl_ifp_literal_failure_return_regression` |
| low | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:39` | literal_failure_return | open | `interface_tcl_ino_literal_failure_return_regression` |
| low | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:47` | literal_failure_return | open | `interface_tcl_ino_literal_failure_return_regression` |
| low | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:70` | literal_failure_return | open | `interface_tcl_ino_literal_failure_return_regression` |
| low | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:78` | literal_failure_return | open | `interface_tcl_ino_literal_failure_return_regression` |
| low | tcl | ino | `src/interface/tcl/tcl_ino/tcl_noconfig.cpp:42` | literal_failure_return | open | `interface_tcl_ino_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:60` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:111` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:171` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:232` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:292` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:338` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:386` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:433` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:481` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:568` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:679` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:734` | literal_failure_return | open | `interface_tcl_ipdn_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:50` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:91` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:125` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:156` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:185` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:206` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:248` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:269` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:290` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:311` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:332` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_plconfig.cpp:63` | literal_failure_return | open | `interface_tcl_ipl_literal_failure_return_regression` |
| low | tcl | ipnp | `src/interface/tcl/tcl_ipnp/tcl_ipnp.cpp:42` | literal_failure_return | open | `interface_tcl_ipnp_literal_failure_return_regression` |
| low | tcl | ipnp | `src/interface/tcl/tcl_ipnp/tcl_ipnp.cpp:82` | literal_failure_return | open | `interface_tcl_ipnp_literal_failure_return_regression` |
| low | tcl | ipw | `src/interface/tcl/tcl_ipw/tcl_power.cpp:51` | literal_failure_return | open | `interface_tcl_ipw_literal_failure_return_regression` |
| low | tcl | ipw | `src/interface/tcl/tcl_ipw/tcl_power.cpp:75` | literal_failure_return | open | `interface_tcl_ipw_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:203` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:209` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:218` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:246` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_dump_net_shape.cpp:41` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_init_rcx.cpp:43` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_init_rcx.cpp:49` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_init_rcx.cpp:58` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:98` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:106` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:116` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_report_rcx.cpp:29` | empty_implementation | open | `interface_tcl_ircx_empty_implementation_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_report_rcx.cpp:34` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_run_rcx.cpp:36` | literal_failure_return | open | `interface_tcl_ircx_literal_failure_return_regression` |
| low | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_destroy_rt.cpp:30` | literal_failure_return | open | `interface_tcl_irt_literal_failure_return_regression` |
| low | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_init_rt.cpp:48` | literal_failure_return | open | `interface_tcl_irt_literal_failure_return_regression` |
| low | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_rt_clean_def.cpp:30` | literal_failure_return | open | `interface_tcl_irt_literal_failure_return_regression` |
| low | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_run_ert.cpp:38` | literal_failure_return | open | `interface_tcl_irt_literal_failure_return_regression` |
| low | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_run_rt.cpp:34` | literal_failure_return | open | `interface_tcl_irt_literal_failure_return_regression` |
| low | tcl | main.h | `src/interface/tcl/tcl_main.h:47` | literal_failure_return | open | `interface_tcl_main.h_literal_failure_return_regression` |
| low | tcl | notification | `src/interface/tcl/tcl_notification/src/tcl_init_notification.cpp:35` | literal_failure_return | open | `interface_tcl_notification_literal_failure_return_regression` |
| low | tcl | util | `src/interface/tcl/tcl_util/tcl_util.cpp:121` | literal_failure_return | open | `interface_tcl_util_literal_failure_return_regression` |
| low | tcl | util | `src/interface/tcl/tcl_util/tcl_util.cpp:128` | literal_failure_return | open | `interface_tcl_util_literal_failure_return_regression` |
| low | tcl | util | `src/interface/tcl/tcl_util/tcl_util.cpp:154` | literal_failure_return | open | `interface_tcl_util_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:53` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:87` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:125` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:131` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:140` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:187` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| low | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:221` | literal_failure_return | open | `interface_tcl_vec_literal_failure_return_regression` |
| medium | python | config | `src/interface/python/py_config/py_config.cpp:66` | literal_success_return | open | `interface_python_config_literal_success_return_regression` |
| medium | python | idb | `src/interface/python/py_idb/py_db.cpp:66` | literal_success_return | open | `interface_python_idb_literal_success_return_regression` |
| medium | python | idb | `src/interface/python/py_idb/py_db_op.h:34` | literal_success_return | open | `interface_python_idb_literal_success_return_regression` |
| medium | python | idb | `src/interface/python/py_idb/py_db_op.h:40` | literal_success_return | open | `interface_python_idb_literal_success_return_regression` |
| medium | python | idrc | `src/interface/python/py_idrc/py_idrc.cpp:35` | literal_success_return | open | `interface_python_idrc_literal_success_return_regression` |
| medium | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:110` | literal_success_return | open | `interface_python_ifp_literal_success_return_regression` |
| medium | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:122` | literal_success_return | open | `interface_python_ifp_literal_success_return_regression` |
| medium | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:136` | literal_success_return | open | `interface_python_ifp_literal_success_return_regression` |
| medium | python | ifp | `src/interface/python/py_ifp/py_ifp.cpp:149` | literal_success_return | open | `interface_python_ifp_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:27` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:33` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:40` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:64` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:70` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:76` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:92` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipdn | `src/interface/python/py_ipdn/py_ipdn.cpp:108` | literal_success_return | open | `interface_python_ipdn_literal_success_return_regression` |
| medium | python | ipl | `src/interface/python/py_ipl/py_ipl.cpp:81` | literal_success_return | open | `interface_python_ipl_literal_success_return_regression` |
| medium | python | ipw | `src/interface/python/py_ipw/py_ipw.cpp:45` | literal_success_return | open | `interface_python_ipw_literal_success_return_regression` |
| medium | python | ipw | `src/interface/python/py_ipw/py_ipw.cpp:79` | literal_success_return | open | `interface_python_ipw_literal_success_return_regression` |
| medium | python | irt | `src/interface/python/py_irt/py_irt.cpp:32` | literal_success_return | open | `interface_python_irt_literal_success_return_regression` |
| medium | python | irt | `src/interface/python/py_irt/py_irt.cpp:45` | literal_success_return | open | `interface_python_irt_literal_success_return_regression` |
| medium | python | irt | `src/interface/python/py_irt/py_irt.cpp:51` | literal_success_return | open | `interface_python_irt_literal_success_return_regression` |
| medium | python | irt | `src/interface/python/py_irt/py_irt.cpp:66` | literal_success_return | open | `interface_python_irt_literal_success_return_regression` |
| medium | python | irt | `src/interface/python/py_irt/py_irt_utils.cpp:119` | literal_success_return | open | `interface_python_irt_literal_success_return_regression` |
| medium | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:45` | default_check_success | open | `interface_tcl_config_default_check_success_regression` |
| medium | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:59` | literal_success_return | open | `interface_tcl_config_literal_success_return_regression` |
| medium | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:103` | default_check_success | open | `interface_tcl_config_default_check_success_regression` |
| medium | tcl | config | `src/interface/tcl/tcl_config/tcl_config.cpp:196` | literal_success_return | open | `interface_tcl_config_literal_success_return_regression` |
| medium | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:37` | default_check_success | open | `interface_tcl_contest_default_check_success_regression` |
| medium | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:55` | literal_success_return | open | `interface_tcl_contest_literal_success_return_regression` |
| medium | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:74` | default_check_success | open | `interface_tcl_contest_default_check_success_regression` |
| medium | tcl | contest | `src/interface/tcl/tcl_contest/tcl_contest.cpp:99` | literal_success_return | open | `interface_tcl_contest_literal_success_return_regression` |
| medium | tcl | eco | `src/interface/tcl/tcl_eco/tcl_eco.cpp:44` | default_check_success | open | `interface_tcl_eco_default_check_success_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:51` | default_check_success | open | `interface_tcl_eval_default_check_success_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:67` | literal_success_return | open | `interface_tcl_eval_literal_success_return_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:91` | literal_success_return | open | `interface_tcl_eval_literal_success_return_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:114` | literal_success_return | open | `interface_tcl_eval_literal_success_return_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:133` | default_check_success | open | `interface_tcl_eval_default_check_success_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:176` | literal_success_return | open | `interface_tcl_eval_literal_success_return_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:219` | default_check_success | open | `interface_tcl_eval_default_check_success_regression` |
| medium | tcl | eval | `src/interface/tcl/tcl_eval/tcl_eval.cpp:240` | literal_success_return | open | `interface_tcl_eval_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:53` | default_check_success | open | `interface_tcl_feature_default_check_success_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:73` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:96` | default_check_success | open | `interface_tcl_feature_default_check_success_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:116` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:143` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:161` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:180` | default_check_success | open | `interface_tcl_feature_default_check_success_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:194` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:213` | default_check_success | open | `interface_tcl_feature_default_check_success_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:227` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:252` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | feature | `src/interface/tcl/tcl_feature/tcl_feature.cpp:272` | literal_success_return | open | `interface_tcl_feature_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:43` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:62` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:78` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:91` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:106` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:119` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:137` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:160` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:176` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:187` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:203` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:222` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:238` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_gui.cpp:258` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_web.cpp:42` | default_check_success | open | `interface_tcl_gui_default_check_success_regression` |
| medium | tcl | gui | `src/interface/tcl/tcl_gui/tcl_web.cpp:59` | literal_success_return | open | `interface_tcl_gui_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db.cpp:36` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db.cpp:54` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:37` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:54` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:69` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:85` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:94` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:107` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:121` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:128` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:145` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:159` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:161` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:182` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:199` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:202` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:215` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:229` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:252` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:266` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:276` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:293` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:306` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:309` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:345` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:359` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:382` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:385` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:408` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:422` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:451` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:467` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:470` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:496` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:515` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_file.cpp:518` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:41` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:57` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:69` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:80` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:103` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:116` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:125` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:136` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:147` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:159` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:170` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:182` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:215` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:244` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:259` | default_check_success | open | `interface_tcl_idb_default_check_success_regression` |
| medium | tcl | idb | `src/interface/tcl/tcl_idb/tcl_db_operate.cpp:273` | literal_success_return | open | `interface_tcl_idb_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/include/tcl_drc.h:30` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/include/tcl_drc.h:44` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/include/tcl_drc.h:58` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/include/tcl_drc.h:72` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:54` | default_check_success | open | `interface_tcl_idrc_default_check_success_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:92` | default_check_success | open | `interface_tcl_idrc_default_check_success_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_check_def.cpp:108` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_destroy_drc.cpp:33` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_drc_cmp_violation.cpp:37` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | idrc | `src/interface/tcl/tcl_idrc/src/tcl_init_drc.cpp:44` | literal_success_return | open | `interface_tcl_idrc_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:34` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:56` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:73` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:97` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:124` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:149` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:179` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_blockage.cpp:207` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:108` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_init_ifp.cpp:218` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:40` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:91` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:143` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:189` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_io.cpp:230` | default_check_success | open | `interface_tcl_ifp_default_check_success_regression` |
| medium | tcl | ifp | `src/interface/tcl/tcl_ifp/tcl_tapcell.cpp:46` | literal_success_return | open | `interface_tcl_ifp_literal_success_return_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:33` | default_check_success | open | `interface_tcl_ino_default_check_success_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:51` | literal_success_return | open | `interface_tcl_ino_literal_success_return_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:64` | default_check_success | open | `interface_tcl_ino_default_check_success_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_ino.cpp:82` | literal_success_return | open | `interface_tcl_ino_literal_success_return_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_noconfig.cpp:47` | literal_success_return | open | `interface_tcl_ino_literal_success_return_regression` |
| medium | tcl | ino | `src/interface/tcl/tcl_ino/tcl_noconfig.h:34` | literal_success_return | open | `interface_tcl_ino_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:54` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:78` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:105` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:124` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:164` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:193` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:227` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:286` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:332` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:380` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:404` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:427` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:444` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:475` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:498` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:562` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:623` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:673` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:702` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:708` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:710` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:728` | default_check_success | open | `interface_tcl_ipdn_default_check_success_regression` |
| medium | tcl | ipdn | `src/interface/tcl/tcl_ipdn/tcl_ipdn.cpp:742` | literal_success_return | open | `interface_tcl_ipdn_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:44` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:85` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:119` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:150` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:160` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:172` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:182` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:200` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:211` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:223` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:230` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:242` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:263` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:284` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:305` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:326` | default_check_success | open | `interface_tcl_ipl_default_check_success_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_ipl.cpp:336` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_plconfig.cpp:68` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipl | `src/interface/tcl/tcl_ipl/tcl_plconfig.h:34` | literal_success_return | open | `interface_tcl_ipl_literal_success_return_regression` |
| medium | tcl | ipnp | `src/interface/tcl/tcl_ipnp/tcl_ipnp.cpp:36` | default_check_success | open | `interface_tcl_ipnp_default_check_success_regression` |
| medium | tcl | ipnp | `src/interface/tcl/tcl_ipnp/tcl_ipnp.cpp:76` | default_check_success | open | `interface_tcl_ipnp_default_check_success_regression` |
| medium | tcl | ipnp | `src/interface/tcl/tcl_ipnp/tcl_ipnp.cpp:95` | literal_success_return | open | `interface_tcl_ipnp_literal_success_return_regression` |
| medium | tcl | ipw | `src/interface/tcl/tcl_ipw/tcl_power.cpp:45` | default_check_success | open | `interface_tcl_ipw_default_check_success_regression` |
| medium | tcl | ipw | `src/interface/tcl/tcl_ipw/tcl_power.cpp:78` | literal_success_return | open | `interface_tcl_ipw_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/include/tcl_ircx.h:47` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/include/tcl_ircx.h:61` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:81` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:102` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:105` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:115` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:125` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:128` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:152` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_compare_spef.cpp:212` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_dump_net_shape.cpp:35` | default_check_success | open | `interface_tcl_ircx_default_check_success_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_init_rcx.cpp:52` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:65` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:71` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:74` | literal_success_return | open | `interface_tcl_ircx_literal_success_return_regression` |
| medium | tcl | ircx | `src/interface/tcl/tcl_ircx/src/tcl_plot_spef.cpp:100` | default_check_success | open | `interface_tcl_ircx_default_check_success_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:31` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:45` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:59` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:73` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:91` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:105` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/include/tcl_rt.h:119` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_destroy_rt.cpp:33` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_init_rt.cpp:52` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_rt_clean_def.cpp:35` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_run_ert.cpp:42` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | irt | `src/interface/tcl/tcl_irt/src/tcl_run_rt.cpp:37` | literal_success_return | open | `interface_tcl_irt_literal_success_return_regression` |
| medium | tcl | notification | `src/interface/tcl/tcl_notification/include/tcl_notification.h:29` | literal_success_return | open | `interface_tcl_notification_literal_success_return_regression` |
| medium | tcl | notification | `src/interface/tcl/tcl_notification/src/tcl_init_notification.cpp:57` | literal_success_return | open | `interface_tcl_notification_literal_success_return_regression` |
| medium | tcl | util | `src/interface/tcl/tcl_util/tcl_util.cpp:159` | literal_success_return | open | `interface_tcl_util_literal_success_return_regression` |
| medium | tcl | util | `src/interface/tcl/tcl_util/tcl_util.h:61` | literal_success_return | open | `interface_tcl_util_literal_success_return_regression` |
| medium | tcl | util | `src/interface/tcl/tcl_util/tcl_util.h:62` | literal_success_return | open | `interface_tcl_util_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:47` | default_check_success | open | `interface_tcl_vec_default_check_success_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:65` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:81` | default_check_success | open | `interface_tcl_vec_default_check_success_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:99` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:134` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:164` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:181` | default_check_success | open | `interface_tcl_vec_default_check_success_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:199` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:215` | default_check_success | open | `interface_tcl_vec_default_check_success_regression` |
| medium | tcl | vec | `src/interface/tcl/tcl_vec/tcl_vec.cpp:232` | literal_success_return | open | `interface_tcl_vec_literal_success_return_regression` |

## API Candidates

| Tool | Layer | File:line | Class | Method | Status |
|---|---|---|---|---|---|
| iECO | operation_api | `src/operation/iECO/api/ieco_api.h:39` | `ECOApi` | `ecoVia` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:47` | `FpApi` | `initDie` | not_exposed_to_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:57` | `FpApi` | `makeTracks` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:58` | `FpApi` | `autoPlacePins` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:59` | `FpApi` | `placePort` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:60` | `FpApi` | `autoPlacePad` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:61` | `FpApi` | `placeIOFiller` | referenced_by_interface |
| iFP | operation_api | `src/operation/iFP/api/ifp_api.h:66` | `FpApi` | `tapCells` | referenced_by_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:118` | `iIR` | `set_pg_provenance` | not_exposed_to_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:141` | `iIR` | `solver_method_name` | not_exposed_to_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:143` | `iIR` | `init` | referenced_by_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:144` | `iIR` | `readSpef` | referenced_by_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:145` | `iIR` | `readInstancePowerDB` | not_exposed_to_interface |
| iIR | operation_api | `src/operation/iIR/api/iIR.hh:156` | `iIR` | `solveIRDrop` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:39` | `NoApi` | `destroyInst` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:41` | `NoApi` | `initNO` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:42` | `NoApi` | `iNODataInit` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:45` | `NoApi` | `fixFanout` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:46` | `NoApi` | `fixIO` | referenced_by_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:47` | `NoApi` | `lastResult` | not_exposed_to_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:49` | `NoApi` | `saveDef` | referenced_by_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:53` | `NoApi` | `reportTiming` | referenced_by_interface |
| iNO | operation_api | `src/operation/iNO/api/NoApi.hpp:56` | `NoApi` | `outputSummary` | not_exposed_to_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:55` | `Power` | `getOrCreatePower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:56` | `Power` | `destroyPower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:63` | `Power` | `set_default_toggle` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:143` | `Power` | `buildGraph` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:145` | `Power` | `readRustVCD` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:146` | `Power` | `dumpGraph` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:147` | `Power` | `buildSeqGraph` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:148` | `Power` | `dumpSeqGraphViz` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:150` | `Power` | `setupClock` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:151` | `Power` | `annotateToggleSP` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:152` | `Power` | `updateActivityCoverage` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:154` | `Power` | `initPowerGraphData` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:156` | `Power` | `checkPipelineLoop` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:157` | `Power` | `levelizeSeqGraph` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:159` | `Power` | `propagateClock` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:160` | `Power` | `propagateConst` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:161` | `Power` | `propagateToggleSP` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:163` | `Power` | `initToggleSPData` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:165` | `Power` | `calcLeakagePower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:166` | `Power` | `calcInternalPower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:167` | `Power` | `calcSwitchPower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:168` | `Power` | `analyzeGroupPower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:169` | `Power` | `updatePower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:177` | `Power` | `reportInstancePowerCSV` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:179` | `Power` | `reportPower` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:181` | `Power` | `getInstancePowerData` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:183` | `Power` | `runCompleteFlow` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:186` | `Power` | `readPGSpef` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:219` | `Power` | `runIRAnalysis` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:220` | `Power` | `reportIRDropTable` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:221` | `Power` | `reportIRDropCSV` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:222` | `Power` | `reportIRAnalysis` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:227` | `Power` | `getNetToggleAndVoltageData` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:229` | `Power` | `displayInstancePowerMap` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/Power.hh:231` | `Power` | `buildPGBudget` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:64` | `PowerEngine` | `destroyPowerEngine` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:75` | `PowerEngine` | `creatDataflow` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:81` | `PowerEngine` | `buildMacroConnectionMap` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:83` | `PowerEngine` | `buildPGNetWireTopo` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:88` | `PowerEngine` | `resetIRAnalysisData` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:110` | `PowerEngine` | `displayIRDropMap` | referenced_by_interface |
| iPA | operation_api | `src/operation/iPA/api/PowerEngine.hh:115` | `PowerEngine` | `buildMacroConnectionMapWithGPU` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:46` | `PdnApi` | `addIOPin` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:47` | `PdnApi` | `globalConnect` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:50` | `PdnApi` | `createGrid` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:53` | `PdnApi` | `connectLayerList` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:58` | `PdnApi` | `connectIOPinToPowerStripe` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:59` | `PdnApi` | `connectPowerStripe` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:61` | `PdnApi` | `addSegmentStripeList` | referenced_by_interface |
| iPDN | operation_api | `src/operation/iPDN/api/ipdn_api.h:66` | `PdnApi` | `addSegmentVia` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:46` | `PLAPI` | `getInst` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:47` | `PLAPI` | `destoryInst` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:49` | `PLAPI` | `initAPI` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:50` | `PLAPI` | `runFlow` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:51` | `PLAPI` | `runFlowResult` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:52` | `PLAPI` | `runAiFlow` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:53` | `PLAPI` | `runAiFlowResult` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:54` | `PLAPI` | `runIncrementalFlow` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:55` | `PLAPI` | `insertLayoutFiller` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:57` | `PLAPI` | `runGP` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:58` | `PLAPI` | `runGPResult` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:59` | `PLAPI` | `runMP` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:60` | `PLAPI` | `runNetworkFlowSpread` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:62` | `PLAPI` | `runLG` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:63` | `PLAPI` | `runIncrLG` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:64` | `PLAPI` | `runIncrLG` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:65` | `PLAPI` | `runIncrLGResult` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:66` | `PLAPI` | `runPostGP` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:67` | `PLAPI` | `runDP` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:69` | `PLAPI` | `runDPwithAiWireLengthPredictor` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:71` | `PLAPI` | `runBufferInsertion` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:72` | `PLAPI` | `writeBackSourceDataBase` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:74` | `PLAPI` | `obtainTargetDir` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:76` | `PLAPI` | `updatePlacerDB` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:77` | `PLAPI` | `updatePlacerDB` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:81` | `PLAPI` | `checkLegality` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:85` | `PLAPI` | `reportPLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:86` | `PLAPI` | `reportTopoInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:87` | `PLAPI` | `reportWLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:88` | `PLAPI` | `reportSTWLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:89` | `PLAPI` | `reportHPWLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:90` | `PLAPI` | `reportLongNetInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:91` | `PLAPI` | `reportViolationInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:92` | `PLAPI` | `reportBinDensity` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:94` | `PLAPI` | `reportLayoutWhiteInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:95` | `PLAPI` | `reportTimingInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:96` | `PLAPI` | `reportCongestionInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:97` | `PLAPI` | `reportPLBaseInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:99` | `PLAPI` | `notifyPLWLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:100` | `PLAPI` | `notifyPLTimingInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:101` | `PLAPI` | `notifySTAUpdateTimingRuntime` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:102` | `PLAPI` | `notifyPLCongestionInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:103` | `PLAPI` | `notifyPLOriginInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:105` | `PLAPI` | `isSTAStarted` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:106` | `PLAPI` | `isPlacerDBStarted` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:107` | `PLAPI` | `isAbucasLGStarted` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:113` | `PLAPI` | `createPLDirectory` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:114` | `PLAPI` | `printHPWLInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:115` | `PLAPI` | `printTimingInfo` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:116` | `PLAPI` | `saveNetPinInfoForDebug` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:117` | `PLAPI` | `savePinListInfoForDebug` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:118` | `PLAPI` | `plotConnectionForDebug` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:119` | `PLAPI` | `plotModuleListForDebug` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:120` | `PLAPI` | `plotModuleStateForDebug` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:122` | `PLAPI` | `modifySTAOutputDir` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:123` | `PLAPI` | `initSTA` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:124` | `PLAPI` | `updateSTATiming` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:125` | `PLAPI` | `obtainClockNameList` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:126` | `PLAPI` | `isClockNet` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:127` | `PLAPI` | `isSequentialCell` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:128` | `PLAPI` | `isBufferCell` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:129` | `PLAPI` | `updateSequentialProperty` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:138` | `PLAPI` | `obtainTimingCoverage` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:148` | `PLAPI` | `obtainPinEarlySlack` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:149` | `PLAPI` | `obtainPinLateSlack` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:150` | `PLAPI` | `obtainPinEarlyArrivalTime` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:151` | `PLAPI` | `obtainPinLateArrivalTime` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:152` | `PLAPI` | `obtainPinEarlyRequiredTime` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:153` | `PLAPI` | `obtainPinLateRequiredTime` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:154` | `PLAPI` | `obtainWNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:155` | `PLAPI` | `obtainTNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:156` | `PLAPI` | `obtainEarlyWNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:157` | `PLAPI` | `obtainEarlyTNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:158` | `PLAPI` | `obtainLateWNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:159` | `PLAPI` | `obtainLateTNS` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:160` | `PLAPI` | `updateTiming` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:166` | `PLAPI` | `obtainPinCap` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:167` | `PLAPI` | `obtainAvgWireResUnitLengthUm` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:168` | `PLAPI` | `obtainAvgWireCapUnitLengthUm` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:169` | `PLAPI` | `obtainInstOutPinRes` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:172` | `PLAPI` | `destroyTimingEval` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PLAPI.hh:176` | `PLAPI` | `outputSummary` | not_exposed_to_interface |
| iPL | operation_api | `src/operation/iPL/api/PlacementStatus.hh:229` | `PlacementStatusEvaluator` | `stage` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PlacementStatus.hh:300` | `PlacementStatusEvaluator` | `stage` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/PlacementStatus.hh:323` | `PlacementStatusEvaluator` | `stage` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:35` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:38` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:41` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:44` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:48` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:51` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:54` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPL | operation_api | `src/operation/iPL/api/TimingCoverage.hh:57` | `PlacementStatusEvaluator` | `fail` | referenced_by_interface |
| iPNP | operation_api | `src/operation/iPNP/api/ipnp_api.hh:57` | `PNPApi` | `run_pnp` | referenced_by_interface |
| iPNP | operation_api | `src/operation/iPNP/api/ipnp_api.hh:58` | `PNPApi` | `connect_M2_M1` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:112` | `TimingIDBAdapter` | `getAverageResistance` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:113` | `TimingIDBAdapter` | `getAverageCapacitance` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:118` | `TimingIDBAdapter` | `dbToSta` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:148` | `TimingIDBAdapter` | `dbToSta` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:149` | `TimingIDBAdapter` | `staToDb` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:151` | `TimingIDBAdapter` | `dbToSta` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:152` | `TimingIDBAdapter` | `staToDb` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:156` | `TimingIDBAdapter` | `createInstance` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:157` | `TimingIDBAdapter` | `deleteInstance` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:158` | `TimingIDBAdapter` | `substituteCell` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:160` | `TimingIDBAdapter` | `attach` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:161` | `TimingIDBAdapter` | `attach` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:162` | `TimingIDBAdapter` | `disattachPin` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:163` | `TimingIDBAdapter` | `disattachPinPort` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:167` | `TimingIDBAdapter` | `createNet` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:172` | `TimingIDBAdapter` | `deleteNet` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:174` | `TimingIDBAdapter` | `renameNet` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:175` | `TimingIDBAdapter` | `swapNetNames` | referenced_by_interface |
| iSTA | operation_api | `src/operation/iSTA/api/TimingIDBAdapter.hh:222` | `TimingIDBAdapter` | `configStaLinkCells` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:47` | `ToApi` | `destroyInst` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:49` | `ToApi` | `init` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:50` | `ToApi` | `initEngine` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:52` | `ToApi` | `runTO` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:54` | `ToApi` | `optimizeDrv` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:55` | `ToApi` | `optimizeDrvSpecialNet` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:58` | `ToApi` | `optimizeSetup` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:59` | `ToApi` | `performBuffering` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:62` | `ToApi` | `optimizeHold` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:64` | `ToApi` | `saveDef` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:66` | `ToApi` | `resetConfigLibs` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:67` | `ToApi` | `resetConfigSdc` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:69` | `ToApi` | `reportTiming` | referenced_by_interface |
| iTO | operation_api | `src/operation/iTO/api/ToApi.hpp:71` | `ToApi` | `outputSummary` | referenced_by_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:50` | `CtsIO` | `runCTS` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:51` | `CtsIO` | `reportCTS` | referenced_by_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:52` | `CtsIO` | `runPostCTSLegalize` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:53` | `CtsIO` | `runPostCTSLegalizeWithResult` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:63` | `CtsIO` | `readCtsDataFromFile` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:64` | `CtsIO` | `saveCtsDataToFile` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:84` | `CtsIO` | `readTreeDataFromFile` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:85` | `CtsIO` | `saveTreeDataToFile` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:87` | `CtsIO` | `getTreeData` | not_exposed_to_interface |
| icts_io | platform_tool_api | `src/platform/tool_manager/tool_api/icts_io/icts_io.h:110` | `CtsIO` | `updateLeafNumber` | not_exposed_to_interface |
| idrc_io | platform_tool_api | `src/platform/tool_manager/tool_api/idrc_io/idrc_io.h:41` | `DrcIO` | `runDRC` | not_exposed_to_interface |
| idrc_io | platform_tool_api | `src/platform/tool_manager/tool_api/idrc_io/idrc_io.h:42` | `DrcIO` | `readDrcFromFile` | not_exposed_to_interface |
| idrc_io | platform_tool_api | `src/platform/tool_manager/tool_api/idrc_io/idrc_io.h:43` | `DrcIO` | `saveDrcToFile` | not_exposed_to_interface |
| idrc_io | platform_tool_api | `src/platform/tool_manager/tool_api/idrc_io/idrc_io.h:45` | `DrcIO` | `getDetailCheckResult` | not_exposed_to_interface |
| ino_io | platform_tool_api | `src/platform/tool_manager/tool_api/ino_io/ino_io.h:40` | `NoIO` | `runNOFixIO` | not_exposed_to_interface |
| ino_io | platform_tool_api | `src/platform/tool_manager/tool_api/ino_io/ino_io.h:41` | `NoIO` | `runNOFixFanout` | not_exposed_to_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:74` | `PlacerIO` | `initPlacer` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:75` | `PlacerIO` | `destroyPlacer` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:76` | `PlacerIO` | `runPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:77` | `PlacerIO` | `runAiPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:78` | `PlacerIO` | `runIncrementalLegalization` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:79` | `PlacerIO` | `runIncrementalLegalization` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:82` | `PlacerIO` | `runFillerInsertion` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:83` | `PlacerIO` | `runMacroPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:84` | `PlacerIO` | `runGlobalPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:85` | `PlacerIO` | `runLegalization` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:86` | `PlacerIO` | `runDetailPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:88` | `PlacerIO` | `checkLegality` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:89` | `PlacerIO` | `reportPlacement` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:91` | `PlacerIO` | `runIncrementalFlow` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:93` | `PlacerIO` | `readInstanceDataFromDirectory` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:94` | `PlacerIO` | `saveInstanceDataToDirectory` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:97` | `PlacerIO` | `readInstanceDataFromFile` | referenced_by_interface |
| ipl_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipl_io/ipl_io.h:98` | `PlacerIO` | `saveInstanceDataToFile` | referenced_by_interface |
| ipnp_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipnp_io/ipnp_io.h:33` | `PnpIO` | `runPNP` | not_exposed_to_interface |
| ipw_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipw_io/ipw_io.h:51` | `PowerIO` | `autoRunPower` | referenced_by_interface |
| ipw_io | platform_tool_api | `src/platform/tool_manager/tool_api/ipw_io/ipw_io.h:52` | `PowerIO` | `runPower` | referenced_by_interface |
| irt_io | platform_tool_api | `src/platform/tool_manager/tool_api/irt_io/irt_io.h:42` | `RTIO` | `getInst` | referenced_by_interface |
| irt_io | platform_tool_api | `src/platform/tool_manager/tool_api/irt_io/irt_io.h:43` | `RTIO` | `delInst` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:55` | `StaIO` | `autoRunSTA` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:56` | `StaIO` | `initSTA` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:57` | `StaIO` | `isInitSTA` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:58` | `StaIO` | `buildGraph` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:59` | `StaIO` | `runSTA` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:60` | `StaIO` | `updateTiming` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:61` | `StaIO` | `buildClockTree` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:63` | `StaIO` | `getClockTree` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:66` | `StaIO` | `getClockNetNameList` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:67` | `StaIO` | `getClockNameList` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:68` | `StaIO` | `getCellType` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:69` | `StaIO` | `isClockNet` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:70` | `StaIO` | `isSequentialCell` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:74` | `StaIO` | `obtainInstPinCap` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:75` | `StaIO` | `obtainPinCap` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:76` | `StaIO` | `obtainAvgWireResUnitLengthUm` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:77` | `StaIO` | `obtainAvgWireCapUnitLengthUm` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:78` | `StaIO` | `obtainInstOutPinRes` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:80` | `StaIO` | `setStaWorkDirectory` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:81` | `StaIO` | `readIdb` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:82` | `StaIO` | `runSDC` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:83` | `StaIO` | `runLiberty` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:84` | `StaIO` | `runSpef` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:85` | `StaIO` | `reportTiming` | referenced_by_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:86` | `StaIO` | `buildNetGraph` | not_exposed_to_interface |
| ista_io | platform_tool_api | `src/platform/tool_manager/tool_api/ista_io/ista_io.h:87` | `StaIO` | `getPeriodNS` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:52` | `ToIO` | `runTO` | referenced_by_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:54` | `ToIO` | `runTOFixFanout` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:55` | `ToIO` | `runTODrv` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:56` | `ToIO` | `runTODrvSpecialNet` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:57` | `ToIO` | `runTOHold` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:58` | `ToIO` | `runTOSetup` | not_exposed_to_interface |
| ito_io | platform_tool_api | `src/platform/tool_manager/tool_api/ito_io/ito_io.h:59` | `ToIO` | `runTOBuffering` | not_exposed_to_interface |
