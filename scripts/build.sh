#!/usr/bin/env bash
set -e

# Create scratch org
sfdx force:org:create -f config/project-scratch-def.json --durationdays 30 -a trade-lwc-scratch

# Set defaultusername scratch org
sfdx force:config:set defaultusername=trade-lwc-scratch

# Open scratch org
sfdx force:org:open

#Get Custom Settings
sfdx force:source:retrieve -m CustomObject:EburyTradeSettings__c

# Push changes
sfdx force:source:push


