FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /App

## Arguments for setting the Sonarqube Token, Project Key, Sonarqube Uri
ARG SONAR_TOKEN
ARG SONAR_BACKEND_API_PROJECT_KEY
ARG SONAR_HOST

## Install Java, because the sonarscanner needs it.
RUN apt-get update
RUN apt-get dist-upgrade -y 
RUN apt-get install -y openjdk-17-jre 

## Install sonarscanner
RUN dotnet tool install --global dotnet-sonarscanner --version 6.1.0

##Install dotnet-coverage
RUN dotnet tool install --global dotnet-coverage

## Set the dotnet tools folder in the PATH env variable
ENV PATH="${PATH}:/root/.dotnet/tools"

## Start scanner
RUN dotnet sonarscanner begin \
	/k:"$SONAR_BACKEND_API_PROJECT_KEY" \
	/d:sonar.host.url="$SONAR_HOST" \
	/d:sonar.token="$SONAR_TOKEN" \ 
	/d:sonar.cs.vscoveragexml.reportsPaths="coverage.xml"

# Copy everything
COPY CalculatorApp/ .

## Build the app and collect coverage
RUN dotnet build && \
    dotnet test && \
    dotnet-coverage collect "dotnet test" -f xml -o "coverage.xml"
 
## Stop scanner
RUN dotnet sonarscanner end /d:sonar.token="$SONAR_TOKEN"
EXPOSE 5099
CMD ["dotnet", "run","--project","CalculatorApp"]
