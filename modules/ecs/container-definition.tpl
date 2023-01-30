[
    {
        "name": "haproxy",
        "image": "${myecrrepo}/dockercloud/haproxy:latest",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 80
            },
            {
                "containerPort": 443,
                "hostPort": 443
            }
        ]
    },
    {
        "name": "api-gateway",
        "image": "${myecrrepo}/api-gateway",
        "cpu": 256,
        "memory": 512,
        "command": [
            "node",
            "api-gateway"
        ],
        "environment": [
            {
                "name": "VIRTUAL_HOST",
                "value": "api-gateway.app.com"
            }
        ],
        "essential": true,
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ]
    },
    {
        "name": "delivery-service",
        "image": "${myecrrepo}/delivery-service",
        "cpu": 256,
        "memory": 512,
        "command": [
            "node",
            "delivery-service"
        ],
        "essential": true
    },
    {
        "name": "order-service",
        "image": "${myecrrepo}/order-service",
        "cpu": 256,
        "memory": 512,
        "command": [
            "node",
            "order-service"
        ],
        "essential": true
    },
    {
        "name": "restaurants-service",
        "image": "${myecrrepo}/restaurants-service",
        "cpu": 256,
        "memory": 512,
        "command": [
            "node",
            "restaurants-service"
        ],
        "essential": true
    }
]