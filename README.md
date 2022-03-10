# Take home assignment
Sing gee's take home assignment, thank you for taking time to review the code!

# Requirements
- pipenv

# How to run assignment using `Docker` and `Make` 
1. `make setup`
2. `make run` *

*Note: Do ensure that your environment variable `GOOGLE_APPLICATION_CREDENTIALS` is set before running `make run`

# How to run using just `Docker`
### On windows
1. docker build -t sg-assignment .
2. docker run -v %GOOGLE_APPLICATION_CREDENTIALS%:/root/.config/gcloud/application_default_credentials.json:ro -v %cd%/results:/assignment/results sg-assignment

### On Mac OS or Linux
1. docker build -t sg-assignment .
2. docker run -v $(GOOGLE_APPLICATION_CREDENTIALS):/root/.config/gcloud/application_default_credentials.json:ro -v $(pwd)/results:/assignment/results sg-assignment
