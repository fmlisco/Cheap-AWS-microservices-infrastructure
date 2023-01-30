# Cheap AWS microservices infrastructures

## Objective 
The purpose of this project is to demonstrate the feasibility of creating an AWS infrastructure that utilizes microservices at a low cost. The goal is to achieve cost-effectiveness, with a budget of $65 per month, and an average hourly cost of less than $0.10.

## AWS infrastructure setup
1. Comment, modify, or delete the content of the file **backend.tf** if you want to run it locally.
2. run: `make init` 
3. `make plan` 
4. `make apply`

## Flow
- Ideally **Jenkins** controls the workflow of this project (the Jenkinsfile is located in the **jenkins** folder)
- for any environment (**dev/test/production**), the following steps are taken:
1. Downloads the **microservices-workshop** git repo
2. Builds the related docker images
3. Pushes the docker images to our ECR, created for this purpose
4. Runs `terraform apply`

## Script to Retrieve the Cost of the Production Environment
The task requested me to create a python script to achieve this result so in the folder **scripts** you can find:
- a python script to retrieve the AWS  costs related to the last 30 days
- a python script to retrieve the AWS  costs but in this case it's necessary to specify start and end dates
- a bash script
- a golang script 

All of them have the purpose to retrieve the AWS costs. Up to you to choose which one to use