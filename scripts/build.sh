#!/usr/bin/env bash
set -e

# Create scratch org
echo "1. START OF CREATION SCRATCH ORG..."
echo " SCRATCH ORG NAME: trade-lwc-scratch"
sfdx force:org:create -f config/project-scratch-def.json --durationdays 30 -a trade-lwc-scratch
echo "  SCRATCH ORg CREATED!"

# Set defaultusername scratch org
echo "2. SETTING DEFAULTUSERNAME SCRATCH ORG..."
sfdx force:config:set defaultusername=trade-lwc-scratch
echo " SCRATCH OR CREATED!"

# Push changes
echo "3. PUSHING CHANGES..."
sfdx force:source:push -u trade-lwc-scratch
echo " PUSHED CHANGES!"

# Run Test 
echo "4. RUNNING TESTS..."
sfdx force:apex:test:run -n "NewTradeControllerTest" -r human 
echo "4. RUNNED TESTS!"




