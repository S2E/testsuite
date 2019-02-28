#!/bin/bash

{% include 'common-run.sh.tpl' %}

s2e run -n {{ project_name }}

echo === Checking that faults were injected
grep -q "FaultInjInvokeOrig_ZwOpenKey" $S2E_LAST/debug.txt
grep -q "FaultInjInvokeOrig_ExAllocatePoolWithTag" $S2E_LAST/debug.txt

echo === Computing code coverage
s2e coverage --sympath {{ test_dir }}/scanner lcov --html {{ project_name }} | tee $S2E_LAST/cov.log

echo === Checking code coverage
COV_PC=$(grep "lines......" $S2E_LAST/cov.log | cut -d : -f 2 | cut -d '%' -f 1)

if (( $(bc <<< "$COV_PC < 50") )); then
    echo Bad coverage: $COV_PC
    exit 1
fi