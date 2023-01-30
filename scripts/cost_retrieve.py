import boto3
from datetime import datetime, timedelta

# Set the start and end date for the cost report
start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
end_date = datetime.now().strftime('%Y-%m-%d')

# Create a boto3 client for the Cost Explorer service
client = boto3.client('ce')

# Define the parameters for the cost report
params = {
    'TimePeriod': {
        'Start': start_date,
        'End': end_date
    },
    'Granularity': 'DAILY',
    'Metrics': ['BlendedCost'],
    'GroupBy': [{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
}

# Retrieve the cost report
result = client.get_cost_and_usage(**params)

# Extract the data for the production environment
production_cost = 0.0
for group in result['ResultsByTime'][0]['Groups']:
    if group['Keys'][0] == 'PRODUCTION':
        production_cost += float(group['Metrics']['BlendedCost']['Amount'])

print("The total cost of the production environment between {} and {} is: ${:.2f}".format(start_date, end_date, production_cost))
