import boto3
import argparse

# Create a boto3 client for the Cost Explorer service
# e.g.
# $ python cost_retrieve_with_args.py --start_date 2022-11-01 --end_date 2023-01-10
# The total cost of the production environment between 2022-11-01 and 2023-01-10 is: $0.00

client = boto3.client('ce')

def get_production_cost(start_date, end_date):
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
    return production_cost

# Create a command-line argument parser
parser = argparse.ArgumentParser()
parser.add_argument('--start_date', required=True, help='Start date in YYYY-MM-DD format')
parser.add_argument('--end_date', required=True, help='End date in YYYY-MM-DD format')
args = parser.parse_args()

cost = get_production_cost(args.start_date, args.end_date)
print("The total cost of the production environment between {} and {} is: ${:.2f}".format(args.start_date, args.end_date, cost))

