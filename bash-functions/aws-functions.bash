aws-login() {
  # Define color variables
  GREEN="\033[32m"
  RED="\033[31m"
  YELLOW="\033[33m"
  DARKGREY="\033[30m"
  BLUE="\033[34m"
  NC="\033[0m" # No Color

  # Check if required environment variables are set
  if [[ -z "$ECR_USERNAME" ]]; then
    echo -e "${YELLOW}WARNING: ECR_USERNAME is not set. Please set it to your Docker username.${NC}"
    return 1
  fi

  if [[ -z "$ECR_HOST_URL" ]]; then
    echo -e "${YELLOW}WARNING: ECR_HOST_URL is not set. Please set it to your ECR host URL.${NC}"
    return 1
  fi

  # Check if AWS credentials are valid
  aws sts get-caller-identity &> /dev/null
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}AWS credentials are invalid or expired. Attempting to log in via AWS SSO...${NC}"
    aws sso login
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Failed to log in via AWS SSO. Please check your configuration.${NC}"
      return 1
    fi
  fi

  echo -e "${GREEN}AWS credentials are valid.${NC}"

  # Log in to ECR
  echo -e "${NC}Logging in to ECR at ${BLUE}$ECR_HOST_URL...${NC}"
  aws ecr get-login-password | docker login --username "$ECR_USERNAME" --password-stdin "$ECR_HOST_URL"
  if [[ $? -eq 0 ]]; then
    echo -e "👍 ${GREEN}Done ${NC}"
  else
    echo -e "${RED}Failed to log in to ECR. Please check your credentials and configuration.${NC}"
    return 1
  fi
}