#!/usr/bin/env bash
helpFunction()
{
  echo ""
  echo "Usage: $0 -s stackName -r region -p parameterFile"
  echo -e "\t-s stack name for the cloudformation"
  echo -e "\t-r region of the aws "
  echo -e "\t-p parameters file"
  exit 1 # Exit script after printing help
}

while getopts "s:r:t:p:" opt
do
  case "$opt" in
    s ) STACK_NAME="$OPTARG" ;;
    r ) REGION="$OPTARG" ;;
    p ) PARAMETER_FILE="$OPTARG";;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done
if [ -z "$STACK_NAME" ] || [ -z "$REGION" ] || [ -z "$PARAMETER_FILE" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi


echo "Deploying the Cloud Formation Template with Stack Name: " $STACK_NAME
echo "Using Parameters specified in the file: " $PARAMETER_FILE
echo "Using Region: " $REGION


read -p "Confirm params above and press enter to continue"

aws cloudformation validate-template --template-body file://namespace.yaml
aws --region $REGION cloudformation deploy \
    --template-file namespace.yaml \
    --parameter-overrides \
    $(jq -r '.Parameters | keys[] as $k | "\($k)=\(.[$k])"' $PARAMETER_FILE) \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name $STACK_NAME