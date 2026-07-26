variable "DYNAMO_QUESTIONS_TABLE" {
  type    = string
  default = ""
}

variable "DYNAMO_INTERVENTIONS_TABLE" {
  type    = string
  default = ""
}

variable "DYNAMO_REPORTS_TABLE" {
  type    = string
  default = ""
}

variable "S3_OUTPUT_BUCKET_NAME" {
  type    = string
  default = ""
}

variable "S3_INPUT_BUCKET_NAME" {
  type    = string
  default = ""
}

variable "SQS_QUEUE_NAME" {
  type    = string
  default = ""
}

variable "SQS_DEADLETTER_QUEUE_NAME" {
  type    = string
  default = ""
}