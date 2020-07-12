terraform {
  backend "${BACKEND_TYPE}" {
    ${BUCKET}
    ${KEY}
    ${REGION}
    ${DYNAMODB_TABLE}
    ${ENCRYPT}
  }
}