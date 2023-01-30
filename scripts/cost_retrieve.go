package main

import (
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/costexplorer"
)

func main() {
	// Create a new session
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create a new CostExplorer client
	svc := costexplorer.New(sess)

	// Set the start and end date for the cost report
	end := time.Now()
	start := end.AddDate(0, 0, -30)

	// Define the parameters for the cost report
	params := &costexplorer.GetCostAndUsageInput{
		TimePeriod: &costexplorer.DateInterval{
			Start: aws.String(start.Format("2006-01-02")),
			End:   aws.String(end.Format("2006-01-02")),
		},
		Granularity: aws.String("DAILY"),
		Metrics:     []*string{aws.String("BlendedCost")},
		GroupBy: []*costexplorer.GroupDefinition{
			&costexplorer.GroupDefinition{
				Type:  aws.String("DIMENSION"),
				Key:   aws.String("SERVICE"),
			},
		},
	}

	// Retrieve the cost report
	result, err := svc.GetCostAndUsage(params)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Extract the data for the production environment
	productionCost := 0.0
	for _, group := range result.ResultsByTime[0].Groups {
		if *group.Keys[0] == "PRODUCTION" {
			productionCost += *group.Metrics["BlendedCost"].Amount
		}
	}
	fmt.Printf("The total cost of the production environment between %s and %s is: $%.2f\n", start.Format("2006-01-02"), end.Format("2006-01-02"), productionCost)
}