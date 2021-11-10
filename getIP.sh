#!/bin/bash
az vm show -d -g dockerEngineRG -n dockerEngine --query publicIps -o tsv
