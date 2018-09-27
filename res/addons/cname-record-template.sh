cat << COINCOIN
{
  "Comment": "string",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "*.$CLUSTER_DOMAIN",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$DNS_NAME"
          }
        ]
      }
    }
  ]
}
COINCOIN