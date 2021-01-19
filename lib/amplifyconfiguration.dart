const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ca-central-1:d2f612f2-339f-4593-97e6-22ad9a9040cb",
                            "Region": "ca-central-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ca-central-1_WJdOgmXom",
                        "AppClientId": "4i0i31ej5h9uvvg1q1p259o3k4",
                        "AppClientSecret": "ac8r61eaphpvjatlu8rtp6e5fi8gko9aldrrp90cnrclsd7hcmd",
                        "Region": "ca-central-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH"
                    }
                },
                "AppSync": {
                    "Default": {
                        "ApiUrl": "https://ln7phmt5qbct5kx3bsahlext7a.appsync-api.ca-central-1.amazonaws.com/graphql",
                        "Region": "ca-central-1",
                        "AuthMode": "API_KEY",
                        "ApiKey": "da2-u4c5ls4udvbqtkcyhfn7viyfou",
                        "ClientDatabasePrefix": "todolist_API_KEY"
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "todolist": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://ln7phmt5qbct5kx3bsahlext7a.appsync-api.ca-central-1.amazonaws.com/graphql",
                    "region": "ca-central-1",
                    "authorizationType": "API_KEY",
                    "apiKey": "da2-u4c5ls4udvbqtkcyhfn7viyfou"
                }
            }
        }
    }
}''';