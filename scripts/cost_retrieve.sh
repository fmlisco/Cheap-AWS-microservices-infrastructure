#!/bin/bash

# Set the start and end date for the cost report
start_date=$(date --date="30 days ago" +%Y-%m-%d)
end_date=$(date +%Y-%m-%d)

# Retrieve the cost report
result=$(aws ce get-cost-and-usage --time-period Start=$start_date,End=$end_date --granularity DAILY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE)

# Extract the data for the production environment
production_cost=0.0
while read -r line; do
    service=$(echo $line | awk '{print $1}')
    cost=$(echo $line | awk '{print $2}')
    if [ "$service" == "PRODUCTION" ]; then
        production_cost=$(echo "$production_cost + $cost" | bc)
    fi
done <<< "$result"

echo "The total cost of the production environment between $start_date and $end_date is: \$$production_cost"
