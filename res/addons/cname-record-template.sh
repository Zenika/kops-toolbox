cat << COINCOIN
{
  "Comment": "string",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "*.kube.gilleslabs.xyz",
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